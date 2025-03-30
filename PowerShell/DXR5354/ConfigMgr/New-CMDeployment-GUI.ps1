<# This form was created using POSHGUI.com  a free online gui designer for PowerShell
.NAME
    ConfigMgr Workstation Deployment Form
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$ConfigMgrDeploymentForm         = New-Object system.Windows.Forms.Form
$ConfigMgrDeploymentForm.ClientSize  = New-Object System.Drawing.Point(800,800)
$ConfigMgrDeploymentForm.text    = "Form"
$ConfigMgrDeploymentForm.TopMost  = $false

$TitleTextBox                    = New-Object system.Windows.Forms.Label
$TitleTextBox.text               = "Humana ConfigMgr Workstation Deployment Form"
$TitleTextBox.AutoSize           = $true
$TitleTextBox.width              = 25
$TitleTextBox.height             = 10
$TitleTextBox.location           = New-Object System.Drawing.Point(8,3)
$TitleTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',14)

$PackageTypeComboBox             = New-Object system.Windows.Forms.ComboBox
$PackageTypeComboBox.text        = "Select a type"
$PackageTypeComboBox.width       = 150
$PackageTypeComboBox.height      = 20
@('Package','Application','Task Sequence','Software Update','Baseline') | ForEach-Object {[void] $PackageTypeComboBox.Items.Add($_)}
$PackageTypeComboBox.location    = New-Object System.Drawing.Point(116,43)
$PackageTypeComboBox.Font        = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PackageTypeLabel                = New-Object system.Windows.Forms.Label
$PackageTypeLabel.text           = "Package Type"
$PackageTypeLabel.AutoSize       = $true
$PackageTypeLabel.width          = 25
$PackageTypeLabel.height         = 10
$PackageTypeLabel.location       = New-Object System.Drawing.Point(19,45)
$PackageTypeLabel.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PkgIDLabel                      = New-Object system.Windows.Forms.Label
$PkgIDLabel.text                 = "Package ID"
$PkgIDLabel.AutoSize             = $true
$PkgIDLabel.width                = 25
$PkgIDLabel.height               = 10
$PkgIDLabel.location             = New-Object System.Drawing.Point(12,99)
$PkgIDLabel.Font                 = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PkgIDTextBox                    = New-Object system.Windows.Forms.TextBox
$PkgIDTextBox.multiline          = $false
$PkgIDTextBox.width              = 85
$PkgIDTextBox.height             = 20
$PkgIDTextBox.location           = New-Object System.Drawing.Point(94,94)
$PkgIDTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 148
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(179,122)
$TextBox1.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ProgramLabel                    = New-Object system.Windows.Forms.Label
$ProgramLabel.text               = "Program/DeploymentType"
$ProgramLabel.AutoSize           = $true
$ProgramLabel.width              = 25
$ProgramLabel.height             = 10
$ProgramLabel.location           = New-Object System.Drawing.Point(13,125)
$ProgramLabel.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PurposeLabel                    = New-Object system.Windows.Forms.Label
$PurposeLabel.text               = "Purpose"
$PurposeLabel.AutoSize           = $true
$PurposeLabel.width              = 25
$PurposeLabel.height             = 10
$PurposeLabel.location           = New-Object System.Drawing.Point(15,151)
$PurposeLabel.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$PurposeComboBox                 = New-Object system.Windows.Forms.ComboBox
$PurposeComboBox.text            = "Select purpose"
$PurposeComboBox.width           = 100
$PurposeComboBox.height          = 20
@('Available','Required') | ForEach-Object {[void] $PurposeComboBox.Items.Add($_)}
$PurposeComboBox.location        = New-Object System.Drawing.Point(71,148)
$PurposeComboBox.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$SoftwareCenterLabel             = New-Object system.Windows.Forms.Label
$SoftwareCenterLabel.text        = "Run in software center"
$SoftwareCenterLabel.AutoSize    = $true
$SoftwareCenterLabel.width       = 25
$SoftwareCenterLabel.height      = 10
$SoftwareCenterLabel.location    = New-Object System.Drawing.Point(17,177)
$SoftwareCenterLabel.Font        = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$SoftwareCenterCheckBox          = New-Object system.Windows.Forms.CheckBox
$SoftwareCenterCheckBox.AutoSize  = $false
$SoftwareCenterCheckBox.width    = 95
$SoftwareCenterCheckBox.height   = 20
$SoftwareCenterCheckBox.location  = New-Object System.Drawing.Point(163,177)
$SoftwareCenterCheckBox.Font     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$MWLabel                         = New-Object system.Windows.Forms.Label
$MWLabel.text                    = "Maintenance Windows"
$MWLabel.AutoSize                = $true
$MWLabel.width                   = 25
$MWLabel.height                  = 10
$MWLabel.location                = New-Object System.Drawing.Point(235,175)
$MWLabel.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ConfigMgrDeploymentForm.controls.AddRange(@($TitleTextBox,$PackageTypeComboBox,$PackageTypeLabel,$PkgIDLabel,$PkgIDTextBox,$TextBox1,$ProgramLabel,$PurposeLabel,$PurposeComboBox,$SoftwareCenterLabel,$SoftwareCenterCheckBox,$MWLabel))

