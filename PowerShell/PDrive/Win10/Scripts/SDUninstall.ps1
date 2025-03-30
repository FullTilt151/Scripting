Set-Service 'WinMagic SecureDoc Service' -StartupType Disabled
$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'SecureDoc Disk Encryption (x64) 7.1SR4'"
$app.Uninstall()