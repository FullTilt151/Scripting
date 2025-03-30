[CmdletBinding(ConfirmImpact = 'low')]
PARAM(
    [Parameter(Mandatory = $true)]
    [PSObject]$sccmConnectionInfo
)

$WmiQueryParameters = $sccmConnectionInfo.WmiQueryParameters

$SUGs = Get-WmiObject -Class SMS_UpdateGroupAssignment @WmiQueryParameters
foreach ($SUG in $SUGs) {
    Write-Output "$($SUG.AssignmentName)"
    $SUG.DisableMomAlerts = $true
    $SUG.RaiseMomAlertsOnFailure = $true
    $SUG.Put() | Out-Null
}