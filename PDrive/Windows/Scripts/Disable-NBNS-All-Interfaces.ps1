Get-ChildItem 'HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces' | 
ForEach-Object {
    $NBOptions = Get-ItemProperty -Path $_.Name.Replace('HKEY_LOCAL_MACHINE','HKLM:') -Name NetbiosOptions -ErrorAction SilentlyContinue
    "$($NBOptions.PSChildName) $($NBOptions.NetbiosOptions)"
    if (($NBOptions -eq $null) -or ($NBOptions.NetbiosOptions -ne 2)) {
        Set-ItemProperty -Path $_.Name.Replace('HKEY_LOCAL_MACHINE','HKLM:') -Name NetbiosOptions -Value 2 -Verbose
    }
}