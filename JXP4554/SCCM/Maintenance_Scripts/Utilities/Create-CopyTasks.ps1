[CmdletBinding()]
PARAM(
    [Parameter(Mandatory = $true)]
    [String]$password
)
$trigger = New-ScheduledTaskTrigger -Daily -At 7am
$dirs = ('Maintenance_Scripts', 'Scripts', 'Source')
foreach ($dir in $dirs) {
    $taskName = "Sync $dir"
    if ((Measure-Object -InputObject (Get-ScheduledTask -TaskName $taskName)).Count -eq 0) {
        $action = New-ScheduledTaskAction -Execute 'Powershell' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -command "".\SyncDir.ps1""" -WorkingDirectory "D:\$dir\"
        Register-ScheduledTask -Action $action -TaskPath '\Microsoft\Configuration Manager\' -TaskName $taskName -Description $taskName -Trigger $trigger -User 'HUMAD\SCCM_Service' -Password $password
    }
    else{
        Write-Output "$taskName already exists."
    }
}