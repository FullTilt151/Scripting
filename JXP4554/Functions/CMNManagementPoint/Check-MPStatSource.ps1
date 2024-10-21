$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer 'LOUAPPWPS1658'
$SiteSystems = Get-CMNSiteSystems -SCCMConnectionInfo $SCCMConnectionInfo -role 'SMS Distribution Point'
#$SiteServer = Get-CMNSiteSystems -SCCMConnectionInfo $SCCMConnectionInfo -role 'SMS Site Server'
$path = 'D:\SMS\MP\OUTBOXES\stat.box\*.svf'
foreach($siteSystem in $siteSystems){
    $path = "\\$siteSystem\d$\SMS\MP\OUTBOXES\Stat.box\*.svf"
    Write-Output "Scanning $path"
    $errorLines += Select-String -Path $path -Pattern 'NomadBranch'
}
#$_ -replace '.*SMS Provider.(\w*).*','$1'

$cntError = 0
$cntStart = 0
$cntComplete = 0
$cntFinal = 0
$errorLines | ForEach-Object{
    switch -Wildcard ($_.Line) {
        '*EVT_Error*' {$cntError++}
        '*EVT_Rqst_Started*' {$cntStart++}
        '*EVT_Completed*' {$cntComplete++}
        '*EVT_FinalStats*' {$cntFinal++}
    }
}
Write-Output "Error = $cntError"
Write-Output "Started = $cntStart"
Write-Output "Completed = $cntComplete"
Write-Output "FinalStats = $cntFinal"