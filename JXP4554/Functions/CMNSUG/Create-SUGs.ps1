<#
.SYNOPSIS
    Creates software update groups

.DESCRIPTION
    Some variables need to be set first, they are:
    $Server - Server with SMS WMI Provider
    $DPGroupName - Name of DP Group to distribute Update Packages to
    $PackageSourcePath - UNC Path to source location for patches to be downloaded to
    $LogFile - File to hold the log

.EXAMPLE
    PS C:\> Create-SUGs

.NOTES
    Author:  James Parris
    Email:   Jim@ParrisFamily.com
    Date:    02/01/2015
    PSVer:   3.0
#>

$Server = 'LOUAPPWTS872'
$DPGroupName = "All DPs"
$PackageSourcePath = '\\louappwts872\f$\Source\Patches\'
$Logfile = "C:\Temp\Create-Sugs.log"
$MinUpdatesInstalled = 0

#Begin Functions

Function Set-SUG
#This function will create the SUG and add the CI's to it.
{
    Param
    (
    [Parameter(Mandatory = $true)]
    $SUG,
    [Parameter(Mandatory = $true)]
    $UpdateList
    )

    #prepare the Default Paramater Values to work with Get-WMIObject
    New-LogEntry "Beginning function" 1 "Set-SUG"
    $PSDefaultParameterValues =@{"get-wmiobject:namespace"="Root\SMS\site_$($Site)";"get-WMIObject:computername"=$Server}
 
    #Get a reference to the WMI Class SMS_CI_LocalizedProperties
    New-LogEntry "Getting reference class SMS_CI_LocalizedProperties" 1 "Set-SUG"
    $class = Get-WmiObject -Class SMS_CI_LocalizedProperties -list
 
    #instantiate the Class
    New-LogEntry "Preparing to create Software Update Group" 1 "Set-SUG"
    $LocalizedProperties = $class.CreateInstance()
 
    $LocalizedProperties.DisplayName=$SUG
    $LocalizedProperties.Description=$SUG
 

    $class = Get-WmiObject -Class SMS_AuthorizationList -list
    $UpdateGroup = $class.CreateInstance()
 
    $UpdateGroup.LocalizedInformation = $LocalizedProperties
    $UpdateGroup.Updates = $UpdateList -split ','
 
    $UpdateGroup.put()
    $UpdateGroup.get()
    New-LogEntry "Software Update Group $SUG has been created" 1 "Set-SUG"
}

Function Add-Update
# It first checks to see if the SUG exists (as a key), if it does, it appends the ID to the values
# otherwise, it creates the SUG and adds the value
{
    Param
    (
    [Parameter(Mandatory = $true)]
    $SUG,
    [Parameter(Mandatory = $true)]
    $UpdateID
    )

    New-LogEntry "Beginning function" 1 "Add-Update"
    if ($Global:SUGInfo.ContainsKey($SUG))
    {
        New-LogEntry "Appending Update to SUGinfo" 1 "Add-Update"
        $Temp = "$($Global:SUGInfo.Item($SUG)), $($UpdateID)"
        $Global:SUGInfo.Remove($SUG)
        $Global:SUGInfo.Add($SUG, $Temp)
    }
    else
    {
        New-LogEntry "Creating entry and adding update" 1 "Add-Update"
        $Global:SUGInfo.Add($SUG, $UpdateID) 
    }
}

