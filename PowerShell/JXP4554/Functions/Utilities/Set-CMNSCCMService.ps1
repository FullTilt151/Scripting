PARAM
(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Start','Stop','Restart')]
    [String]$action
)
$services = ('CcmExec','SMS_EXECUTIVE','SMS_SITE_BACKUP','SMS_SITE_COMPONENT_MANAGER','SMS_SITE_VSS_WRITER')
foreach($service in $services)
{
    Switch ($action)
    {
        'Start' {Get-Service $service -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq 'Stopped' -and $_.Name -ne 'SMS_SITE_BACKUP'} | Start-Service}
        'Stop' {Get-Service $service -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq 'Running'} | Stop-Service}
        'Restart' {Get-Service $service -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq 'Running'} | Restart-Service}
    }
}