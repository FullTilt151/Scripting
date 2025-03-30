import-Module webadministration
$WSUSInfo = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Update Services\Server\Setup'
$limits = Get-ItemProperty -Path IIS:\Sites\'WSUS Administration' -Name limits
$cpu = Get-ItemProperty -Path IIS:\AppPools\Wsuspool -Name cpu 
$processModel = Get-ItemProperty -Path IIS:\AppPools\Wsuspool -Name processmodel.pingingEnabled
$queueLength = Get-ItemProperty -Path IIS:\AppPools\Wsuspool -name queueLength
$rapidFailProtection = Get-ItemProperty -Path IIS:\AppPools\Wsuspool -name failure
$recycling = Get-ItemProperty -Path IIS:\AppPools\Wsuspool -Name recycling.periodicRestart
$contentPath = Get-ItemProperty -Path 'IIS:\Sites\WSUS Administration\Content' -Name PhysicalPath.Value
$results = @{
    "WSUS.SQL Server"             = $WSUSInfo.SqlServerName;
    "WSUS.Content"                = $WSUSInfo.ContentDir;
    "Web.ContentPathValid"        = ($contentPath -match '^\\\\' -or $contentPath -match '\w:')
    "Web.ContentPath"             = $contentPath
    "Limits.MaxConnections"       = $limits.maxConnections;
    "Limits.MaxBandwidth"         = $limits.maxBandwidth;
    "Limits.ConnectionTimeout"    = $limits.connectionTimeout.ToString();
    "CPU.Action"                  = $cpu.action;
    "CPU.Limit"                   = ($cpu.limit / 1000);
    "CPU.ResetInterval"           = $cpu.resetInterval.ToString();
    "ProcessModel.PingingEnabled" = $processModel.Value;
    "QueuLength"                  = $queueLength.Value;
    "RapidFail.Enabled"           = $rapidFailProtection.rapidFailProtection;
    "RapidFail.Interval"          = $rapidFailProtection.rapidFailProtectionInterval.ToString();
    "RapidFail.MaxCrashes"        = $rapidFailProtection.rapidFailProtectionMaxCrashes;
    "RapidFail.Response"          = $rapidFailProtection.loadBalancerCapabilities;
    "Recycling.RestartTime"       = $recycling.time.ToString();
    "Recycling.Requests"          = $recycling.requests;
    "Recycling.PrivateMemory"     = $recycling.PrivateMemory;
}
$results | Out-GridView