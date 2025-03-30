$IntDescription = (netsh wlan show int | Select-String 'Description')
$WLANInt = $IntDescription.ToString().Split(':')[1].Trim()

Get-Childitem 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}' -ErrorAction SilentlyContinue |
ForEach-Object {
    $IntProperties = Get-ItemProperty ($psitem.Name).Replace('HKEY_LOCAL_MACHINE','HKLM:') -ErrorAction SilentlyContinue
    if ($IntProperties.DriverDesc -eq $WLANInt) {
        if ($IntProperties.RoamingPreferredBandType -ne 2) {
            Set-ItemProperty -Path ($psitem.Name).Replace('HKEY_LOCAL_MACHINE','HKLM:') -Name RoamingPreferredBandType -Value 2
        }
    }
}