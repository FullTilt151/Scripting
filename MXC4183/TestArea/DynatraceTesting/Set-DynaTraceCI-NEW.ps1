#Set initial to false. Switch if found, etc.
$keys = $false

# Detect Edge install.
if (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "Microsoft Edge"}){
    # Now check if the keys exist. 
    if(Test-Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\fklgmciohehgadlafhljjhgdojfjihhk'){
        $keys = $True
    }else{
        New-Item -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge\' -name Extensions -Force
        New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions' -Name "fklgmciohehgadlafhljjhgdojfjihhk" -Force
        New-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\fklgmciohehgadlafhljjhgdojfjihhk' -Name "update_url" -Value "ttps://edge.microsoft.com/extensionwebstorebase/v1/crx"
    }
 }

# Detect Chrome install.
if (test-path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'){
    #Chrome installed. Check key.
    if(Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name adminMode -ErrorAction SilentlyContinue){
    $keys = $true
    }else{ 
        #Create and set the keys/entries for Google.
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\' -Name ExtensionInstallForceList -Force
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist' -Name "1" -Value "fklgmciohehgadlafhljjhgdojfjihhk;https://clients2.google.com/service/update2/crx"
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\' -Name 3rdParty -Force
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\3rdParty' -Name extensions -Force
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions' -Name fklgmciohehgadlafhljjhgdojfjihhk -Force
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk' -name policy -Force
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -Name "adminMode" -PropertyType DWord -Value "0"
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -Name "fetchURL" -Value "https://cagf-dt.humana.com/e/d3610855-748f-4365-9bb1-f036451fac27/api/v1/browserextension/config?Api-Token=Ic_hfgeIQH-af8Ub9eKuV"
        }    
}


return $keys

