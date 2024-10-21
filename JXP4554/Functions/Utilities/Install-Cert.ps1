#http://www.orcsweb.com/blog/james/powershell-ing-on-windows-server-how-to-import-certificates-using-powershell/

function Import-PfxCertificate {

    param([String]$certPath,[String]$certRootStore = �LocalMachine�,[String]$certStore = �My�,$pfxPass = $null)
    $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2
 
    if ($pfxPass -eq $null) {$pfxPass = read-host �Enter the pfx password� -assecurestring}

    $pfx.import($certPath,$pfxPass,�Exportable,PersistKeySet�)
 
    $store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore)
    $store.open('MaxAllowed')
    $store.add($pfx)
    $store.close()
    }




function Import-509Certificate {

    param([String]$certPath,[String]$certRootStore,[String]$certStore)
 
    $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2
    $pfx.import($certPath)
 
    $store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore)
    $store.open('MaxAllowed')
    $store.add($pfx)
    $store.close()
    }
