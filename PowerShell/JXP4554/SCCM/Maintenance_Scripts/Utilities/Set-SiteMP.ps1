param
(
    [Parameter(Mandatory = $false)]
    $SiteCode = 'WP1',

    [Parameter(Mandatory = $false)]
    $mp = 'LOUAPPWPS1642.rsc.humad.com',

    $port = '80'
)
$Client = New-Object -ComObject Microsoft.SMS.Client
$Client.SetAssignedSite($SiteCode)
$Client.SetCurrentManagementPoint($mp)
Restart-Service CCMExec
$Client = New-Object -ComObject Microsoft.SMS.Client
$Client.GetAssignedSite()
$Client.GetCurrentManagementPoint()
