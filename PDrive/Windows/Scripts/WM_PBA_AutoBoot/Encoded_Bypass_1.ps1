# This creates a unicode file with the command parameter
# You must replace the xxx with the real username and password
$Script = {
'SDUTIL /u /keyfile"xxx" /pwd"xxx" /c"8" /t"8" /Silent' | Out-File 'C:\Program Files\WinMagic\SecureDoc-NT\Bypass.ini' -encoding Unicode
}

# Convert the script variable to Base64
$Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Script))

# Write a text file with the command line output
'Powershell.exe -EncodedCommand ' + $Base64 | Out-File '.\Bypass_Step_1.txt'
