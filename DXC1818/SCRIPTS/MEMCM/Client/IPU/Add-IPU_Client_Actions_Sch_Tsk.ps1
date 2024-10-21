Add-Content -Path "C:\Temp\IPU_Client_Actions.ps1" -Value '
Start-Sleep -Seconds 600
IF (Test-Connection -ComputerName LOUNASWPS08.rsc.humad.com) {
    Write-Output "Discovery Data Collection Cycle"
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}"
    Write-Output "Machine Policy Retrieval & Evaluation"
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"
    Write-Output "Hardware Inventory"
    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"
    Unregister-ScheduledTask -TaskName "IPU Client Actions" -Confirm:$False
    Remove-Item -Path "C:\Temp\IPU_Client_Actions.ps1" -Force
    }'

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument 'C:\Temp\IPU_Client_Actions.ps1'
$trigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "IPU Client Actions" -Description "Run client actions after IPU" -Force -User SYSTEM -RunLevel "Highest"