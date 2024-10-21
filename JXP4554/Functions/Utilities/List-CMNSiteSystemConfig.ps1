$sccmcon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1825
$siteSystems = Get-CMNSiteSystems -sccmConnectionInfo $sccmcon -role 'SMS Management Point'
foreach ($siteSystem in $siteSystems) {
    $ipAddress = ''
    $netConfig = Get-CimInstance -ComputerName $siteSystem -ClassName  Win32_NetworkAdapterConfiguration
    foreach ($adapter in $netConfig) {
        if ($adapter.ipAddress) {
            foreach ($ipAddr in $adapter) {
                $ipAddress += "ipAddress`t$($ipAddr.ipAddress)`r`nSubnet`t`t$($ipAddr.IPSubnet)`r`n"
            }
        }
    }
    $message =  "$SiteSystem`r`n$ipAddress"
    Write-Output $message
    $message | Out-File -FilePath c:\Temp\SiteSystems.txt -Append -Encoding ascii
}