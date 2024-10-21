param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({test-path $_})]
    $CertificatePath,
    [Parameter(Mandatory=$true)]
    $CertificatePassword,
    [Parameter(Mandatory=$true)]
    [ValidateScript({test-path $_})]
    $ScriptToSign
)

$Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertificatePath, $CertificatePassword)
Set-AuthenticodeSignature -Certificate $Cert -FilePath $ScriptToSign