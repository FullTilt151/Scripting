$IntDescription = (netsh wlan show int | Select-String 'Description')
$WLANInt = $IntDescription.ToString().Split(':')[1].Trim()

Get-Childitem 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}' -ErrorAction SilentlyContinue |
ForEach-Object {
    $IntProperties = Get-ItemProperty ($psitem.Name).Replace('HKEY_LOCAL_MACHINE','HKLM:') -ErrorAction SilentlyContinue
    if ($IntProperties.DriverDesc -eq $WLANInt) {
        switch ($IntProperties.RoamingPreferredBandType) {
            0 {Write-Output 'No Preference'}
            1 {Write-Output 'Prefer 2.4GHz band'}
            2 {Write-Output 'Prefer 5.2GHz band'}
        }
    }
}