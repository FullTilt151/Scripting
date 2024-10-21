$remediate = $false # Change to true for remediation script
$compliant = $false
# Populate your extensionGUID + Store URL here
# Chrome store: https://clients2.google.com/service/update2/crx
# Edge store: https://edge.microsoft.com/extensionwebstorebase/v1/crx
# $extensionGUID = 'hlnipadenlamgabofnnplfkdghpfnjeh;https://clients2.google.com/service/update2/crx'
$extensionGUID = 'fklgmciohehgadlafhljjhgdojfjihhk;https://clients2.google.com/service/update2/crx'
$Path = 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist'
$ErrorActionPreference = 'SilentlyContinue'

$CountOfProperties = (Get-Item -Path $Path -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property).Count # Get count of properties under key
$GUID = $false

if ($CountOfProperties -gt 0) { # If properties exist, parse them to see if GUID already exists
    $i = 1
    for ($i = 1 ; $i -le $CountOfProperties ; $i++){
        if ((Get-ItemProperty -Path $Path -Name $i -ErrorAction SilentlyContinue).$i -match $extensionGUID) {
            $GUID = $true # Found the GUID
        }
    }
}

$FetchUrlValue = "https://cagf-dt.humana.com:443/e/d3610855-748f-4365-9bb1-f036451fac27/api/v1/browserextension/config?Api-Token=Ic_hfgeIQH-af8Ub9eKuV"
$fetchUrl = (Get-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "fetchUrl").fetchurl

$AdminModeValue = (Get-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -name "adminmode").adminmode

if ($GUID -eq $true -and $FetchUrl -eq $FetchUrlValue -and $AdminModeValue -eq 0) { # If properties exist, parse them to see if GUID already exists
    $compliant = $true
} else { # Compliant = false if any of the 3 checks fail
    $compliant = $false
}

if ($remediate -eq $true -and $compliant -eq $false) {
    if ($GUID -ne $true) {
        if((Test-Path -Path $Path) -ne $true){
            New-Item -Path $Path -Force # Create reg key if missing
        }
        [int32]$TopNumber = (Get-Item -Path $Path -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property) | Sort-Object -Descending | Select-Object -First 1
        $NewItem = $TopNumber + 1 # Increment items under reg key
        New-ItemProperty -Path $Path -Name $NewItem -Value $extensionGUID # Add new entry for required extension
    }

    $PolicyPath = 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy'
    if((Test-Path $PolicyPath) -ne $true) {
        New-Item -Path $PolicyPath -Force
    }

    if ($FetchUrl -ne $FetchUrlValue) {
        New-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -Name 'fetchUrl' -Value $FetchUrlValue -Force
    }

    if ($AdminModeValue -ne 0) {
        New-ItemProperty -Path 'HKLM:\Software\Policies\Google\Chrome\3rdparty\extensions\fklgmciohehgadlafhljjhgdojfjihhk\policy' -Name 'adminmode' -Value 0 -Force
    }
} else {
    $compliant
}