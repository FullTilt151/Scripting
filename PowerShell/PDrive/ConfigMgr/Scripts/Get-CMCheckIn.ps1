# Invoke machine policy retrieval and eval
Invoke-WmiMethod -Namespace "Root\CCM" -Class SMS_Client -Name TriggerSchedule -ArgumentList "{00000000-0000-0000-0000-000000000021}" | Out-Null

# Parse PolicyAgent.log and determine last policy request
$PolicyAgent = Get-Content C:\windows\ccm\logs\PolicyAgent.log
$PolicyInstance = $PolicyAgent | Select-String "ResourceType = `"Machine`"" -Context 4,0 | Select-Object -Last 1
$PolicyDateWMI = ($PolicyInstance.Context.PreContext | Select-String 'DateTime').ToString().Trim().Replace('DateTime = "','').Replace('";','')
$PolicyDate = [System.Management.ManagementDateTimeConverter]::ToDateTime($PolicyDateWMI)
Get-Date $PolicyDate -UFormat "%m/%d/%Y %I:%M:%S %p"