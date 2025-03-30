$regpath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$Name = "EnableBalloonTips"
$value = "0"
IF(!(Test-Path $regpath))
{
New-Item $regpath -Force | Out-Null
New-ItemProperty -Path $regpath -Name $Name -Value $value -PropertyType DWORD -Force | Out-Null }
ELSE {
New-ItemProperty -Path $regpath -Name $Name -Value $value -PropertyType DWORD -Force | Out-Null }