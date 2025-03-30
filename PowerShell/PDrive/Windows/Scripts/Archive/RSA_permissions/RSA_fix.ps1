$domainuser = (Get-WmiObject win32_computersystem | Select-Object username).username
write-host "User:"$domainuser
$user = $domainuser.Substring(6,($domainuser.length-6))
$path = (get-childitem C:\users\$user\AppData\Roaming\Microsoft\Crypto\RSA).FullName
write-host "Path:"$path

icacls.exe $path /grant ''$user':(OI)(CI)F'
icacls.exe $path /grant 'BUILTIN\Administrators:(OI)(CI)F'
icacls.exe $path /grant 'NT AUTHORITY\SYSTEM:(OI)(CI)F'