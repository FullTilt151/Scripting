$regpath = "HKCU:\Software\Policies\Microsoft\Windows\Explor‌​er"
$Name = "DisableNotificationCenter"
$value = "1"
IF(!(Test-Path $regpath))
{
New-Item $regpath -Force | Out-Null
New-ItemProperty -Path $regpath -Name $Name -Value $value -PropertyType DWORD -Force | Out-Null }
ELSE {
New-ItemProperty -Path $regpath -Name $Name -Value $value -PropertyType DWORD -Force | Out-Null }