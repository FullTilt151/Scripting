# This script will compare the current password and if it is incorrect, will change the local admin password
# Set Password Version
$pwver = "0314a"

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
    $key = (207,221,213,162,66,222,167,84,70,138,43,243,7,252,12,9,59,56,4,193,102,230,237,215,105,101,190,46,126,56,192,151)
	# Put long encrypted text in this section
    $EncryptTxt = "76492d1116743f0423413b16050a5345MgB8AFcAcwBlAHYAOABtADYAQgArAG8AZgB2AEEAWgB1AHcAZQBGADEAQgBmAHcAPQA9AHwAYgAxADMAMgA4ADgAMgAzAGEANQBiADEAZAAyAGEAMAA5ADAANgA5ADYAYwBjADkANAA4ADQAZAAyAGEAYwBkADQAMgBlAGYAMgA3ADQAMABlADEANgAwAGQAYgA2AGMAMgAxAGQAYwA3ADYANwA0ADEAMwBkAGMAYQAxAGQAOQAzAGUAMQA5ADgANwA0AGIAMAA1ADEAYwBkADQAYgBiAGUAZAA4ADAAYwBiAGUAZQBhAGEAYQAyADYAZgAxAGQANQBhAGEANgA3ADMAOQA0ADcANgBjADAAMAAzAGIANABhAGMAMwAxADMAOQAwADgAMwA4ADQANQBmAGQAMwA0ADMAYwAwAGIAMgA4ADkAMwBiADkANQA0ADcAMAA1ADAAMQBiADcAMgA3ADQAMABmAGEANABhADIANQBhADcANgA3AGMAYgBkAGYAZQA0AGQAYgA5ADUANABmADkAMgA3AGMANgBiAGIAYwBmADkAMAA4ADUAZQAwADcANABkADYA"
    $DecryptedText = Get-EncryptedData -data $EncryptTxt -key $key
    $username = "administrator"
    $user = [ADSI]"WinNT://./$username"
    $user.SetPassword($DecryptedText.TrimStart("System.Windows.Forms.TextBox, Text: "))

}

#Check Password Version
if((get-itemproperty HKLM:\SOFTWARE\humana\PWD).$pwver -ne $null)
    {
     #write-host "Reg Key Found"
     EXIT
    }
    else
    {
    #Write-Host "No Reg Key Found"
    Change-PW
    }