PARAM
(
    [Parameter(Mandatory = $true,
        HelpMessage = 'SiteServer Name')]
    [String]$siteServer,

    [Parameter(Mandatory = $false)]
    [Int16]$Delay = 60
)

Clear-Host

$sccmCN = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
$baseDir = "\\$($sccmCN.ComputerName).rsc.humad.com\SMS_$($sccmCN.SiteCode)\Inboxes\Auth"
$date = Get-Date
$lastTotal = 0

while (1 -eq 1) {
    $oldDate = $date
    $date = get-date -Format G
    $dataldr = (Get-ChildItem "$baseDir\dataldr.box").Count
    $process = (Get-ChildItem "$baseDir\dataldr.box\process").Count
    $seconds = (New-TimeSpan -Start $oldDate -End $date).Minutes * 60 + (New-TimeSpan -Start $oldDate -End $date).Seconds
    $total = $dataldr + $process
    $difference = $lastTotal - $total
    $lastTotal = $total
    if($seconds -ne 0){$changesPerMinute = $difference / $seconds * 60}
    else{$changesPerMinute = 0}
    $message = "{0} - Process: {1} Dataldr: {2} Total: {3}, Difference from last run {4}, Changes/minute {5:n2}, Changes/hour {6:n2}" -f $date, $process, $dataldr, $total, $difference, $changesPerMinute, ($changesPerMinute * 60)
    $message
    Start-Sleep -Seconds $Delay
}