# This is an all in one solution to create the command file and execute it in one step
# You must replace the xxx with the real username and password

$Script = {
'SDUTIL /u /keyfile"dsipcadmin" /pwd"Rev1$edRe$olut1on" /c"10" /t"10" /Silent' | Out-File 'C:\Program Files\WinMagic\SecureDoc-NT\Bypass.ini' -encoding Unicode
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
'Powershell.exe -executionpolicy bypass -EncodedCommand ' + $Base64 | Out-File '.\Bypass_Endcoded.txt'