Function Get-Updates 
# Downloads the updates to the PackageSourcePath location.
{
     Param
    (
    [Parameter(Mandatory = $true)]
    $SUG,
    [Parameter(Mandatory = $true)]
    $UpdateList
    )

   #Create a new PSDrive where the Patches will be downloaded
    New-LogEntry "Beginning function" 1 "Get-Updates"
    New-PSDrive -Name M -PSProvider FileSystem -Root "$PackageSourcePath"
    $downloadpath = "M:\$SUG"
    New-LogEntry "Making sure directory exists" 1 "Get-Updates"
    if (-not (Test-Path M:\$SUG)) 
    {
        New-Item -Path "M:\$SUG" -ItemType directory
    }

    New-LogEntry "Beginning download of updates" 1 "Get-Updates"
    $DownloadInfo = foreach ($CI_ID in ($UpdateList -split ','))
    {
        $contentID = Get-CimInstance -Query "Select ContentID,ContentUniqueID,ContentLocales from SMS_CITOContent Where CI_ID='$CI_ID'"  @hash
        #Filter out the English Local and ContentID's not targeted to a particular Language
        $contentID = $contentID  | Where {($_.ContentLocales -eq "Locale:9") -or ($_.ContentLocales -eq "Locale:0") }
 
        foreach ($id in $contentID)
        {
            $contentFile = Get-CimInstance -Query "Select FileName,SourceURL from SMS_CIContentfiles WHERE ContentID='$($ID.ContentID)'" @hash
            [pscustomobject]@{Source = $contentFile.SourceURL ;
                                Destination = "$downloadpath\$($id.ContentID)\$($contentFile.FileName)";
            }
        }
    }
 
    New-LogEntry "Test and create the Destination Folders if needed" 1 "Get-Updates"
    $DownloadInfo.destination |
        ForEach-Object -Process {
                If (! (test-path -Path "filesystem::$(Split-Path -Path $_)"))
                {
                    New-Item -ItemType directory -Path "$(Split-Path -Path $_)"
                }
            }
    New-LogEntry "Starting Download" 1 "Get-Updates"
    $DownloadInfo | Start-BitsTransfer

    New-LogEntry "Linking to package" 1 "Get-Updates"
    Set-UpdateDeploymentPackage $SUG $UpdateList
    New-LogEntry "final cleanup" 1 "Get-Updates"
    $DownloadInfo.destination |`
    ForEach-Object -Process `
    { 
        Remove-Item -Path (split-path -path $_) -Recurse -verbose
    }

}

Function Set-UpdateDeploymentPackage
# This function creates and distributes the Deployment Package
{
    Param
    (
    [Parameter(Mandatory = $true)]
    $SUG,
    [Parameter(Mandatory = $true)]
    $UpdateList
    )

    New-LogEntry "Beginning function" 1 "Set-UpdateDeploymentPackage"
    New-LogEntry "Get the Class" 1 "Set-UpdateDeploymentPackage"
    $class = Get-WmiObject -Class SMS_SoftwareUpdatesPackage -List -ComputerName $Server -Namespace root\SMS\Site_$($Site)

    $PKGPath = "$PackageSourcePath$SUG"
 
    New-LogEntry "Instantiate the Class Object" 1 "Set-UpdateDeploymentPackage"
    $DeployPackage = $class.CreateInstance()
 
    New-LogEntry "Set the appropriate properties on the Instance" 1 "Set-UpdateDeploymentPackage"
    $DeployPackage.Name = $SUG
    $DeployPackage.SourceSite = $Site
    $DeployPackage.PkgSourcePath = $PKGPath
    $DeployPackage.Description = "$SUG"
    $DeployPackage.PkgSourceFlag = [int32]2 #Value of 2 -->Stores Software Updates
 
    New-LogEntry "Persist the changes" 1 "Set-UpdateDeploymentPackage"
    $DeployPackage.put()
 
    New-LogEntry "Get the latest WMI Instance back" 1 "Set-UpdateDeploymentPackage"
    $DeployPackage.get()
    New-LogEntry "Get the Array of content source path" 1 "Set-UpdateDeploymentPackage"
    $contentsourcepath = Get-ChildItem  -path $PKGPath | select -ExpandProperty Fullname
 
    New-LogEntry "Get the array of ContentIDs" 1 "Set-UpdateDeploymentPackage"
    $allContentIDs =  $contentsourcepath | foreach {Split-Path  -Path $_ -Leaf}
    New-LogEntry "Call AddUpdateContent" 1 "Set-UpdateDeploymentPackage"
    $DeployPackage.AddUpdateContent($allContentIDs,$contentsourcepath,$true)
    $DPGroup = Get-WmiObject -Class SMS_DistributionPointGroup -Filter "name = '$DPGroupName'" -ComputerName $Server -Namespace root\SMS\Site_$($Site)
    $DPGroup.AddPackages($DeployPackage.PackageID)
}

Function New-LogEntry {
    # Writes to the log file
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [STRING] $Entry,
        
        [Parameter(Position=1,Mandatory=$true)]
        [INT32] $type,

        [Parameter(Position=2,Mandatory=$true)]
        [STRING] $component = 'Create-SUGs'
        )

        if ($Entry.Length -eq 0)
        {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Global:LogFile -Append -Encoding ascii
}

