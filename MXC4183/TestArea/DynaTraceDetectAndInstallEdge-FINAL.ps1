#Detect Dynatrace Extension for Edge
if(Test-Path -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy'){
    return $true
}elseif(Test-Path -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist'){
    return $true
}
else {
    return $false
}

# Set 3rdParty keys
if((Test-Path -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty') -ne $true){
    #do stuff
    New-Item -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty'
    New-Item -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions'
    New-Item -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli'
    New-Item -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy'
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "fetchUrl" -value "https://cagf-dt.humana.com:443/e/d3610855-748f-4365-9bb1-f036451fac27/api/v1/browserextension/config?Api-Token=Ic_hfgeIQH-af8Ub9eKuV"
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "adminmode" -PropertyType DWORD -value "0"

}elseif((Test-Path -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist') -ne $true){
    # do more stuff
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist'
    New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "1" -Value "mpioohaaamocbdblijfoeigkkadcekli;https://edge.microsoft.com/extensionwebstorebase/v1/crx"
    New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "2" -Value "mpioohaaamocbdblijfoeigkkadcekli"
}
else{
    return $true
}
    

