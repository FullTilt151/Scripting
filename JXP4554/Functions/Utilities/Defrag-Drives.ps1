$Trigger = New-JobTrigger -Daily -At '3:00 am'
$Options = New-ScheduledJobOption -HideInTaskScheduler -RunElevated
Register-ScheduledJob -Name 'Daily Defrag' -ScriptBlock {foreach ($Drive in (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3").DeviceID.Substring(0, 1)) {Optimize-Volume -DriveLetter $Drive}} -Trigger $Trigger -ScheduledJobOption $Options