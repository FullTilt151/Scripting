function Test-RegistryValue 
{

    param 
    (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Path,

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Name,

        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Value
    )

    try 
    {
        $Test = Get-ItemProperty -Path $Path $Name
        return $Test.$($Name) -eq $Value
    }

    catch 
    {
        return $false
    }

}

function Test-Cert
{
    Param
    (
        [Parameter(Mandatory=$true)]
        $CertPath,
        [Parameter(Mandatory=$true)]
        $ThumbPrint
    )
    try
    {
        $TestCert = Get-ChildItem -Path $CertPath | `
            Where-Object `
            {
                $_.Thumbprint -eq $ThumbPrint
            }
        return $ThumbPrint -eq $TestCert.Thumbprint
    }

    catch
    {
        return $false
    }
}

Test-RegistryValue HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate AcceptTrustedPublisherCerts 1
Test-Cert Cert:\LocalMachine\TrustedPublisher 5013F03C8342C2E929076534211EBFA9C58F4768