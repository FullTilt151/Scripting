function Set-WSUSSigningCertificate {
    <#
    .SYNOPSIS
        Set the WSUS signing certificate
    .DESCRIPTION
        This function will let you set the WSUS signing certificate so that you can publish third party updates that
        need signed by the WSUS server.
    .PARAMETER ComputerName
        The Computer Name of the WSUS Server you want to set the signing certificate for
    .PARAMETER CertificatePath
        The full path to the certificate you want to use
    .PARAMETER CertificatePassword
        The password for the certificate file
    .EXAMPLE
        PS C:\> Set-WSUSSigningCertificate -ComputerName WSUS1 -CertificatePath 'c:\temp\WSUS_Signing_Cert.pfx' -CertificatePassword 'FakePassword123!'
        Sets the signing certificate for the remote WSUS server WSUS1
    .EXAMPLE
        PS C:\> Set-WSUSSigningCertificate -CertificatePath 'c:\temp\WSUS_Signing_Cert.pfx' -CertificatePassword 'FakePassword123!'
        Sets the signing certificate for the local computer
    .NOTES
        The certificate file specified must include the private key, which is why a password is required.
    #>
    param (
        [parameter(Mandatory = $false)]
        [string]$ComputerName = $env:COMPUTERNAME,
        [parameter(Mandatory = $True)]
        [ValidateScript( { Test-Path $_ -ErrorAction Stop })]
        [string]$CertificatePath,
        [parameter(Mandatory = $True)]
        [string]$CertificatePassword
    )
    $ComputerName = [system.net.dns]::GetHostByName($ComputerName).HostName
    $WSUS = @{ }
    $WSUS.ComputerName = $ComputerName
    $HKLM = 2147483650
    $WSUSConfigKeyPath = "SOFTWARE\Microsoft\Update Services\Server\Setup"
    $ConnectionProperties = @('PortNumber', 'UsingSSL')
    $WMI_Connection = Get-WmiObject -List "StdRegProv" -namespace root\default -ComputerName $WSUS['ComputerName'] -ErrorAction SilentlyContinue
    if ($WMI_Connection) {
        foreach ($Property in $ConnectionProperties) {
            $WSUS.$Property = ($WMI_Connection.GetDWORDValue($hklm, $WSUSConfigKeyPath, $Property)).uValue
        }
        $WSUS_Server = Get-WsusServer -Name $WSUS['ComputerName'] -UseSsl:$WSUS['UsingSSL'] -PortNumber $WSUS['PortNumber']
        $ServerConfig = $WSUS_Server.GetConfiguration()
        $ServerConfig.SetSigningCertificate($CertificatePath, $CertificatePassword)
        $ServerConfig.Save()
    }
}