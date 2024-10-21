"Starting Set-Inventory at $(Get-Date)" | Out-File -FilePath 'C:\Temp\Set-Inventory.log' -Encoding ascii -Append
$client = Get-CimClass -Namespace Root\CCM -ClassName SMS_Client
$actions = ('{00000000-0000-0000-0000-000000000001}', '{00000000-0000-0000-0000-000000000003}')
$isPending = $true
while ($isPending) {
    $isPending = $false
    $completedActions = (Get-CimInstance -Namespace root\CCM\InvAgt -ClassName InventoryActionStatus).InventoryActionID
    foreach ($action in $actions) {
        if ($completedActions.Count -gt 0) {
            if (!$completedActions.Contains($action)) {
                "Running action $action at $(Get-Date)" | Out-File -FilePath 'C:\Temp\Set-Inventory.log' -Encoding ascii -Append
                Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = $action} | Out-Null
                $isPending = $true
            }
        }
        else{
            $isPending = $true
            "Running action $action at $(Get-Date)" | Out-File -FilePath 'C:\Temp\Set-Inventory.log' -Encoding ascii -Append
            Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = $action} | Out-Null
        }
    }
    if ($isPending) {
        Start-Sleep -Seconds 600
        Restart-Service -Name CcmExec
    }
}
"Finishing Set-Inventory at $(Get-Date)" | Out-File -FilePath 'C:\Temp\Set-Inventory.log' -Encoding ascii -Append