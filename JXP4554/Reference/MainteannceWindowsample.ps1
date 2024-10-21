[CmdletBinding()]
param(
    [string]$SiteCode,
    [string]$ServiceWindowName,
    [string]$ServiceWindowDescription,
    [string]$CollectionID
)
Function Convert-NormalDateToConfigMgrDate {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$starttime
    )
    return [System.Management.ManagementDateTimeconverter]::ToDMTFDateTime($starttime)
}
Function create-ScheduleToken {
    $SMS_ST_RecurInterval = "SMS_ST_RecurInterval"
    $class_SMS_ST_RecurInterval = [wmiclass]""
    $class_SMS_ST_RecurInterval.psbase.Path = "ROOT\SMS\Site_$($SiteCode):$($SMS_ST_RecurInterval)"
    $scheduleToken = $class_SMS_ST_RecurInterval.CreateInstance()
    if ($scheduleToken) {
        $scheduleToken.DayDuration = 1
        $scheduleToken.HourDuration = 0
        $scheduleToken.IsGMT = $false
        $scheduleToken.MinuteDuration = 0
        $scheduleToken.StartTime = (Convert-NormalDateToConfigMgrDate $startTime)
        $SMS_ScheduleMethods = "SMS_ScheduleMethods"
        $class_SMS_ScheduleMethods = [wmiclass]""
        $class_SMS_ScheduleMethods.psbase.Path = "ROOT\SMS\Site_$($SiteCode):$($SMS_ScheduleMethods)"
        $script:ScheduleString = $class_SMS_ScheduleMethods.WriteToString($scheduleToken)
        [string]$ScheduleString.StringData
    }
}
Function New-SMSServiceWindow {
    $CollSettings = Get-WmiObject -class sms_collectionsettings -Namespace root\sms\site_$($SiteCode) | Where-Object { $_.CollectionID -eq "$($CollectionID)" }
    $CollSettings = [wmi]$CollSettings.__PATH
    $CollSettings.Get()
    $SMS_ServiceWindow = "SMS_ServiceWindow"
    $class_SMS_ServiceWindow = [wmiclass]""
    $class_SMS_ServiceWindow.psbase.Path = "ROOT\SMS\Site_$($SiteCode):$($SMS_ServiceWindow)"
    $SMS_ServiceWindow = $class_SMS_ServiceWindow.CreateInstance()
    $SMS_ServiceWindow.Name = "$($ServiceWindowName)"
    $SMS_ServiceWindow.Description = "$($ServiceWindowDescription)"
    $SMS_ServiceWindow.IsEnabled = $true
    $SMS_ServiceWindow.ServiceWindowSchedules = $scheduleString
    $SMS_ServiceWindow.ServiceWindowType = 1 #1 is General, 5 is for OSD
    $SMS_ServiceWindow.StartTime = "$(Get-Date -Format "yyyyMMddhhmmss.ffffff+***")"
    $CollSettings.ServiceWindows += $SMS_ServiceWindow.psobject.baseobject
    $CollSettings.Put() | Out-Null
}
##############################################
[datetime]$startTime = get-date
$schedulestring = create-ScheduleToken
try {
    New-SMSServiceWindow
}
catch {
    Write-Error "There was an error creating the Maintenance Window $($ServiceWindowName) for Collection ID $($CollectionID)."
}
