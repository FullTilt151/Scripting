try {
    Write-Output "Renaming $env:windir\System32\GroupPolicy\Machine\Registry.pol to $env:windir\System32\GroupPolicy\Machine\Registry.old" | ConvertTo-Json
    if (Test-Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol") {
        Write-Output "Moving $env:windir\System32\GroupPolicy\Machine\Registry.pol to $env:windir\System32\GroupPolicy\Machine\Registry.old" | ConvertTo-Json
        Move-Item -Path "$env:windir\System32\GroupPolicy\Machine\Registry.pol" -Destination "$env:windir\System32\GroupPolicy\Machine\Registry.old" -Force
    }
    else{
        Write-Output "unable to find $env:windir\System32\GroupPolicy\Machine\Registry.pol" | ConvertTo-Json
    }
}

Catch {
    Write-Output "Unable to rename $env:windir\System32\GroupPolicy\Machine\Registry.pol" | ConvertTo-Json
    Throw "Unable to rename $env:windir\System32\GroupPolicy\Machine\Registry.pol"
}

try {
    Write-Output "Removing InventoryActionSatus from WMI" | ConvertTo-Json
    Get-CimInstance -Namespace root\CCM\InvAgt -ClassName InventoryActionStatus -Filter "InventoryActionID = '{00000000-0000-0000-0000-000000000001}'" -ErrorAction SilentlyContinue | Remove-CimInstance
    Invoke-CimMethod -Namespace root\ccm -ClassName SMS_Client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000001}'} -ErrorAction SilentlyContinue | Out-Null
}
catch {
    Write-Output "Unable to reset inventory" | ConvertTo-Json
    Write-Output $Error.ErrorDetails | ConvertTo-Json
    Throw "Unable to reset inventory"
}

Write-Output "$env:COMPUTERNAME complete!" | ConvertTo-Json