[void]$ConfigMgrDeploymentForm.ShowDialog()

# Site configuration
$SiteCode = "WP1" # Site code 
$ProviderMachineName = "LOUAPPWPS1658.rsc.humad.com" # SMS Provider machine name

# Import the ConfigurationManager.psd1 module 
if($null -eq (Get-Module ConfigurationManager)) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
}

# Connect to the site's drive if it is not already present
if($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\"

$PackageTypes = ('Package','Application','Task Sequence','Software Update','Baseline')

$PackageTypeChoice

switch ($PackageTypeChoice) {
    'Package' {
        $PkgPackageID = ''
        $PkgProgramName = ''
        $PkgPurpose = ''
        $PkgSoftwareCenter = ''
        $PkgMWSoftwareInstall = ''
        $PkgMWSystemRestart = ''
        $PkgSlowNetwork = ''
        $PkgFastNetwork = ''
        $PkgCollectionID = ''

        $StartTime = "T22:00:00"
        $StopTime = "T01:00:00"
        
        #Convert targeted Eastern time to local machine time
        $loctz = Get-TimeZone
        $esttz = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.Id -eq "US Eastern Standard Time" }
        $date_to_convert = ((Get-Date).ToString('yyyy-MM-dd'))
        $StartTime = [System.TimeZoneInfo]::ConvertTime("$date_to_convert$StartTime", $esttz, $loctz)
        $StopTime = [System.TimeZoneInfo]::ConvertTime("$date_to_convert$StopTime", $esttz, $loctz)

        $PkgAvailable = (Get-Date $DeployDay -Hour 5 -Minute 0 -Second 0)
        $PkgDeadline = (Get-Date $DeployDay -Hour 2 -Minute 0 -Second 0).AddDays(1)
        $PkgExpireTime = (Get-Date $DeployDay -Hour 8 -Minute 0 -Second 0).AddDays(1)
        $PkgSchedule = New-CMSchedule -Nonrecurring -Start $StartTime -IsUtc

        New-CMPackageDeployment -PackageId $PkgPackageID -ProgramName $PkgProgramName -DeployPurpose $PkgPurpose -SendWakeupPacket $true -UseUtcForAvailableSchedule $true -UseUtcForExpireSchedule $true -Schedule $PkgSchedule -SoftwareInstallation $PkgMWSoftwareInstall -SystemRestart $PkgMWSystemRestart -SlowNetworkOption $PkgSlowNetwork -FastNetworkOption $PkgFastNetwork  -AllowFallback $true -CollectionId $PkgCollectionID -AvailableDateTime $PkgAvailable -DeadlineDateTime $PkgDeadline
    }
    'Application' {}
    'Task Sequence' {}
    'Software Update' {}
    'Baseline' {}
} 