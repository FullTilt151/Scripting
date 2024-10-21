[CmdletBinding()]
PARAM(
    [Parameter(Mandatory = $true)]
    [String]$siteServers,

    [Parameter(Mandatory = $true)]
    [String]$updateServer,

    [Parameter(Mandatory = $true)]
    [String]$password
)
$taskName = "Decline Updates"
if ((Measure-Object -InputObject (Get-ScheduledTask -TaskName $taskName)).Count -eq 0) {
    $action = New-ScheduledTaskAction -Execute 'Powershell' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -command "".\Invoke-CMNSoftwareUpdateMaintenance.ps1 -siteServers $siteServers -updateServer $updateServer -useSSL -port 8531 -logFile C:\temp\Invoke-CMNSoftwareUpdateMaintenance.log -logEntries""" -WorkingDirectory 'D:\Maintenance_Scripts\SUP\Invoke-CMNSoftwareUpdateMaintenance'
    Register-ScheduledTask -Action $action -TaskPath '\Microsoft\Configuration Manager\' -TaskName $taskName -Description "Monthly decline of updates" -User 'HUMAD\SCCM_Service' -Password $password
}

$taskName = "Optimize-WSUS"
if ((Measure-Object -InputObject (Get-ScheduledTask -TaskName $taskName)).Count -eq 0) {
$action = New-ScheduledTaskAction -Execute 'Powershell' -Argument '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -command ".\Optimize-WSUS.ps1 -doIndex -doWsusCleanup"' -WorkingDirectory 'D:\Maintenance_Scripts\SUP'
Register-ScheduledTask -Action $action -TaskPath '\Microsoft\Configuration Manager\' -TaskName $taskName -Description "Monthly Optimization of WSUS" -User 'HUMAD\SCCM_Service' -Password $password}