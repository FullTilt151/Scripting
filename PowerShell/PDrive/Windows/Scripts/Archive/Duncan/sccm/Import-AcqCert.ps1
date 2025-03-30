$pfxPass = 'tsam$01'

function Import-PfxCert {
 
 param([String]$certPath,[String]$certRootStore = "LocalMachine",[String]$certStore = "My",$pfxPass = $null)
 $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2

 if ($pfxPass -eq $null) {$pfxPass = read-host "Enter the pfx password" -assecurestring}
 
 #$pfx.import($certPath,$pfxPass,"Exportable,PersistKeySet")
 $pfx.import($certPath,$pfxPass,"MachineKeySet,PersistKeySet")
 Write-Host "Certificate Subject:$($pfx.Subject)"
 #Get-ChildItem cert:\$certRootStore\$certStore
 $certs = Get-ChildItem cert:\$certRootStore\$certStore
 $certCount = 0
 $certs | ForEach-Object{if($PSItem.Subject -eq $pfx.Subject){$certCount=1;}}
 if($certCount -eq 0){
    Write-Host "Certificate not found in store."
    Write-Host "Importing certificate..."
    
    $store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore)
    $store.open("MaxAllowed")
    $store.add($pfx)
    $store.close()
 } else {
    Write-Host "Certificate already exists in store with this subject."
 }
}

$pfxFilePath = $args[0]
if($pfxFilePath -like "-extract*"){
    $args[0] = ""
    exit
}
if(Test-Path $pfxFilePath){
    Import-PfxCert -certPath $pfxFilePath -pfxPass $pfxPass
} else {
    Write-Host "File $($pfxFilePath) dies not exist."
}
"Exiting"