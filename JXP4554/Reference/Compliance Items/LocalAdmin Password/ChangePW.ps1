# This script will compare the current password and if it is incorrect, will change the local admin password
# Set Password Version
$pwver = "0115"

function Set-Key {
# Establish the windows key that will be used to generate the encrypted password
    param([string]$string)
    $length = $string.length
    $pad = 32-$length
    if (($length -lt 16) -or ($length -gt 32)) {Throw "String must be between 16 and 32 characters"}
    $encoding = New-Object System.Text.ASCIIEncoding
    $bytes = $encoding.GetBytes($string + "0" * $pad)
    return $bytes
}
function Set-EncryptedData {
# Establish the encrypted password based on key
    param($key,[string]$plainText)
    $securestring = new-object System.Security.SecureString
    $chars = $plainText.toCharArray()
    foreach ($char in $chars) {$secureString.AppendChar($char)}
    $encryptedData = ConvertFrom-SecureString -SecureString $secureString -Key $key
    return $encryptedData
}
function Get-EncryptedData {
# Comparative step
    param($key,$data)
    $data | ConvertTo-SecureString -key $key |
    ForEach-Object {[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_))}
}
function Change-PW{
# change the Admin password if it's not correct
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $obj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine',$env:COMPUTERNAME)
	# Put previously generated key in this step
    $key = (188,118,129,122,181,71,166,72,84,178,211,145,43,141,148,176,42,85,237,202,44,175,185,14,36,90,132,53,32,255,231,221)
	# Put long encrypted text in this section
    $EncryptTxt = "76492d1116743f0423413b16050a5345MgB8AHQAUwBhACsAbgBiADEAMABCAHMASwBFAHcAQgAvAFUANQB5AFAAeABjAFEAPQA9AHwAMQBjAGQAMgAzAGIAZQBkADYAZgBjADQAOAAxADAAYgBhADYAZQBlADQANQA0AGUAYwBkADkAOQA1ADgAMgAxADcANAA0AGMAMABjAGYANAA2ADcANQA1ADEANgBjADEAYgAzAGEAMgBjADEAZgA1ADgAZgA1AGIANgAwAGMAMwA="
    $DecryptedText = Get-EncryptedData -data $EncryptTxt -key $key
    $username = "administrator"
    $user = [ADSI]"WinNT://./$username"
    $user.SetPassword($DecryptedText.TrimStart("System.Windows.Forms.TextBox, Text: "))

}


    Change-PW
