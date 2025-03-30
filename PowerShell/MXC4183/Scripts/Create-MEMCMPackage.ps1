<#
.SYNOPSIS
	This script will create a package, it's programs, distribute the content and deployments (optional) for CR testing. 
.DESCRIPTION
	This script will create a package, it's programs, distribute the content and deployments (optional) for CR testing. 
.PARAMETER Site
	This is the site you're in. Default is WQ1.
.PARAMETER Collection
	This should be the testing collection you want to deploy your package to. Default is my collection. 
.PARAMETER PackageID
	This should be the package you want to test your deployment with.
.EXAMPLE
    Update this later...
#>
#Parameters to enter. Use PSADT script to fill in info

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('WQ1','SQ1','MT1')]
    [string]$Site = $Site,
    [Parameter(Mandatory=$true)]
    [string]$CR,
    [Parameter(Mandatory=$false)]
    [string]$SourceLocation,
    [Parameter(Mandatory=$false)]
    [string]$PackageVendor,
    [Parameter(Mandatory=$false)]
    [string]$PackageProduct,
    [Parameter(Mandatory=$false)]
    [string]$PackageVersion,
    [Parameter(Mandatory=$true)]
    [string]$ProgramDiskSpaceReq,
    [Parameter(Mandatory=$true)]
    [string]$ProgramDuration
)

# Pull the CR info from the CR database.
$SQLServer = "scdddb.humana.com" #or machinename: LOUSQLWPS747
$SQLQ = Invoke-Sqlcmd -ServerInstance $SQLServer -Database ATSCERTREQ -Query "select * from sc.request where RequestID = $CR"
$Product = Invoke-Sqlcmd -ServerInstance $SQLServer -Database ATSCERTREQ -Query "select * from sc.product where ProductId = $($SQLQ.ProductID)" -ea stop
$Vendor = Invoke-Sqlcmd -ServerInstance $SQLServer -Database ATSCERTREQ -Query "select * from sc.vendor where vendorId = $($Product.VendorID)"

# Had to convert the results Invoke-sqlcmd to a string. https://stackoverflow.com/questions/46964645/store-invoke-sqlcmd-query-as-string
$VendorName = $vendor.name.ToString()
$ProductName = $product.name.ToString()
$VersionNumber = $sqlq.Productversion.ToString()

