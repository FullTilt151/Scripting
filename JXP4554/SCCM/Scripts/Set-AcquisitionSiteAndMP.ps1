Param
(
    [Parameter(Mandatory = $false)]
    $siteCode = 'WP1'
)

Switch ($siteCode) {
    'MT1' {$MP = 'LOUAPPWTS1150.rsc.humad.com'}
    'SP1' {$MP = 'LOUAPPWPS1740.rsc.humad.com'}
    'SQ1' {$MP = 'LOUAPPWQS1020.rsc.humad.com'}
    'WP1' {$MP = 'LOUAPPWPS1642.rsc.humad.com'}
    'WQ1' {$MP = 'LOUAPPWQS1023.rsc.humad.com'}
}

$Client = New-Object -ComObject Microsoft.SMS.Client
$Client.SetAssignedSite($siteCode)
$Client.SetCurrentManagementPoint($mp)
Restart-Service CCMExec

$Client = New-Object -ComObject Microsoft.SMS.Client
$Client.GetAssignedSite()
$Client.GetCurrentManagementPoint()