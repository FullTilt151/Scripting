#This will open all MEMCM installation logs.

$logDir = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global -ErrorAction SilentlyContinue).LogDirectory
if (!$logdir) {$logDir = "$($env:windir)\CCM\Logs"}
$params = @("$logdir\smsts.log", "$logdir\execmgr.log")
$cmd = 'cmtrace'
& $cmd $params