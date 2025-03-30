function Get-EncryptedData {
# Encrypt password
    param($key,$data)
    $data | ConvertTo-SecureString -key $key |
    ForEach-Object {[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_))}
}

$group =[ADSI]"WinNT://./Administrators" 
$members = @($group.psbase.Invoke("Members")) 
$admins = $members | foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
$key = (188,118,129,122,181,71,166,72,84,178,211,145,43,141,148,176,42,85,237,202,44,175,185,14,36,90,132,53,32,255,231,221)
$encryptedPW = "76492d1116743f0423413b16050a5345MgB8AHQAUwBhACsAbgBiADEAMABCAHMASwBFAHcAQgAvAFUANQB5AFAAeABjAFEAPQA9AHwAMQBjAGQAMgAzAGIAZQBkADYAZgBjADQAOAAxADAAYgBhADYAZQBlADQANQA0AGUAYwBkADkAOQA1ADgAMgAxADcANAA0AGMAMABjAGYANAA2ADcANQA1ADEANgBjADEAYgAzAGEAMgBjADEAZgA1ADgAZgA1AGIANgAwAGMAMwA=" 
$DecryptedText = Get-EncryptedData -data $encryptedPW -key $key


Add-Type -assemblyname system.DirectoryServices.accountmanagement 
$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
$DS.ValidateCredentials("Administrator", $DecryptedText.TrimStart("System.Windows.Forms.TextBox, Text: "))