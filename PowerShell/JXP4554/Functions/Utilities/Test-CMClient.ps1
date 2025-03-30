param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('SP1','WP1')]
    $Environment = 'WP1'
)

if ($Environment -eq 'SP1') {
    $servers = ('grbappwps12.rsc.humad.com','louappwps1740.rsc.humad.com','louappwps1741.rsc.humad.com','louappwps1821.rsc.humad.com','louappwps1822.rsc.humad.com')
    $ips = ('32.32.55.31','10.113.32.64','10.113.32.65','10.97.32.22','10.97.32.23')
    $urls = ('http://32.32.55.31/sms_mp/.sms_aut?mplist','http://10.113.32.64/sms_mp/.sms_aut?mplist','http://10.113.32.65/sms_mp/.sms_aut?mplist','http://10.97.32.22/sms_mp/.sms_aut?mplist','http://10.97.32.23/sms_mp/.sms_aut?mplist')
    #$urls = ('http://grbappwps12.rsc.humad.com/sms_mp/.sms_aut?mplist','http://louappwps1740.rsc.humad.com/sms_mp/.sms_aut?mplist','http://louappwps1741.rsc.humad.com/sms_mp/.sms_aut?mplist','http://louappwps1821.rsc.humad.com/sms_mp/.sms_aut?mplist','http://louappwps1822.rsc.humad.com/sms_mp/.sms_aut?mplist')
} elseif ($Environment -eq 'WP1') {
    $servers = ('LOUAPPWPS1642.rsc.humad.com','LOUAPPWPS1643.rsc.humad.com','LOUAPPWPS1644.rsc.humad.com','LOUAPPWPS1645.rsc.humad.com','LOUAPPWPS1646.rsc.humad.com','LOUAPPWPS1647.rsc.humad.com','LOUAPPWPS1648.rsc.humad.com','LOUAPPWPS1649.rsc.humad.com','LOUAPPWPS1653.rsc.humad.com','LOUAPPWPS1654.rsc.humad.com','LOUAPPWPS1655.rsc.humad.com','LOUAPPWPS1656.rsc.humad.com','LOUAPPWPS1657.rsc.humad.com')
    $ips = ('133.27.20.196','133.27.20.197','133.27.20.254','133.27.15.11','133.27.15.28','133.27.15.30','133.27.15.61','133.27.15.62','133.27.7.18','133.27.7.37','133.27.7.65','133.27.7.72','133.27.7.75')
    $urls = ('http://133.27.20.196/sms_mp/.sms_aut?mplist','http://133.27.20.197/sms_mp/.sms_aut?mplist','http://133.27.20.254/sms_mp/.sms_aut?mplist','http://133.27.15.11/sms_mp/.sms_aut?mplist','http://133.27.15.28/sms_mp/.sms_aut?mplist','http://133.27.15.30/sms_mp/.sms_aut?mplist','http://133.27.15.61/sms_mp/.sms_aut?mplist','133.27.15.62/sms_mp/.sms_aut?mplist','http://133.27.7.18/sms_mp/.sms_aut?mplist','http://133.27.7.37/sms_mp/.sms_aut?mplist','http://133.27.7.65/sms_mp/.sms_aut?mplist','http://133.27.7.72/sms_mp/.sms_aut?mplist','http://133.27.7.75/sms_mp/.sms_aut?mplist')
}

$ports = ('80','443','8530','8531','10123')
Write-Output 'Noting IP addresses'
$ipAddress = ''
$DNSError = ''
$portError = ''
$URLError = ''

$netCfg = Get-WmiObject -Class Win32_NetworkAdapterConfiguration
Write-Output 'Noting OS'
$OS = (Get-WmiObject -Class Win32_OperatingSystem).Caption
$domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
foreach($adapter in $netCfg)
{
    if($adapter.IPaddress)
    {
        foreach($ipAddr in $adapter)
        {
            $ipAddress += "IPAddress`t$($ipAddr.IPAddress)`r`nSubnet`t`t$($ipAddr.IPSubnet)`r`n"
        }
    }
}

Write-Output 'Check to see if 10 route is added'
$query = "Select Destination from Win32_IP4RouteTable"
if ((Measure-Object -InputObject (Get-WmiObject -Query $query | Where-Object {$_.Destination -match '^10.'})).Count -gt 0){$hasRoute = $true}
else {$hasRoute = $false}


Write-Output 'Verify DNS Resolution'
$hasDNS = $true
for($x = 0 ; $x -lt $servers.Count; $x++)
{
    $lookup = [Net.DNS]::GetHostEntry($servers[$x]) 
    if($lookup.AddressList.IPAddressToString -ne $ips[$x])
    {
        $hasDNS = $false
        $DNSError += "Name Lookup for $($servers[$x]) is not returning $($ips[$x]), returns $($lookup.AddressList.IPAddressToString)`r`n"
    }
}

Write-Output 'Test Telnetting to each port'
$hasPort = $true
foreach($server in $servers)
{
    foreach($port in $ports)
    {
        $test = New-Object System.Net.Sockets.TcpClient;
        Try
        {
            $test.Connect($server, $port);
        }
        Catch
        {
            $hasPort = $false
            $portError += "Unable to use port $port on server $server`r`n"
        }
        Finally
        {
            $test.Dispose();
        }
    }
}

Write-Output 'Test MP urls'
$hasURL = $true
foreach($url in $urls)
{
    $webRequest = Invoke-WebRequest -Uri $url
    if($webRequest.StatusCode -ne 200)
    {
        $hasURL = $false
        $URLError += "Unable to access $url`r`n"
    }
}

$message = "----------------------------------------`r`n"
$message += "              Results`r`n"
$message += "----------------------------------------`r`n`r`n"
$message += "Name`t`t$($env:COMPUTERNAME)`r`n"
$message += "Domain`t`t$($domain)`r`n"
$message += "OS`t`t$OS`r`n"
$message += $ipAddress

if($hasRoute -or $hasURL){$message += "Route`t`tGood`r`n"}
else{$message += "System does not appear to have a route to get to the Site Systems, please verify`r`n"}

if($hasDNS){$message += "DNS`t`tGood`r`n"}
else{$message += $DNSError}

if($hasURL){$message += "MP URL's`tGood`r`n"}
else{$message += $URLError}

if($hasPort){$message += "Ports`t`tGood`r`n"}
else{$message += $portError}
Write-Output ''
$message
$message | Out-File -FilePath "C:\Temp\$($env:COMPUTERNAME).txt" -Encoding ascii