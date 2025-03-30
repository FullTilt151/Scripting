param(
    [parameter(Mandatory = $true)]
    [string]$TaskSequenceID,
    [parameter(Mandatory = $true)]
    [int]$PilotNumber,
    [parameter(Mandatory = $true)][ValidatePattern('^(0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.](19|20)\d\d$')]
    [string]$DeployDay
    #[Parameter(Mandatory=$True)][ValidateSet('PM','VM')]
    #$ChassisType
)

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

$LOC = Get-Location | Select-Object -ExpandProperty Path
If ($LOC -ne 'WP1:\') {
    if ($PSVersionTable.PSEdition -ne 'Core') {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
    } else {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -SkipEditionCheck # Import the ConfigurationManager.psd1 module 
    }
    if (!(Test-Path WP1:)) {
        New-PSDrive -Name WP1 -PSProvider CMSite -Root LOUAPPWPS1658
    }
    Push-Location "WP1:" # Set the current location to be the site code.
}

$IncludeCollIDPM = 'WP10022C'
$IncludeCollIDVM = 'WP10002B'

[regex]$regex = '\d\d\w\d'
$TargetBuild = $regex.Matches($(Get-CMTaskSequence -TaskSequencePackageId $TaskSequenceID | Select-Object -ExpandProperty Name)).Value

# Gather collection info
$TargetsLimitingCollectionID = Get-CMCollection -Name "Win10 $TargetBuild Targets w/Agents current" | Select-Object -ExpandProperty CollectionID
$CollName = "$TargetBuild IPU Pilot $PilotNumber"

# Create Collections and add rules
$Coll1 = New-CMDeviceCollection -LimitingCollectionId $TargetsLimitingCollectionID -Name $CollName -RefreshType Manual
Move-CMObject -InputObject $Coll1 -FolderPath 'WP1:\DeviceCollection\CIS Device Collections\Windows 10\Servicing\Deployments'

$CollIDPM = New-CMDeviceCollection -LimitingCollectionId $Coll1.CollectionID -Name "$CollName - PM" -RefreshType Manual
Add-CMDeviceCollectionIncludeMembershipRule -CollectionId $CollIDPM.CollectionID -IncludeCollectionId $IncludeCollIDPM
Move-CMObject -InputObject $CollIDPM -FolderPath 'WP1:\DeviceCollection\CIS Device Collections\Windows 10\Servicing\Deployments'

$CollIDVM = New-CMDeviceCollection -LimitingCollectionId $Coll1.CollectionID -Name "$CollName - VM" -RefreshType Manual
Add-CMDeviceCollectionIncludeMembershipRule -CollectionId $CollIDVM.CollectionID -IncludeCollectionId $IncludeCollIDVM
Move-CMObject -InputObject $CollIDVM -FolderPath 'WP1:\DeviceCollection\CIS Device Collections\Windows 10\Servicing\Deployments'

$Availtime = (Get-Date $DeployDay -Hour 5 -Minute 0 -Second 0)
$StartTime = (Get-Date $DeployDay -Hour 2 -Minute 0 -Second 0).AddDays(1)
$ExpireTime = (Get-Date $DeployDay -Hour 8 -Minute 0 -Second 0).AddDays(1)
$AssignmentSchedule = New-CMSchedule -Nonrecurring -Start $StartTime -IsUtc
New-CMTaskSequenceDeployment -TaskSequencePackageId $TaskSequenceID -DeployPurpose Required -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $false -Availability Clients -RunFromSoftwareCenter $false -SystemRestart $true -SoftwareInstallation $true -DeploymentOption DownloadAllContentLocallyBeforeStartingTaskSequence -AllowSharedContent $true -AllowFallback $true -Collection $CollIDPM -Schedule $AssignmentSchedule -AvailableDateTime $Availtime -UseUtcForAvailableSchedule $true -DeadlineDateTime $ExpireTime -UseUtcForExpireSchedule $true -InternetOption $true
New-CMTaskSequenceDeployment -TaskSequencePackageId $TaskSequenceID -DeployPurpose Required -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $false -Availability Clients -RunFromSoftwareCenter $false -SystemRestart $true -SoftwareInstallation $true -DeploymentOption RunFromDistributionPoint -AllowSharedContent $true -AllowFallback $true -Collection $CollIDVM -Schedule $AssignmentSchedule -AvailableDateTime $Availtime -UseUtcForAvailableSchedule $true -DeadlineDateTime $ExpireTime -UseUtcForExpireSchedule $true -InternetOption $true

# Driver Update deployment
$DrvTaskSequenceID = 'WP1007BF'
$DrvAvailtime = (Get-Date $DeployDay -Hour 5 -Minute 0 -Second 0)
$DrvStartTime = (Get-Date $DeployDay -Hour 4 -Minute 0 -Second 0).AddDays(1)
$DrvExpireTime = (Get-Date $DeployDay -Hour 8 -Minute 0 -Second 0).AddDays(7)
$DrvAssignmentSchedule = New-CMSchedule -Nonrecurring -Start $DrvStartTime -IsUtc
New-CMTaskSequenceDeployment -TaskSequencePackageId $DrvTaskSequenceID -DeployPurpose Required -RerunBehavior AlwaysRerunProgram -ShowTaskSequenceProgress $false -Availability Clients -RunFromSoftwareCenter $false -SystemRestart $true -SoftwareInstallation $true -DeploymentOption DownloadAllContentLocallyBeforeStartingTaskSequence -AllowSharedContent $true -AllowFallback $true -Collection $CollIDPM -Schedule $DrvAssignmentSchedule -AvailableDateTime $DrvAvailtime -UseUtcForAvailableSchedule $true -DeadlineDateTime $DrvExpireTime -UseUtcForExpireSchedule $true -InternetOption $true

#Exclude VIP users collection WP10709D
Add-CMDeviceCollectionExcludeMembershipRule -CollectionName "$CollName" -ExcludeCollectionId 'WP10709D'

# Add WKIDs to Servicing collection
$WKIDS = Get-Content -Path $InputPath
ForEach ($WKID in $WKIDS) {
    Add-CMDeviceCollectionDirectMembershipRule -CollectionID $Coll1.CollectionID `
		-ResourceId $(Get-CMDevice -Name "$WKID").ResourceID
}

Pop-Location
Remove-Item -Path C:\temp\wkids.txt -ErrorAction SilentlyContinue