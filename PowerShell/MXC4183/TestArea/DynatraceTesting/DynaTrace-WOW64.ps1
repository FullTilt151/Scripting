$key = $false

if(Test-Path -path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Google\Chrome'){
    $key = $true
}else{
     New-Item -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Google\Chrome'
     }          

if(Test-Path -path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Google\Chrome\ExtensionInstallForcelist'){
    $key = $true
}else{
    New-Item -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Google\Chrome\ExtensionInstallForcelist'
    New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "1" -Value "fklgmciohehgadlafhljjhgdojfjihhk;https://clients2.google.com/service/update2/crx"
    New-ItemProperty -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -Name "2" -Value "fklgmciohehgadlafhljjhgdojfjihhk"
    }

if(Test-Path -Path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Google\Chrome\3rdparty'){
    $key= $true
}else{
    New-Item -path 'HKLM:\SOFTWARE\WOW6432Node\Policies\Google\Chrome\3rdparty'
    New-Item -path 'HKLM:\Software\WOW6432Node\Policies\Google\Chrome\3rdparty\extensions'
    New-Item -path 'HKLM:\Software\WOW6432Node\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk'
    New-Item -path 'HKLM:\Software\WOW6432Node\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy'
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -Name "adminMode" -PropertyType DWord -Value "0"
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -Name "fetchURL" -Value "https://cagf-dt.humana.com/e/d3610855-748f-4365-9bb1-f036451fac27/api/v1/browserextension/config?Api-Token=Ic_hfgeIQH-af8Ub9eKuV"
}
return $key

