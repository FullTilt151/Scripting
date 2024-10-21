$sourceCon = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS875
$query = "SELECT * FROM SMS_UpdateGroupAssignment"
Get-WmiObject -Query $query -ComputerName $sourceCon.ComputerName -Namespace $sourceCon.NameSpace | ForEach-Object{
    Write-Output "Checking $($_.AssignmentName)"
    if($_.DisableMomAlerts -eq $false -or $_.RaiseMomAlertsOnFailure -eq $false)
    {
        Write-Output "Updating $($_.AssignmentName)"
        $_.DisableMomAlerts = $true
        $_.RaiseMomAlertsOnFailure = $true
        $_.Put() | Out-Null
    }
}