#Delcare Variables
New-LogEntry "Starting" 1 "Main"
$SUGNames = @()
$SUGUpdates = @()
$SUGInfo = @{}
$SUGs = @()
$Site = $(Get-WmiObject -ComputerName $Server -Namespace root\SMS -Class SMS_ProviderLocation).SiteCode
$hash = @{
    cimsession = New-CimSession -ComputerName $Server
    NameSpace = "Root\SMS\Site_$($Site)" 
    ErrorAction = 'Stop'
}

#Create hash tables for info
$query = "Select * from SMS_SoftwareUpdate"
New-LogEntry "Getting list of updates" 1 "Main"
$BulletinIDPatches  = Get-CimInstance -Query $query @hash

#Filter out not Applicable patches
New-LogEntry "Filtering out the ones don't have enough installs" 1 "Main"
$BulletinIDPatches = $BulletinIDPatches | where NumPresent -gt $MinUpdatesInstalled 

#Select Products you are targeting
New-LogEntry "Building and displaying list of products for selection" 1 "Main"
$productcategories = Get-CimInstance -ClassName SMS_UpdateCategoryInstance -Filter 'CategoryTypeName="Product"' @hash | Out-GridView -Title "Select the Products to target" -PassThru 

# will use a HashTable for filtering later
New-LogEntry "Creating Hash Table" 1 "Main"
$ProductIDHash = @{}

#create a Hash Table used to filter out later
$productcategories | ForEach-Object -Process {$ProductIDHash.Add("$($($_.CategoryInstance_UniqueID) -replace 'Product:')","$($_.LocalizedCategoryInstanceName)")}

$UpdateClassifications = Get-WmiObject -Class SMS_CategoryInstance -Filter 'CategoryTypeName = "UpdateClassification"' -ComputerName $Server -Namespace root\SMS\Site_$($Site)
$UpdateClassificationsIDHash = @{}
$UpdateClassifications | ForEach-Object -Process {$UpdateClassificationsIDHash.Add("$($($_.CategoryInstance_UniqueID) -replace 'UpdateClassification:')","$($_.LocalizedCategoryInstanceName)")}

#Filter out S/W updates which do not apply to the Products we want
New-LogEntry "Filtering out updates which do not apply to the prodcts we want" 1 "Main"
$DeployPatches = $BulletinIDPatches | `
ForEach-Object -Process `
{
    # Check if the Software Update is applicable to the list of Products we selected and doesn't target Itanium Architecture
    if ($ProductIDHash.Contains($([System.Xml.XmlDocument]$_.ApplicabilityCondition).ApplicabilityRule.ProductId) -and ( $_.LocalizedDisplayName -notlike "*Itanium*"))
    {
        # Adding a note property to the S/W update Object in Pipeline to know which product it applies to
        $_ | Add-Member -MemberType NoteProperty -Name AppliesTo -Value "$($ProductIDHash.$($([System.Xml.XmlDocument]$_.ApplicabilityCondition).ApplicabilityRule.ProductId))"
 
    Write-Output -InputObject $_
    }
}

#Define Hasn Table for SUGS consiting of UpdateID - SUG Name
New-LogEntry "Building SUGs hash table" 1 "Main"
foreach($DeployPatch in $DeployPatches) 
{
    $Year = $DeployPatch.DatePosted.Year
    $Month = $DeployPatch.DatePosted.Month
    $Product = $ProductIDHash.Item($([System.Xml.XmlDocument]$DeployPatch.ApplicabilityCondition).ApplicabilityRule.ProductId)
     foreach($ID in $DeployPatch.CategoryInstance_UniqueIDs) 
    {
        if ($ID -match 'UpdateClassification')
        {
            $UpdateClassification = $UpdateClassificationsIDHash.Item($ID -replace 'UpdateClassification:')
            if ($Year -eq $(Get-Date).Year) 
            {
                New-LogEntry "Adding $($DeployPatch.CI_ID) to $Year-$Month-$Product-$UpdateClassification" 1 "Main"
                Add-Update "$Product-$Year-$Month-$UpdateClassification" "$($DeployPatch.CI_ID)"
            }
            else 
            {
                New-LogEntry "Adding $($DeployPatch.CI_ID) to $Year-$Product-$UpdateClassification" 1 "Main"
                Add-Update "$Product-$Year-$UpdateClassification" "$($DeployPatch.CI_ID)"
            }
        }
    }
}

New-LogEntry "Beginning building of SUGs" 1 "Main"
$SUGInfo.Keys | `
% {
    Get-Updates $_ $SUGInfo.Item($_) 
    Set-SUG $_ $SUGInfo.Item($_)
}