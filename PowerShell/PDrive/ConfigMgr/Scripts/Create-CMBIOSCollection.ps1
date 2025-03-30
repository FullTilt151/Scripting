param(
[Parameter(Mandatory=$true)][ValidateSet('WP1','WQ1')]
$SiteCode,
[Parameter(Mandatory=$true)]
$BIOSPrefix,
[Parameter(Mandatory=$true)]
$BIOSModels
)

Switch ($SiteCode) {
    'WP1' {$ProviderMachineName = "LOUAPPWPS1658.rsc.humad.com"; $LimitColl = 'WP10022C'}
    'WQ1' {$ProviderMachineName = "LOUAPPWQS1151.rsc.humad.com"; $LimitColl = 'WQ100030'}
}

if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
}

if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
}

Push-Location "$($SiteCode):\"

$CollName = "BIOS - $BIOSPrefix - $BIOSModels"

$Schedule = New-CMSchedule -Start '01/01/2000 8:00 AM' -RecurInterval Days -RecurCount 1
$Coll = New-CMDeviceCollection -Name $CollName -LimitingCollectionId $LimitColl -RefreshType Periodic -RefreshSchedule $Schedule

$CollQuery = "select *  from  SMS_R_System inner join SMS_G_System_PC_BIOS on SMS_G_System_PC_BIOS.ResourceId = SMS_R_System.ResourceId where SMS_G_System_PC_BIOS.SMBIOSBIOSVersion like `"$BIOSPrefix%`""

Add-CMDeviceCollectionQueryMembershipRule -Collection $Coll -RuleName $BIOSPrefix -QueryExpression $CollQuery

Move-CMObject -FolderPath 'DeviceCollection\DocCert Device Collections\Lenovo BIOS Patching' -InputObject $Coll

Pop-Location