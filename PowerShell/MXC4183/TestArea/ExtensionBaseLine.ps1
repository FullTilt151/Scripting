#Set initial to false. Switch if found, etc.
$keys = $false

# Detect Edge install.
if (Get-ItemProperty HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "Microsoft Edge"}){
    # Now check if the keys exist. 
    if(Test-Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\fklgmciohehgadlafhljjhgdojfjihhk'){
        $keys = $True
    }
 }

# Detect Chrome install.
if (Get-ItemProperty 'HKLM:\Software\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome'){
    #Chrome installed, check for keys.
    if(Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForceList' -name 1 -ErrorAction SilentlyContinue){
        #Check the key for the proper value.
        if(Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name adminMode -ErrorAction SilentlyContinue){
            $keys = $true
        }
    }
}
return $keys
