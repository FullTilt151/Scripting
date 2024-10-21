Import-Module $env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1

$deployments = Get-WmiObject -ComputerName louappwps875 -Namespace root\sms\site_cas -Class SMS_Advertisement

$spreadsheet = @{}

foreach ($deployment in $deployments) {
    $deployment.psbase.get()
    $depid = $deployment.AdvertisementID
    $depid = $deployment.AdvertisementName
    $depstart = $deployment.AssignedSchedule | Select-Object -ExpandProperty StartTime 
    $deployment.AssignedSchedule | Select-Object -ExpandProperty DayDuration
    $deployment.AssignedSchedule | Select-Object -ExpandProperty DaySpan
    $deployment.AssignedSchedule | Select-Object -ExpandProperty HourDuration
    $deployment.AssignedSchedule | Select-Object -ExpandProperty HourSpan
    $deployment.AssignedSchedule | Select-Object -ExpandProperty MinuteDuration
    $deployment.AssignedSchedule | Select-Object -ExpandProperty MinuteSpan
}