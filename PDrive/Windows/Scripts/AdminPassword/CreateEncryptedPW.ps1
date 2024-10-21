function Set-Key {
    param([string]$string)
    $length = $string.length
    $pad = 32-$length
    if (($length -lt 16) -or ($length -gt 32)) {Throw "String must be between 16 and 32 characters"}
    $encoding = New-Object System.Text.ASCIIEncoding
    $bytes = $encoding.GetBytes($string + "0" * $pad)
    return $bytes
}
function Set-EncryptedData {
    param($key,[string]$plainText)
    $securestring = new-object System.Security.SecureString
    $chars = $plainText.toCharArray()
    foreach ($char in $chars) {$secureString.AppendChar($char)}
    $encryptedData = ConvertFrom-SecureString -SecureString $secureString -Key $key
    return $encryptedData
}
function Get-EncryptedData {
    param($key,$data)
    $data | ConvertTo-SecureString -key $key |
    ForEach-Object {[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_))}
}

# Generate Key and send to key.file
$key = 1..32 | ForEach-Object { Get-Random -Maximum 256 } 
$key -join "," >>c:\temp\key.file

# Generate encrypted PW and send to key.file
$PlainText = Read-Host "Please enter a Password: "
Write-Host "You entered "$PlainText
$EncryptTxt = Set-EncryptedData -key $key -plainText $PlainText
$EncryptTxt >> C:\temp\key.file
Write-Host "Your EncryptedString is: " $EncryptTxt

#verify key/encryption
$DecryptedText = Get-EncryptedData -data $EncryptTxt -key $key
    if ($DecryptedText -eq $PlainText){ 
    write-host "Match"
    }
    else
    { 
    write-host "Nope. Try again"
}