# This script will create a front end for a user to create a key and encrypted password
# A file will be generated in the root of C: called Key.FILE. 
# This file will show the generated key and the encrypted password. Both are used in ChangePW.ps1 and CompareAdminPW.ps1

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
function Convert-PW{
    $EncryptTxt = Set-EncryptedData -key $key -plainText $PlainText
    $EncryptTxt >> c:\key.file
    [System.Windows.Forms.MessageBox]::Show("The Key and Encrypted Password have been created")
}

# Generate Key and send to key.file
$key = 1..32 | ForEach-Object { Get-Random -Maximum 256 } 
$key -join "," >>c:\key.file

# Generate encrypted PW and send to key.file
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  

$Form = New-Object System.Windows.Forms.Form
$Form.StartPosition = "CenterScreen"    
$Form.Size = New-Object System.Drawing.Size(250,200)
$Form.Text = "Encrypted Password Tool"  

# Start text fields
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(180,20) 
$objLabel.Text = "Please enter password:"
$Form.Controls.Add($objLabel) 

$PlainText = New-Object System.Windows.Forms.TextBox 
$PlainText.Location = New-Object System.Drawing.Size(50,50)
$PlainText.Size = New-Object System.Drawing.Size(150,20) 
$Form.Controls.Add($PlainText) 

# Start buttons

#OK button
$Button = New-Object System.Windows.Forms.Button 
$Button.Location = New-Object System.Drawing.Size(50,100) 
$Button.Size = New-Object System.Drawing.Size(50,35) 
$Button.Text = "OK" 
$Button.Add_Click({Convert-PW}) 
$Form.Controls.Add($Button) 

#Close button
$Button1 = New-Object System.Windows.Forms.Button
$Button1.Location = New-Object System.Drawing.Size(100,100)
$Button1.Size = New-Object System.Drawing.Size(50,35)
$Button1.Text = "Close"
$Button1.Add_Click({$Form.close()})
$Form.Controls.Add($Button1)


$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()