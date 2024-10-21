Function Reset-CMNClient {[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, HelpMessage = 'ComputerNames to fix')]
    [String[]]$computerNames
)

foreach ($computerName in $computerNames) {
    if (Test-Connection -ComputerName $computerName -Count 1 -ErrorAction SilentlyContinue) {
        Write-Output "Fixing $computerName"
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            Stop-Service -Name CcmExec -Force
            Get-ChildItem Cert:\LocalMachine\SMS | Where-Object { $_.Subject -match '^CN=SMS, ' } | Remove-Item -Force
            Start-Service CcmExec
        }
    }
    else{Write-Output "Unable to connect to $computerName"}
}
}
$dbCon = Get-CMNConnectionString -Database CM_WP1 -DatabaseServer LOUSQLWPS606
$query = "select STM.Netbios_Name0
from v_r_system STM
join v_FullCollectionMembership FCM on STM.ResourceID = FCM.ResourceID
where FCM.CollectionID = 'WP100BE4' and (STM.Client0 = 0 or STM.Client0 is NULL)"
$computers = (Get-cmndatabasedata -query $query -connectionstring $dbcon -isSqlServer).Netbios_Name0
Reset-CMNClient -computerNames $computers