If ($PackageName.Length -gt 40 -or $VersionNumber.Length -gt 30) {
    Write-Warning "Your package name exceeds 40 characters OR your version is more than 32 characters, shorten and try again!"
    EXIT
}
else{  
#PSS for each env.
$SiteCode = switch ( $Site ) {
    MT1 { 'LOUAPPWTS1140.rsc.humad.com' }
    WQ1 { 'LOUAPPWQS1151.rsc.humad.com' }
    SQ1 { 'LOUAPPWQS1150.rsc.humad.com' }
}


#region Connect 
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $SiteCode -ErrorAction SilentlyContinue
Push-Location $Site":"
Write-Output "Connected to $Site..."
#endregion Connect

# Hardcording the install/uninstall commands.
$SilentInstallCommand = "Deploy-Application.exe -DeployMode Silent"
$SilentUninstallCommand = "Deploy-Application.exe -DeploymentType Uninstall"

# Setting variables for supported OSes. These will get set later based env.

    $OSreq = Get-CMSupportedPlatform -Fast | Where-Object {$_.Displaytext -eq "All Windows 10 (64-bit) Client"}
    $OSSvrReq = Get-CMSupportedPlatform -Fast | Where-Object {$_.DisplayText -eq "All x64 Windows Server 2016"}
    $OSsvrReq2012 = Get-CMSupportedPlatform -Fast | Where-Object {$_.DisplayText -eq "All x64 Windows Server 2012 R2"}
    $OSSvrReq2019 = Get-CMSupportedPlatform -Fast | Where-Object {$_.DisplayText -eq "All x64 Windows Server 2019 and higher"}

    # Took the sourcelocation out of parameters. If we know the CR#, we can deduce the source location.
    if($site -eq "WQ1"){
        $SourceLocation = "\\lounaswps08\pdrive\d907ats\$CR\install"
    }
    elseif($site -eq "SQ1"){
        $SourceLocation = "\\lounaswps08\pdrive\d907atssvr\$CR\install"
    }
    else{
        Write-host -ForegroundColor Red "Your Site code is wack. Exiting..."
        EXIT
    }

    # Now we don't need to bug the user with the source location, let's get on with creating the package.
    Write-Output "Creating package"
      $NewPackage = New-CMPackage -Name $ProductName -Manufacturer $VendorName -Version $VersionNumber -Path $SourceLocation -Language 'EN'
    Write-Progress -Activity "Creating Package" -PercentComplete 25
    Set-CMPackage -Name $ProductName -DistributionPriority Normal

    # Create install/uninstall programs and change what OS types can get the package based on which env we're in.
    # Checking to make sure install/uninstall program names don't exceed 50 characters.
    If ($ProductName.Length -gt 40) {
        Write-Warning "Your Install $productname exceeds 50 characters. Please shorten the product name or manually create the package programs."
        EXIT
    }
    else{
        if($site -eq "SQ1"){
            Write-Output "Creating install program in SQ1..."
            New-CMProgram -PackageID $NewPackage.PackageID -StandardProgramName "Install $ProductName" -CommandLine $SilentInstallCommand -DiskSpaceRequirement $ProgramDiskSpaceReq -DiskSpaceUnit MB -Duration $ProgramDuration -ProgramRunType WhetherOrNotUserIsLoggedOn -RunMode RunWithAdministrativeRights -AddSupportedOperatingSystemPlatform $OSsvrReq2012,$OSSvrReq,$OSSvrReq2019
        }
        else{
            Write-Output "Creating install program in WQ1..."
            New-CMProgram -PackageID $NewPackage.PackageID -StandardProgramName "Install $ProductName" -CommandLine $SilentInstallCommand -DiskSpaceRequirement $ProgramDiskSpaceReq -DiskSpaceUnit MB -Duration $ProgramDuration -ProgramRunType WhetherOrNotUserIsLoggedOn -RunMode RunWithAdministrativeRights -AddSupportedOperatingSystemPlatform $OSreq
        }
            # Create the Uninstall Program. No need to specify who can run this. Any OS can...
            Write-Output "Creating uninstall program..."
            New-CMProgram -PackageID $NewPackage.PackageID -StandardProgramName "Uninstall $ProductName" -CommandLine $SilentUninstallCommand -DiskSpaceRequirement $ProgramDiskSpaceReq -DiskSpaceUnit MB -Duration $ProgramDuration -ProgramRunType WhetherOrNotUserIsLoggedOn -RunMode RunWithAdministrativeRights
            Write-Progress -Activity "Creating Install Program" -PercentComplete 75
        }

     # Distribute the content. Adding a pause here. May not be needed but eh.
     Write-Output "Waiting 1 minute to let things settle in..."
     Start-sleep -Seconds 60
     Write-Output "Distributing content..."
     # Added verbose logging and confirm:$false
     Start-CMContentDistribution -PackageId $NewPackage.PackageID -DistributionPointGroupName "All DP's" -Verbose -confirm:$false
     Write-Progress -Activity "Distributing package." -PercentComplete 95
     #Write-Output "Waiting 5 minutes while content is distributed before moving on."
     #Start-Sleep -Seconds 300
     Write-Output "Moving on..."

     # Set collectionIDs based on what env we're in. These are my test collections.
    if($site -eq 'WQ1'){
        $Collection = 'WQ100500'
    }
    elseif($site -eq 'SQ1'){
        $Collection = 'SQ100757'
    }
    else {
         Write-Output "No valid testing colletion passed, exiting..."
         EXIT
    }
   
    # Validate content is on the DPs then deploy the programs.
    if(Invoke-CMContentValidation -PackageId $NewPackage.packageID -DistributionPointGroupName "All DP's"){
        Write-host "Content not found, please ensure content is on the DPs"
        EXIT
    }else{
        Get-CMPackage -packageID $NewPackage.packageID -fast
        $Actions = (Get-CMProgram -PackageId $NewPackage.PackageID).programname
            foreach ($Action in $Actions) {
                Write-Output "Content found on the DPs! Creating available deployments..."
                New-CMPackageDeployment -PackageId $NewPackage.PackageID -CollectionID $Collection -ProgramName $Action -StandardProgram -FastNetworkOption DownloadContentFromDistributionPointAndRunLocally -SlowNetworkOption DownloadContentFromDistributionPointAndLocall -Comment "This deployment was created by Mike's Create-CRdeployment.ps1 script." -DeployPurpose Available
            }
        # Hit my collections with machine update so I don't have to. (based on the env obvs)
        Invoke-CMClientAction -CollectionID $Collection -ActionType ClientNotificationRequestMachinePolicyNow
            
            # Move the package to my folder (parameterize this later)
            $Me = $NewPackage.name
            Write-Output "Moving $me to my folder... (\mxc4183)"
            Move-CMObject -FolderPath "\Package\SWS Packages\MXC4183" -ObjectID $NewPackage.PackageID
            # Let 'em know.
            Write-host "Site:" -ForegroundColor Green $Site
            Write-Host "Name:"-ForegroundColor Green $NewPackage.Name
            Write-Host "PkgID :"-ForegroundColor Green $NewPackage.packageID
            Set-location -Path "C:\temp"
        }
    # Finally, enable Nomad if we're in WQ1.
    if($site -eq 'WQ1'){
        # Connect to remote WMI, pass the CR, use get() method to get the lazy properties not displayed.
        $TestPkg = Get-WmiObject -Namespace root\sms\site_WQ1 -Class SMS_PackageBaseClass -Impersonation 3 -ComputerName LOUAPPWQS1151.rsc.humad.com | Where-Object {$_.PackageID -eq $NewPackage.packageID }
        $TestPkg.get()
        $TestPkg = $TestPkg.AlternateContentProviders

        # Couldn't figure out the IF so just checked for the whole dang string to make it work.
        If($TestPkg -eq '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>1</pc></Data></Provider></AlternateDownloadSettings>'){
            Write-Host -ForegroundColor Green "CR: $CR has ACP properties!"
            Write-Host -ForegroundColor Green "Those properties are: $TestPkg"
        }
        else{
            # Update the lazy property. Just dumped the xml output in there. It was a string so... itsworking.gif
            Write-Host -ForegroundColor Red "No ACP settings found. Setting ACP to Nomad."
            $TestPkg = Get-WmiObject -Namespace root\sms\site_WQ1 -Class SMS_PackageBaseClass -Impersonation 3 -ComputerName LOUAPPWQS1151.rsc.humad.com | Where-Object {$_.PackageID -eq $NewPackage.packageID }
            $TestPkg.get()
            $TestPkg.AlternateContentProviders = '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>1</pc></Data></Provider></AlternateDownloadSettings>'
            $TestPkg.put()
            Write-Host -ForegroundColor Green "ACP for $CR set to Nomad!"
            Write-Host "Package created. All done."
            Write-host "Site:" -ForegroundColor Green $Site
            Write-Host "Name:"-ForegroundColor Green $NewPackage.Name
            Write-Host "PkgID :"-ForegroundColor Green $NewPackage.packageID
            Set-location -Path "C:\temp"

        }
    }
}