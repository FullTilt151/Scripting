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

$plainText = "Some Super Secret Password"
$key = Set-Key "AGoodKeyThatNoOneElseWillKnow"
$encryptedTextThatIcouldSaveToFile = Set-EncryptedData -key $key -plainText $plaintext
$encryptedTextThatIcouldSaveToFile | out-file e:\test.txt

$pw = get-content \\wkmjxzhnb\shared\test.txt
$DecryptedText = Get-EncryptedData -data $pw -key $key
$DecryptedText