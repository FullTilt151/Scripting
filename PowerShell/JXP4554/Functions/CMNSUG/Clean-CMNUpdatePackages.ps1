<#
.SYNOPSIS
    Perform a clean up of all Software Updates Groups in ConfigMgr

.DESCRIPTION
    Use this script if you need to perform a clean up of expired or superseded Software Updates in all Software Upgrade Groups in ConfigMgr 2012

.PARAMETER SiteServer
    Site server name with SMS Provider installed

.PARAMETER PackageSourcePath
    Location for the new packages, must be a UNC path

.Parameter DPGroupName
    Name of the Distribution Point Group to put the new packages on

.EXAMPLE

.NOTES
    SMS_AuthorizationList - CI_ID - > Updates contains Update CI_ID's #LAZY
    SMS_CIToContent - CI_ID links to SMS_SoftwareUpdate ContentID links to SMSPackageToContent
    SMS_PackageToContent - ContentID maps to PackageID
    SMS_SoftwareUpdate - Each Software Update CI_ID
    SMS_UpdateGroupAssignment - Deployment to collection AssignmentID - Assigned CI's
    \\lounaswps01\idrive\Dept907.CIT\Patching
#>

[CmdletBinding()]
PARAM(
    [Parameter(Mandatory = $true, HelpMessage = "Site server where the SMS Provider is installed")]
    [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    [string]$SiteServer,

    [Parameter(Mandatory = $true, HelpMessage = "Base directory for downloading updates, must be UNC")]
    [String]$PackageSourcePath,

    [Parameter(Mandatory = $true, HelpMessage = "Distribution Point Group to add new packages to")]
    [String]$DPGroupName,

    [Parameter(Mandatory = $false, HelpMessage = 'Display progress')]
    [Switch]$ShowProgress
)

Function Get-Updates {
    Param    (
        [Parameter(Mandatory = $true)]
        [PSObject]$SUG,
        [Parameter(Mandatory = $true)]
        [Array]$UpdateList
    )

    Write-Verbose "Getting updates for package $($SUG.Name)"
    $downloadpath = ($SUG.PkgSourcePath)

    $DownloadInfo = foreach ($CI_ID in $UpdateList) {
        $contentID = Get-WmiObject -Query "Select ContentID,ContentUniqueID,ContentLocales from SMS_CITOContent Where CI_ID='$CI_ID'"  @WMIQueryParameters
        #Filter out the English Local and ContentID's not targeted to a particular Language
        $contentID = $contentID  | Where {($_.ContentLocales -eq "Locale:9") -or ($_.ContentLocales -eq "Locale:0") }

        foreach ($id in $contentID) {
            $contentFile = Get-WmiObject -Query "Select FileName,SourceURL from SMS_CIContentfiles WHERE ContentID='$($ID.ContentID)'" @WMIQueryParameters
            [pscustomobject]@{Source = $contentFile.SourceURL ;
                Destination = "$downloadpath\$($id.ContentID)\$($contentFile.FileName)";
            }
        }
    }

    ForEach ($Download in $DownloadInfo) {
        If (-not (test-path -Path "filesystem::$(Split-Path -Path $Download.Destination)")) {
            New-Item -ItemType directory -Path "$(Split-Path -Path $Download.Destination)" | Out-Null
        }
    }
    $DownloadInfo | Start-BitsTransfer

    Set-UpdateDeploymentPackage $SUG $UpdateList
    $DownloadInfo.destination |    ForEach-Object -Process {
        if (Test-Path (Split-Path -path $_)) {Remove-Item -Path (split-path -path $_) -Recurse -verbose}
    }
}#End Get-Updates

Function Set-UpdateDeploymentPackage {
    # This function creates and distributes the Deployment Package 
    Param    (
        [Parameter(Mandatory = $true)]
        [PSObject]$SUG,
        [Parameter(Mandatory = $true)]
        [Array]$UpdateList
    )

    #New-PSDrive -Name M -PSProvider FileSystem -Root "$($SUG.PkgSourcePath)"
    #$PKGPath = "M:\"
    $PKGPath = $SUG.PkgSourcePath
    [String[]]$contentsourcepath = Get-ChildItem -path $PKGPath | select -ExpandProperty Fullname | Where-Object {$_ -match '.*\\+[0-9]*\\?$'}
    [Int32[]]$allContentIDs = $contentsourcepath | foreach {Split-Path  -Path $_ -Leaf}
    $SUG.AddUpdateContent($allContentIDs, $contentsourcepath, $true) | Out-Null
    #$DPGroup.AddPackages($SUG.PackageID)
} #End Set-UpdateDeploymentPacakge

Function Get-CMNSoftwareUpdateInfo {
    PARAM    (
        [Parameter(Mandatory = $true)]
        [String]$CI_ID
    )
    $Query = "Select ContentID,ContentUniqueID,ContentLocales from SMS_CITOContent Where CI_ID='$CI_ID'"
    $SoftwareUpdateContentInfo = Get-WmiObject -Query $Query @WMIQueryParameters
    $ContentIDs = ""
    foreach ($ContentID in ($SoftwareUpdateContentInfo.ContentID)) {
        if ($ContentIDs.Length -lt 1) {$ContentIDs = $ContentID}
        Else {$ContentIDs = "$ContentID,$ContentIDs"}
    }
    $Query = "Select FileName,SourceURL from SMS_CIContentfiles WHERE ContentID in ($ContentIDs)"
    $SoftwareDownloadInfo = Get-WmiObject -Query $Query @WMIQueryParameters
    $Query = "Select PackageID from SMS_CIToContent JOIN SMS_PackageToContent on SMS_CIToContent.ContentID = SMS_PackageToContent.ContentID Where SMS_CIToContent.CI_ID = '$($Update.CI_ID)'"
    $SoftwarePackageInfo = (Get-WmiObject -Query $Query @WMIQueryParameters).PackageID
    $ReturnHashTable = @{
        CI_ID = $CI_ID;
        ContentID = ($SoftwareUpdateContentInfo.ContentID);
        ContentUniqueID = ($SoftwareUpdateContentInfo.ContentUniqueID);
        CurrentLocales = ($SoftwareUpdateContentInfo.CurrentLocales);
        FileName = ($SoftwareDownloadInfo.FileName);
        SourceURL = ($SoftwareDownloadInfo.SourceURL);
        PackageID = [Array]$SoftwarePackageInfo;
    }

    $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
    $obj.PSObject.TypeNames.Insert(0, 'CMN.SoftwareUpdateInfo')
    Return $obj
}

# Determine SiteCode from WMI
try {
    Write-Verbose "Determining SiteCode for Site Server: '$($SiteServer)'"
    $SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $SiteServer
}

catch [Exception] {
    Throw "Unable to determine SiteCode"
}

#Ensure PackageSourcePath has traling \, if not add it.
if ($PackageSourcePath -match '\\$') {$PackageSourcePath = "$PackageSourcePath$($SCCMConnectionInfo.SiteCode)\"}
else {$PackageSourcePath = "$PackageSourcePath\$($SCCMConnectionInfo.SiteCode)\"}

Write-Verbose "Package Source = $PackageSourcePath"
#Test for PackageSourcePath
if (-not (Test-Path $PackageSourcePath)) {
    Throw "Unknown Path - $PackageSourcePath"
}

#Test for DP Group
$WMIDPGroupName = Convertto-cmnwmisinglequotedstring $DPGroupName
$DPGroup = Get-WmiObject -Class SMS_DistributionPointGroup -Filter "name = '$WMIDPGroupName'" @WMIQueryParameters
if (-not $DPGroup) {
    Throw "Unknown Distribution Point Group - $DPGroup"
}

#Define Variables
$PackageContentToClean = @{} #(Key = PackageID) for extras
$PackageContentToDownload = @{} #(Key = PackageID) for new downloads

#Get Updates needed
Write-Verbose 'Getting Updates... This could take a minute'
$Updates = Get-WmiObject -Class SMS_SoftwareUpdate @WMIQueryParameters
$ProgressCount = 0
$UpdatesCount = $Updates.Count
$PackagesToRefresh = @{}
$PackagesWithNewDownlaods = @{}
#Cycle through each update 
ForEach ($Update in $Updates) {
    #Write Progress
    $ProgressCount++
    if ($ShowProgress) {Write-Progress -Activity 'Processing Software Updates' -Status "$($Update.LocalizedDisplayName)" -CurrentOperation "$($ProgressCount) / $($UpdatesCount)" -PercentComplete (($ProgressCount / $UpdatesCount) * 100)}

    if ($Update.IsContentProvisioned -or $Update.IsDeployed -or $Update.NumMissing -gt 1) {} #Do we need to process? 
    #Get Update Classification for Package Name
    $UpdateClassification = ''
    $Classification = $Update.CategoryInstance_UniqueIDs | Where-Object {$_ -match 'UpdateClassification'}
    $UpdateClassification = (Get-WmiObject -Class SMS_CIAllCategories -Filter "CategoryInstance_UniqueID = '$Classification' and CI_ID = '$($Update.CI_ID)'" @WMIQueryParameters).LocalizedCategoryInstanceName
    if ($UpdateClassification -eq '' -or $UpdateClassification -eq $null) {
        Write-Verbose 'Unable to get classification'
    }
    #Get SUGPackageName
    $SUGPackage = "$UpdateClassification - $($Update.DateRevised.ToString().SubString(0,4))"
    If ($SUGPackage.Length -gt 0) {
        $Message = "KB$($Update.ArticleID)`tPackage - $SUGPackage`tIsDeployed ["
        if ($Update.IsDeployed) {$Message += "x]`tRequired [$($Update.NumMissing)]`tExpired ["}
        else {$Message += " ]`tRequired = $($Update.NumMissing)`tExpired ["}
        if ($Update.IsExpired) {$Message += "x]"}
        else {$Message += " ]"}
        Write-Verbose $Message
        $PatchPackage = Get-WmiObject -Class SMS_SoftwareUpdatesPackage -Filter "Name = '$SUGPackage'" @WMIQueryParameters
        if (-not ($PatchPackage)) {
            #Doesn't exist, create 
            $PatchPackage = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_SoftwareUpdatesPackage").CreateInstance()
            $PatchPackage.Name = $SUGPackage
            $PatchPackage.PackageType = 5
            $PatchPackage.PkgSourceFlag = 2
            $PatchPackage.PkgSourcePath = "$PackageSourcePath$SUGPackage"
            $PatchPackage.Put() | Out-Null
            $PatchPackage.Get()
            $DPGroup.AddPackages($PatchPackage.PackageID) | Out-Null
        }
        if (-not (Test-Path -Path ($PatchPackage.PkgSourcePath))) {
            #Make sure the home directory exists 
            New-Item -Path ($PatchPackage.PkgSourcePath) -ItemType Directory | Out-Null
        }
        #$SoftwareUpdate = get-CMNSoftwareUpdateInfo ($Update.CI_ID)
        #Get PackageID's where the update is downloaded to
        $Query = "Select PackageID`
                        from SMS_CIToContent JOIN SMS_PackageToContent`
                        on SMS_CIToContent.ContentID = SMS_PackageToContent.ContentID`
                        Where SMS_CIToContent.CI_ID = '$($Update.CI_ID)'"
        $PackageIDs = (Get-WmiObject -Query $Query @WMIQueryParameters).PackageID | Sort-Object -Unique
        if (-not $PackageIDs) {
            Write-Verbose "`tUpdate not provisioned, need to download"
            $PackageContentToDownload[$PatchPackage.PackageID] += [Array]$Update.CI_ID
        }
        $ContentID = (Get-WmiObject -Class SMS_CIToContent -Filter "CI_ID = '$($Update.CI_ID)'" @WMIQueryParameters).ContentID
        $IsProvisioned = $false
        if ($update.IsContentProvisioned) {
            foreach ($PackageID in $PackageIDs) {
                if (($PatchPackage.PackageID -eq $PackageID) -and $Update.IsDeployed -and $Update.NumMissing -gt 0 -and (!$Update.IsExpired)) {
                Write-Verbose "`tUpdate is Provisioned"
                $IsProvisioned = $true
            }
            else {
                #Add ContentID to hash - PackageContentToClean (Key = PackageID) for extras
                Write-Verbose "`tNeeds to be removed from $PackageID"
                $PackageContentToClean[$PackageID] += [Array]$ContentID
            }
        }
    }
    if (-not $IsProvisioned) {
        #Add CI_ID to hash - PackageContentToDownload (Key = PackageID) for new downloads
        Write-Verbose "`tNeed to download $($Update.LocalizedDisplayName) to $($PatchPackage.Name)"
        $PackageContentToDownload[($PatchPackage.PackageID)] += [Array]($Update.CI_ID)
    }
}
Else {
    Write-Verbose "Unable to process Update $($Update.CI_ID) - Classification $UpdateClassification"
}
}#End Do we need to process?
} #End Cycle through each update

#Check to see if

#Download updates
if ($ShowProgress) {Write-Progress -Activity 'Processing Software Updates' -Completed}
$PackageCount = 1
foreach ($PackageToDownload in $PackageContentToDownload.GetEnumerator()) {
    if ($ShowProgress) {Write-Progress -Activity 'Download Software Updates' -Status "Working on $($PackageToDownload.Name)" -CurrentOperation "$PackageCount/$($PackageContentToDownload.Count)" -PercentComplete ($PackageCount / $PackageContentToDownload.Count * 100)}
    $PackageCount++
    $SUG = Get-WmiObject -Class SMS_SoftwareUpdatesPackage -Filter "PackageID = '$($PackageToDownload.Name)'" @WMIQueryParameters
    Get-Updates -SUG $SUG -UpdateList $($PackageToDownload.Value)
}
if ($ShowProgress) {Write-Progress -Activity 'Download Software Updates' -Completed}

#Clean existing packages
$PackageCount = 1
foreach ($PackageID in $PackageContentToClean.GetEnumerator()) {
    $PatchPackage = Get-WmiObject -Class SMS_SoftwareUpdatesPackage -Filter "PackageID = '$($PackageID.Name)'" @WMIQueryParameters
    if ($PatchPackage) {
        if ($ShowProgress) {Write-Progress -Activity 'Clean Software Updates' -Status "Working on $($PatchPackage.Name)" -CurrentOperation "$PackageCount/$($PackageContentToClean.Count)" -PercentComplete ($PackageCount / $PackageContentToClean.Count * 100)}
        $PackageCount++
        Write-Verbose "Removing $($Update.LocalizedDisplayName) from $($PatchPackage.Name)"
        $PatchPackage.RemoveContent($PackageID.Value, $true) | Out-Null
        #(Remove if empty) Updating DP's as removed
        if ((Get-WmiObject -Class SMS_PackageToContent -Filter "PackageID = '$($PatchPackage.Name)'" @WMIQueryParameters | Measure-Object).Count -eq 0) {
            Write-Verbose "Removing $($PackageID.Value)"
            if (Test-Path $PatchPackage.PkgSourcePath) {Remove-Item -Path ($PatchPackage.PkgSourcePath) -Recurse -Verbose}
            $PatchPackage | Remove-WmiObject | Out-Null
        }
    }
    else {
        Write-Verbose "*********Unable to retrieve $($PackageID.Name)"
    }
}
if ($ShowProgress) {Write-Progress -Activity 'Clean Software Updates' -Completed}