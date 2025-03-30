$servers = ('grbappwps12.rsc.humad.com', 'louappwps1740.rsc.humad.com', 'louappwps1741.rsc.humad.com', 'louappwps1750.dmzad.hum', 'louappwps1821.rsc.humad.com', 'louappwps1822.rsc.humad.com')
$ips = ('32.32.55.31', '10.113.32.64', '10.113.32.65', '133.20.4.200', '10.97.32.22', '10.97.32.23')
$urls = ('http://32.32.55.31/sms_mp/.sms_aut?mplist', 'http://10.113.32.64/sms_mp/.sms_aut?mplist', 'http://10.113.32.65/sms_mp/.sms_aut?mplist', 'http://10.97.32.22/sms_mp/.sms_aut?mplist', 'http://10.97.32.23/sms_mp/.sms_aut?mplist')
#$urls = ('http://grbappwps12.rsc.humad.com/sms_mp/.sms_aut?mplist','http://louappwps1740.rsc.humad.com/sms_mp/.sms_aut?mplist','http://louappwps1741.rsc.humad.com/sms_mp/.sms_aut?mplist','http://louappwps1821.rsc.humad.com/sms_mp/.sms_aut?mplist','http://louappwps1822.rsc.humad.com/sms_mp/.sms_aut?mplist')
$ports = ('80', '443', '8530', '8531', '10123')
Write-Output 'Noting IP addresses'
$ipAddress = ''
$DNSError = ''
$portError = ''
$URLError = ''

$netCfg = Get-WmiObject -Class Win32_NetworkAdapterConfiguration
Write-Output 'Noting OS'
$OS = (Get-WmiObject -Class Win32_OperatingSystem).Caption
$domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
foreach ($adapter in $netCfg) {
    if ($adapter.IPaddress) {
        foreach ($ipAddr in $adapter) {
            $ipAddress += "IPAddress`t$($ipAddr.IPAddress)`tSubnet`t$($ipAddr.IPSubnet)`r`n"
        }
    }
}

Write-Output 'Check to see if 10 route is added'
$query = "Select Destination from Win32_IP4RouteTable"
if ((Measure-Object -InputObject (Get-WmiObject -Query $query | Where-Object { $_.Destination -match '^10.' })).Count -gt 0) { $hasRoute = $true }
else { $hasRoute = $false }


Write-Output 'Verify DNS Resolution'
$hasDNS = $true
for ($x = 0 ; $x -lt $servers.Count; $x++) {
    $lookup = [Net.DNS]::GetHostEntry($servers[$x]) 
    if ($lookup.AddressList.IPAddressToString -ne $ips[$x]) {
        $hasDNS = $false
        $DNSError += "Name Lookup for $($servers[$x]) is not returning $($ips[$x]), returns $($lookup.AddressList.IPAddressToString)`r`n"
    }
}

Write-Output 'Test Telnetting to each port'
$hasPort = $true
foreach ($server in $servers) {
    foreach ($port in $ports) {
        if (!(Test-NetConnection -ComputerName $server -Port $port).TcpTestSucceeded) {
            $hasPort = $false
            $portError += "Unable to use port $port on server $server`r`n"
        }
    }
}

Write-Output 'Test MP urls'
$hasURL = $true
foreach ($url in $urls) {
    $webRequest = Invoke-WebRequest -Uri $url
    if ($webRequest.StatusCode -ne 200) {
        $hasURL = $false
        $URLError += "Unable to access $url`r`n"
    }
}

Write-Output 'Verifying SMS Certs'
$hasBadCert = $false
#Make sure we don't have a bad cert
$smsCertTB = (Get-Content -Path 'C:\WINDOWS\SMSCFG.ini' -ErrorAction SilentlyContinue | Where-Object { $_ -match 'Certificate Identifier' }) -replace 'SMS Certificate Identifier=SMS;', ''
if ($smsCertTB) {
    $smsCert = (Get-ChildItem -Path Cert:\LocalMachine\SMS | Where-Object { $_.Thumbprint -eq $smsCertTB }).Subject
    if ($smsCert -notmatch $env:COMPUTERNAME -and $smsCert.Count -ne 0) {
        $hasBadCert = $true
        Get-ChildItem -Path Cert:\LocalMachine\SMS | Where-Object { $_.Thumbprint -eq $smsCertTB } | Remove-Item
        Restart-Service -Name CcmExec
    }
}

$message = "----------------------------------------`r`n"
$message += "              Results`r`n"
$message += "----------------------------------------`r`n`r`n"
$message += "Name`t`t$($env:COMPUTERNAME)`r`n"
$message += "Domain`t`t$($domain)`r`n"
$message += "OS`t`t$OS`r`n"
$message += $ipAddress

if ($hasRoute -or $hasURL) { $message += "Route`t`tGood`r`n" }
else { $message += "Server does not appear to have a route to get to the Site Systems, please verify`r`n" }

if ($hasDNS) { $message += "DNS`t`tGood`r`n" }
else { $message += $DNSError }

if ($hasURL) { $message += "MP URL's`tGood`r`n" }
else { $message += $URLError }

if ($hasPort) { $message += "Ports`t`tGood`r`n" }
else { $message += $portError }

if ($hasBadCert) { $message += 'There is a problem with the SCCM certificates in the LocalMachine\SMS folder' }
else {$message += 'SCCM Certificates appear good'}

Write-Output ''
$message
$filename = "C:\Temp\Test-$($env:COMPUTERNAME).txt"
$message | Out-File -FilePath $filename -Encoding ascii
Write-Output "`nPlease send a copy of the file $filename to ConfigMGRSupport@humana.com"