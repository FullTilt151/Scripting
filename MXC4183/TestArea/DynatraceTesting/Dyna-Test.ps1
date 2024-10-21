
if(test-path -path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions'){
    # Extension key there, check values.
    if(Get-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli' -name "update_url" -ErrorAction SilentlyContinue){
        $Eextkey = Get-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli' -name "update_url"
    }else{  
        New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli'
        New-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli' -Name "update_url" -Value "https://clients2.google.com/service/update2/crx"
    }      
}else{
    New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge'
    New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions'
    New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli'
    New-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli' -name "update_url" -Value "https://clients2.google.com/service/update2/crx"
}

# Set Edge Extension Install Force (I copied this from Chrome)
if(Test-Path -path 'HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist'){
        #EIF key present, check for values and set variables
    if(Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -name "1" -ErrorAction SilentlyContinue){
        $ExtListKey1 = Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "1"
        $Ckey = $true
    }else{
        New-Item -Path 'HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist'
        New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "1" -Value "fklgmciohehgadlafhljjhgdojfjihhk;https://clients2.google.com/service/update2/crx"
    }
    if(Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -name "2" -ErrorAction SilentlyContinue){
        $ExtListKey2 = Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "2"
        $Ckey = $true
    }else{
        New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "2" -Value "fklgmciohehgadlafhljjhgdojfjihhk"

    }
}else{
    New-Item -Path 'HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist'
    New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "1" -Value "fklgmciohehgadlafhljjhgdojfjihhk;https://clients2.google.com/service/update2/crx"
    New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -Name "2" -Value "fklgmciohehgadlafhljjhgdojfjihhk"
    }


    # Ok now, just like Chrome, setup the 3rd party keys for Edge.
if(Test-Path -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli'){
    #3rd party key present. Check values.
    if(Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "fetchUrl" -ErrorAction SilentlyContinue){
        $E3ppkey1 = Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "fetchUrl"
    }else{
        New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "fetchUrl" -value "https://cagf-dt.humana.com:443/e/d3610855-748f-4365-9bb1-f036451fac27/api/v1/browserextension/config?Api-Token=Ic_hfgeIQH-af8Ub9eKuV"
        }

    if(Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "adminmode"  -ErrorAction SilentlyContinue){
        $E3ppkey2 = Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "adminmode" 
        $Ekey = $true
    }else{
        New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "adminmode" -PropertyType DWORD -value "0"
    }
        
}else{
    New-Item -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty'
    New-Item -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions'
    New-Item -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli'
    New-Item -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy'
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "fetchUrl" -value "https://cagf-dt.humana.com:443/e/d3610855-748f-4365-9bb1-f036451fac27/api/v1/browserextension/config?Api-Token=Ic_hfgeIQH-af8Ub9eKuV"
    New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "adminmode" -PropertyType DWORD -value "0"
    
}
# End Edge section