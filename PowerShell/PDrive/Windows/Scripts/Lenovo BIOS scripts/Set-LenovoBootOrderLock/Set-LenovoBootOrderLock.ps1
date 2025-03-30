param(
[Parameter(Mandatory=$true)]
[ValidateSet('Enable','Disable')]
$Set
)
(Get-WmiObject -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting(“BootOrderLock,$Set”) | Out-Null
(Get-WmiObject -class Lenovo_SaveBiosSettings -namespace root\wmi).SaveBiosSettings() | Out-Null
Get-WmiObject -class Lenovo_BiosSetting –namespace root\wmi | Where-Object {$_.CurrentSetting -like 'BootOrderLock*'} | Select-Object -ExpandProperty CurrentSetting