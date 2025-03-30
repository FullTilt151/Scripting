$remediate = $false # Change to true for remediation script
$compliant = $false
# Populate your extensionGUID + Store URL here
# Chrome store: https://clients2.google.com/service/update2/crx
# Edge store: https://edge.microsoft.com/extensionwebstorebase/v1/crx
# $extensionGUID = 'hlnipadenlamgabofnnplfkdghpfnjeh;https://clients2.google.com/service/update2/crx'
$extensionGUID = ''
$Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist'
$CountOfProperties = (Get-Item -Path $Path -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Property).Count # Get count of properties under key
if($CountOfProperties -eq 0) { # Compliant = false if no properties exist
    $compliant = $false
} elseif ($CountOfProperties -gt 0) { # If properties exist, parse them to see if GUID already exists
    $i = 1
    for ($i = 1 ; $i -le $CountOfProperties ; $i++){
        if ((Get-ItemProperty -Path $Path -Name $i).$i -match $extensionGUID) {
            $compliant = $true # Found the GUID, compliant = true
        }
    }
}
if($remediate -eq $true -and $compliant -eq $false) {
    if((Test-Path -Path $Path) -ne $true){
        New-Item -Path $Path -Force # Create reg key if missing
    }
    $NewItem = $CountOfProperties + 1 # Increment items under reg key
    New-ItemProperty -Path $Path -Name $NewItem -Value $extensionGUID | Out-Null # Add new entry for required extension
} else {
    $compliant
}