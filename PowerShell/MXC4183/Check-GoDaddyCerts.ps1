
$GodaddyCertRoot = "47beabc922eae80e78783462a79f45c254fde68b" 
$GodaddyCertIntermediate = "27ac9369faf25207bb2627cefaccbe4ef9c319b8"
$needdownload = $false

$rootcerts = Get-ChildItem cert:\LocalMachine\Root | Where-Object {$_.Thumbprint -eq $GodaddyCertRoot}

if($rootcerts){
    $rootcerts | ForEach-Object{
        Write-Host "Trusted Root Cert found" -ForegroundColor Green
        Write-Host "-------------------------------"
        Write-Host "Thumbprint: $($PSItem.Thumbprint)"
        Write-Host "Subject: $($PSItem.Subject)"
        Write-Host "Issuer: $($PSItem.Issuer)"
        Write-Host "Start Date: $($PSItem.NotBefore)"
        Write-Host "Expiry Date: $($PSItem.NotAfter)"
        Write-Host "-------------------------------"
    }
}else{Write-Host "Root Go Daddy G2 cert not located in Trusted Root Certification Authorities store" -ForegroundColor Red; $needdownload = $true}

$intermediatecerts = Get-ChildItem cert:\LocalMachine\CA | Where-Object {$_.Thumbprint -eq $GodaddyCertIntermediate}

if($intermediatecerts){
    $intermediatecerts | ForEach-Object{
        Write-Host "Trusted Intermediate Root Cert found" -ForegroundColor Green
        Write-Host "-------------------------------"
        Write-Host "Thumbprint: $($PSItem.Thumbprint)"
        Write-Host "Subject: $($PSItem.Subject)"
        Write-Host "Issuer: $($PSItem.Issuer)"
        Write-Host "Start Date: $($PSItem.NotBefore)"
        Write-Host "Expiry Date: $($PSItem.NotAfter)"
        #Write-Host "DNS List: $($PSItem.DnsNameList.GetEnumerator())"
        Write-Host "-------------------------------"
    }
}else{Write-Host "Root Go Daddy Intermediate G2 cert not located in Intermediate Certification Authorities store" -ForegroundColor Red; $needdownload = $true}


if($needdownload){
    write-host ""
    write-host "Remediation:"
    write-host "1. Download the following cert bundle:"
    Write-Host "   https://certs.godaddy.com/repository/gd_bundle-g2.crt"
    write-host ""
    Write-Host "2. Run certlm.msc"
    write-host ""
    Write-Host "3. Right-click any Certificate store, choose All Tasks, Import."
    write-host ""
    Write-Host "4. Select the file you just downloaded."
    write-host ""
    Write-Host "5. [IMPORTANT!] For the Certificate Store selection, choose option `" Automatically select the certificate store based on the type of certificate`"."
    write-host ""
    write-host " 6. Click Finish."
}

