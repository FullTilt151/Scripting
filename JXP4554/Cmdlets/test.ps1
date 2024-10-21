# Variables
$cimCollectionID = 'MT100980'
$wmiCollectionID = 'MT100981'
$computerName = 'LOUAPPWTS1140'
$nameSpace = 'Root\SMS\Site_MT1'
$startTime = '08:00:00 PM'
$hourDuration = 1
$minuteDuration = 30
$StartTime = [DateTime]"$(Get-Date  -Format d) $(Get-Date $startTime -Format t)"
$startTimeDMTF = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($startTime)
$wmiQueryParameters = @{
    ComputerName = $computerName;
    NameSpace    = 'root/sms/site_mt1';
}

# Objects
$cimSession = New-CimSession -ComputerName $computerName
$sms_CollectionRuleQueryObj = Get-CimClass -CimSession $cimSession -Namespace $nameSpace -ClassName SMS_CollectionRuleQuery
$sms_CollectionSettingsObj = Get-CimClass -CimSession $cimSession -Namespace $nameSpace -ClassName SMS_CollectionSettings
$sms_ST_NonRecurringObj = Get-CimClass -CimSession $cimSession -Namespace $nameSpace -ClassName SMS_ST_NonRecurring
$sms_ServiceWindowObj = Get-CimClass -CimSession $cimSession -Namespace $nameSpace -ClassName SMS_ServiceWindow
$sms_ScheduleMethodsObj = Get-CimClass -CimSession $cimSession -Namespace $nameSpace -ClassName SMS_ScheduleMethods

# Now to create the Collection objects
$wmiCollectionSettings = Get-WmiObject -Class SMS_CollectionSettings -Filter "CollectionID = '$wmiCollectionID'" @wmiQueryParameters
if (!$wmiCollectionSettings) {
    $wmiCollectionSettings = ([WMIClass]"\\louappwts1140\root\sms\site_mt1:SMS_CollectionSettings").CreateInstance()
    $wmiCollectionSettings.CollectionID = "$wmiCollectionID"
}

$cimCollectionSettings = Get-CimInstance -CimSession $cimSession -Namespace $nameSpace -ClassName SMS_CollectionSettings -Filter "CollectionID = '$cimCollectionID'"
if (!$cimCollectionSettings) {
    $cimCollectionSettings = New-CimInstance -ClientOnly -CimClass $sms_CollectionSettingsObj -Property @{
        CollectionID = $cimCollectionID;
    }
}

# Now to create the service windows
$wmiServiceWindow = ([WMIClass]"\\LOUAPPWTS1140\root\sms\site_MT1:SMS_ServiceWindow").CreateInstance()
$wmiServiceWindow.Name = "Month - $x"
$wmiServiceWindow.Description = "Month - $x"
$wmiServiceWindow.IsEnabled = $true
$wmiServiceWindow.RecurrenceType = 1
$wmiServiceWindow.ServiceWindowType = 1

$cimServiceWindow = New-CimInstance -ClientOnly -CimClass $sms_ServiceWindowObj -Property @{
    Name              = "Month - $x";
    Description       = "Month - $x";
    IsEnabled         = $true;
    RecurrenceType    = 1;
    ServiceWindowType = 1;
}

# Now to create Schedules
$wmiCMSchedule = ([WMIClass]"\\$($computerName)\$($NameSpace):SMS_ST_NonRecurring").CreateInstance()
$wmiCMSchedule.DayDuration = 0
$wmiCMSchedule.HourDuration = $hourDuration
$wmiCMSchedule.MinuteDuration = $minuteDuration
$wmiCMSchedule.StartTime = $wmiServiceWindow.ConvertFromDateTime($StartTime)
$wmiCMSchedule.IsGMT = $false

$cimCMSchedule = New-CimInstance -ClientOnly -CimClass $sms_ST_NonRecurringObj -Property @{
    DayDuration    = 0;
    HourDuration   = $hourDuration;
    MinuteDuration = $minuteDuration;
    IsGMT          = $false;
}
$cimCMSchedule.StartTime = Invoke-CimMethod

$cimServiceWindow.ServiceWindowSchedules = (Invoke-CimMethod -Name WriteToString -ClassName SMS_ScheduleMethods -Namespace $nameSpace -ComputerName $computerName).StringData;
                    
$cimCollectionSettings.ServiceWindows += $cimServiceWindow.PSObject.BaseObject
