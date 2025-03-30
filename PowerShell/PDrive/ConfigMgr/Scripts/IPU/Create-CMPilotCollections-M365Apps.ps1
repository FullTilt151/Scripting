param(
    [parameter(Mandatory = $true)]
    [string]$ChangeNumber, # CHG0000000
    [parameter(Mandatory = $true)]
    [int]$PilotNumber, # 14, 15, 16, etc
    [parameter(Mandatory = $true)][ValidatePattern('^(0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.](19|20)\d\d$')]
    [string]$DeployDay, # 08/31/2021
    [switch]$CreateDeployment
)

# \\lounaswps08\pdrive\dept907.cit\configmgr\scripts\ipu\Create-CMPilotCollections-M365Apps.ps1 -ChangeNumber CHG1234567 -PilotNumber 14 -DeployDay 08/31/2021
# \\lounaswps08\pdrive\dept907.cit\configmgr\scripts\ipu\Create-CMPilotCollections-M365Apps.ps1 -ChangeNumber CHG1234567 -PilotNumber 14 -DeployDay 08/31/2021 -CreateDeployment

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

$LOC = Get-Location | Select-Object -ExpandProperty Path
If ($LOC -ne 'WP1:\') {
    if ($PSVersionTable.PSEdition -ne 'Core') {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module 
    } else {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -UseWindowsPowerShell # Import the ConfigurationManager.psd1 module 
    }
    if (!(Test-Path WP1:)) {
        New-PSDrive -Name WP1 -PSProvider CMSite -Root CMWPPSS.humad.com
    }
    Push-Location "WP1:" # Set the current location to be the site code.
}

# Get collections to include
$IncludeCollIDPM = 'WP10022C' # All Non-HGB Physical Workstations Limiting Collection
$IncludeCollIDVM = 'WP10002B' # All Non-HGB Virtual Workstations Limiting Collection

# Gather collection info
$TargetsLimitingCollectionID = Get-CMCollection -Name 'All Non-HGB Physical and Virtual Workstations Excluding Templates Limiting Collection' | Select-Object -ExpandProperty CollectionID # Change to M365A Not installed Collection
$CollName = "EUX_JHS0544A_CR66955_$($ChangeNumber)_Microsoft 365 Enterprise ProPlus 64bit With Skype_Pilot $PilotNumber"

# Create Collections and add rules
$Coll1 = New-CMDeviceCollection -LimitingCollectionId $TargetsLimitingCollectionID -Name $CollName -RefreshType Manual
Move-CMObject -InputObject $Coll1 -FolderPath 'WP1:\DeviceCollection\DocCert Device Collections\JHS0544\Microsoft 365 Enterprise & Titus Classification Suite'

$CollIDPM = New-CMDeviceCollection -LimitingCollectionId $Coll1.CollectionID -Name "$CollName - PM" -RefreshType Manual
Add-CMDeviceCollectionIncludeMembershipRule -CollectionId $CollIDPM.CollectionID -IncludeCollectionId $IncludeCollIDPM
Move-CMObject -InputObject $CollIDPM -FolderPath 'WP1:\DeviceCollection\DocCert Device Collections\JHS0544\Microsoft 365 Enterprise & Titus Classification Suite'

$CollIDVM = New-CMDeviceCollection -LimitingCollectionId $Coll1.CollectionID -Name "$CollName - VM" -RefreshType Manual
Add-CMDeviceCollectionIncludeMembershipRule -CollectionId $CollIDVM.CollectionID -IncludeCollectionId $IncludeCollIDVM
Move-CMObject -InputObject $CollIDVM -FolderPath 'WP1:\DeviceCollection\DocCert Device Collections\JHS0544\Microsoft 365 Enterprise & Titus Classification Suite'

if ($CreateDeployment) {
    $Availtime = (Get-Date $DeployDay -Hour 5 -Minute 0 -Second 0)
    $StartTime = (Get-Date $DeployDay -Hour 2 -Minute 0 -Second 0).AddDays(1)
    $ExpireTime = (Get-Date $DeployDay -Hour 10 -Minute 0 -Second 0).AddDays(1)
    $AssignmentSchedule = New-CMSchedule -Nonrecurring -Start $StartTime -IsUtc

    New-CMPackageDeployment -AllowFallback $true -AllowSharedContent $true -PersistOnWriteFilterDevice $false -DeployPurpose Required -FastNetworkOption DownloadContentFromDistributionPointAndRunLocally -PackageId 'WQ100D4E' -ProgramName 'HUMINST NIGHT' -StandardProgram -RerunBehavior RerunIfFailedPreviousAttempt -RunFromSoftwareCenter $true -SlowNetworkOption DownloadContentFromDistributionPointAndLocally -SendWakeupPacket $true -Collection $CollIDPM -AvailableDateTime $Availtime -UseUtcForAvailableSchedule $true -Schedule $AssignmentSchedule -DeadlineDateTime $ExpireTime -UseUtcForExpireSchedule $true
    New-CMPackageDeployment -AllowFallback $true -AllowSharedContent $true -PersistOnWriteFilterDevice $false -DeployPurpose Required -FastNetworkOption RunProgramFromDistributionPoint  -PackageId 'WQ100D4E' -ProgramName 'HUMINST NIGHT' -StandardProgram -RerunBehavior RerunIfFailedPreviousAttempt -RunFromSoftwareCenter $true -SlowNetworkOption RunProgramFromDistributionPoint -SoftwareInstallation $true -SystemRestart $true -Collection $CollIDVM -AvailableDateTime $Availtime -UseUtcForAvailableSchedule $true -Schedule $AssignmentSchedule -DeadlineDateTime $ExpireTime -UseUtcForExpireSchedule $true

    # Add WKIDs to Servicing collection
    $WKIDS = Get-Content -Path $InputPath
    ForEach ($WKID in $WKIDS) {
        Add-CMDeviceCollectionDirectMembershipRule -CollectionID $Coll1.CollectionID `
		    -ResourceId $(Get-CMDevice -Name "$WKID").ResourceID
    }
}

Pop-Location
Remove-Item -Path C:\temp\wkids.txt -ErrorAction SilentlyContinue