# This executes the bypass command and cleans up any traces of the files that might contain the password

$Script = {
if((Test-Path 'C:\Program Files\WinMagic\SecureDoc-NT\Bypass.ini') -and -not (Get-Process sdbat -ErrorAction Ignore)) {
& 'C:\Program Files\WinMagic\SecureDoc-NT\SDBat.exe' 'C:\Program Files\WinMagic\SecureDoc-NT\Bypass.ini' | Out-Null
Remove-Item -path 'C:\Program Files\WinMagic\SecureDoc-NT\Bypass.ini' -ErrorAction Ignore
Remove-Item -path 'C:\Program Files\WinMagic\SecureDoc-NT\Userdata\sdbat.log' -ErrorAction Ignore
Exit(0)} else {
Remove-Item -path 'C:\Program Files\WinMagic\SecureDoc-NT\Bypass.ini' -ErrorAction Ignore
Remove-Item -path 'C:\Program Files\WinMagic\SecureDoc-NT\Userdata\sdbat.log' -ErrorAction Ignore
EXIT(1)}
}

# Convert the script variable to Base64
$Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Script))

# Write a text file with the command line output
'Powershell.exe -EncodedCommand ' + $Base64 | Out-File '.\Bypass_Step_2.txt'
