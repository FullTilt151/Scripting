$sccmConInfo = Get-CMNSCCMConnectionInfo -siteServer $env:COMPUTERNAME
$sups = Get-CMNSiteSystems -sccmConnectionInfo $sccmConInfo -role 'SMS Software Update Point'
$params = New-Object System.Collections.ArrayList
foreach($sup in $sups){
    $path = "\\$sup\c$\Program Files\Update Services\LogFiles\SoftwareDistribution.log"
    $params.Add($path) | Out-Null
}
#get WCM.log location
$params.Add($((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\SMS\Tracing\SMS_WSUS_CONFIGURATION_MANAGER).TraceFileName)) | Out-Null
#get WSUSSyncMgr.log
$params.Add($((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\sms\Tracing\SMS_WSUS_SYNC_MANAGER).TraceFileName)) | Out-Null
$cmd = "CMTrace"
& $cmd $params