#Enter in 24 hour Eastern Time format
#Formatting = "THH:mm:ss"
$StartTime = "T22:00:00"
$StopTime = "T01:00:00"

#Convert targeted Eastern time to local machine time
$loctz = Get-TimeZone
$esttz = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.Id -eq "US Eastern Standard Time" }
$date_to_convert = ((Get-Date).ToString('yyyy-MM-dd'))
$StartTime = [System.TimeZoneInfo]::ConvertTime("$date_to_convert$StartTime", $esttz, $loctz)
$StopTime = [System.TimeZoneInfo]::ConvertTime("$date_to_convert$StopTime", $esttz, $loctz)

#Add scheduled tasks
#General
#$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument 'Netsh trace start scenario=NetConnection capture=yes report=yes persistent=yes maxsize=4096 correlation=yes traceFile=C:\NetTrace.etl overwrite=yes'
#NLA
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument 'netsh trace start capture=yes overwrite=yes maxsize=1500 tracefile=c:\temp\netcapture.etl'
$trigger = New-ScheduledTaskTrigger -Daily -At $StartTime
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "NetSh capture" -Description "Capture network traffic" -Force -User SYSTEM -RunLevel "Highest"

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument 'Netsh trace stop'
$trigger = New-ScheduledTaskTrigger -Daily -At $StopTime
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "NetSh capture stop" -Description "Stop network traffic capture " -Force -User SYSTEM -RunLevel "Highest"