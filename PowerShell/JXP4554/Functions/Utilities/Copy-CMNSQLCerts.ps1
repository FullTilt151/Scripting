$SQLServers = ('LOUSQLWTS553','LOUSQLWQS534','LOUSQLWQS535','LOUSQLWPS618','LOUSQLWPS606')

foreach($SQLServer in $SQLServers)
{
    $SourceStoreScope = "\\$SQLServer\My"
    $SourceStorename = 'LocalMachine\'

    $SourceStore = New-Object  -TypeName System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList $SourceStorename, $SourceStoreScope
    $SourceStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

    $cert = $SourceStore.Certificates | Where-Object  -FilterScript {
        $_.subject -like '*Cloudapp.net'
    }


    <#
    $DestStoreScope = 'LocalMachine'
    $DestStoreName = 'root'

    $DestStore = New-Object  -TypeName System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList $DestStoreName, $DestStoreScope
    $DestStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $DestStore.Add($cert)
    #>

    $SourceStore.Close()
    #$DestStore.Close()
}