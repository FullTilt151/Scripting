Connect-VIServer louvcswps05.rsc.humad.com
$si=get-view serviceinstance
$days=-7
$rootfolderviewalarms=(get-view -id $si.Content.RootFolder).TriggeredAlarmState
$am=get-view -id $si.Content.AlarmManager
$alarmids=$am.GetAlarm($si.Content.rootfolder)
$alarmdefinitions=get-view -id $alarmids
$vmcpuusagealarmid=($alarmdefinitions|Where-Object {$_.Info.Systemname -eq 'alarm.VmCPUUsageAlarm' }).info.alarm
$vmswithcpualarms=$rootfolderviewalarms|?{$_.Alarm -eq $vmcpuusagealarmid}
$cpuhoggingVMs=get-view -property name -id ($vmswithcpualarms | %{$_.Entity})
$result=Get-Stat -Entity ($cpuhoggingVMS|%{$_.name}) -Start (Get-Date).AddDays($days) -Finish (get-date) -Stat 'cpu.usage.average' -IntervalMins 120
$reportVMcpu=$result | select value,Entity | Group-Object -Property entity | % {$temp=$_; $temp.group | Measure-Object -Property value -average | select @{n='CPU % Average usage';e={[math]::round($_.average,3)}}, @{n='entity';e={$temp.name} }} | Sort-Object -Propert 'CPU % Average usage' -Descending

