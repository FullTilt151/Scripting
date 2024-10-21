# Detection Script for Chrome and Edge.
$ChromeInstalled = $false
$EdgeInstalled = $false
$Ckey = $false
$Ekey = $false

# Check for Chrome. 
if(test-path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'){
    $ChromeInstalled = $true 
}

# Check for Edge.
if(Get-AppxPackage -Name Microsoft.MicrosoftEdge){
    $EdgeInstalled = $true
}
# Adding a 2nd Edge detection method. Some users Shopped for it. Assuming that's why it's not .appx
if (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "Microsoft Edge"}){
    $EdgeInstalled = $true
}

# If Chrome is installed, check for keys, create if not found. Set keys variable for CI.
if($ChromeInstalled -eq $true){
    #Chrome installed, check for Extension keys.
    if(Test-Path -path 'HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist'){
        #EIF key present, check for values and set variables
        if(Get-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -name "1" -ErrorAction SilentlyContinue){
            $ExtListKey1 = Get-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "1"
            $Ckey = $true
        }else{
            New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "1" -Value "fklgmciohehgadlafhljjhgdojfjihhk;https://clients2.google.com/service/update2/crx"
        }

        if(Get-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -name "2" -ErrorAction SilentlyContinue){
            $ExtListKey2 = Get-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "2"
            $Ckey = $true
        }else{
            New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "2" -Value "fklgmciohehgadlafhljjhgdojfjihhk"

        }
    }else{
    New-Item -Path 'HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist'
    New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "1" -Value "fklgmciohehgadlafhljjhgdojfjihhk;https://clients2.google.com/service/update2/crx"
    New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "2" -Value "fklgmciohehgadlafhljjhgdojfjihhk"
    }

    #Ok, now check for 3rd party keys.
    if(Test-Path -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk'){
        #3rd party key present. Check values.
        if(Get-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "fetchUrl" -ErrorAction SilentlyContinue){
            $3ppkey1 = Get-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "fetchUrl"
            $Ckey = $true
        }else{
            New-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "fetchUrl" -value "https://cagf-dt.humana.com:443/e/d3610855-748f-4365-9bb1-f036451fac27/api/v1/browserextension/config?Api-Token=Ic_hfgeIQH-af8Ub9eKuV"
        }
        if(Get-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "adminmode"  -ErrorAction SilentlyContinue){
            $3ppkey2 = Get-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "adminmode" 
            $Ckey = $true
        }else{
            New-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "adminmode" -PropertyType DWORD -value "0"
        }
        
    }else{
        New-Item -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty'
        New-Item -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions'
        New-Item -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk'
        New-Item -path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy'
        New-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "fetchUrl" -value "https://cagf-dt.humana.com:443/e/d3610855-748f-4365-9bb1-f036451fac27/api/v1/browserextension/config?Api-Token=Ic_hfgeIQH-af8Ub9eKuV"
        New-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "adminmode" -PropertyType DWORD -value "0"

    }
}
# End Chrome section.

# Edge installed. Check for keys, create if not found. Set keys variable for CI
if($EdgeInstalled -eq $true){
    # Check for Edge extension key. If present, check values.
   if(test-path -path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions'){
       # Extension key there, check values.
       if(Get-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli' -name "update_url" -ErrorAction SilentlyContinue){
            $Eextkey = Get-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli' -name "update_url"
            $Ekey = $true      
        }else{  
            New-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli' -Name "update_url" -Value "https://edge.microsoft.com/extensionwebstorebase/v1/crx"
        }      
    }else{
        New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge'
        New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions'
        New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli'
        New-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\mpioohaaamocbdblijfoeigkkadcekli' -name "update_url" -Value "https://edge.microsoft.com/extensionwebstorebase/v1/crx"
    }
    # Ok now, just like Chrome, setup the 3rd party keys for Edge.
    if(Test-Path -path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli'){
        #3rd party key present. Check values.
        if(Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "fetchUrl" -ErrorAction SilentlyContinue){
            $E3ppkey1 = Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Edge\3rdparty\extensions\mpioohaaamocbdblijfoeigkkadcekli\policy' -name "fetchUrl"
            $Ekey = $true
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

}  
# End Edge section