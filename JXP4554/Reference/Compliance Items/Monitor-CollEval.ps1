#Set this variable to true for the remediation script, false for the detection script
$remediate = $false
$waitingCountLimit = 1000
$collecitonNotificationLimit = 2000000
$siteCode = (Get-CimInstance -Namespace root/sms -ClassName SMS_ProviderLocation).SiteCode

$isCompliant = $false
$sccmConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer $env:COMPUTERNAME
$dbCon = Get-CMNConnectionString -DatabaseServer $sccmConnectionInfo.SCCMDBServer -Database $sccmConnectionInfo.SCCMDB
$waitingCountQuery = 'SELECT count(*) [Count] FROM v_collection WHERE currentstatus != 1'
$waitingCount = (Get-CMNDatabaseData -connectionString $dbCon -query $waitingCountQuery -isSQLServer).Count
$collectionNotificationsQuery = 'Select count(*) [Count] from CollectionNotifications' 
$collectionNotificationCount = (Get-CMNDatabaseData -connectionString $dbCon -query $collectionNotificationsQuery -isSQLServer).Count

if ($waitingCount -lt $waitingCountLimit -and $collectionNotificationCount -lt $collecitonNotificationLimit) {
    $isCompliant = $true
}

if ($remediate -and (!$isCompliant)) {
    $SMTPServer = "pobox.humana.com"
    $SMTPSender = "ConfigMgrSupport@humana.com"
    $Subject = "$siteCode CollEval queue is over limit."
    $eMailRecipent = 'ConfigMgrSupport@humana.com'
    $eMailMessage = "<p>{0}`r`nCollection Notification Table has {1:n0} rows.</p>" -f $siteCode, $collectionNotificationCount
    $eMailMessage += "<p>There are {0:n0} collections waiting to be evaluated.</p>" -f $waitingCount
    Send-MailMessage -To $eMailRecipent -From $SMTPSender -SmtpServer $SMTPServer -Subject $Subject -Body $eMailMessage -BodyAsHtml
}
Write-Output $isCompliant