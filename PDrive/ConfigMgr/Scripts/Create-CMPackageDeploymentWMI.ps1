$SiteServer = 'LOUAPPWPS875.rsc.humad.com'
$Sitecode = 'CAS'
$PackageID = 'CAS00913'

#$AppName = ''
$CollectionID = 'CAS025DF'


$Program = Get-WmiObject -ComputerName $SiteServer -Namespace "root\SMS\Site_$SiteCode" -Query "Select * from SMS_Program WHERE PackageID = '$packageID'"
 
# Get the available time
$DateAvailable = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($(get-date -Day 25 -Hour 10 -Minute 0 -Second 0))

# Get the required time
$DateRequired = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($(get-date -Day 25 -Hour 22 -Minute 0 -Second 0))
 
# Create Assigment Time
$ScheduleTime = ([WMIClass] "\\$SiteServer\root\sms\site_$SiteCode`:SMS_ST_NonRecurring").CreateInstance()
 
$ScheduleTime.DayDuration = 0
$ScheduleTime.HourDuration = 0
$ScheduleTime.MinuteDuration = 0
$ScheduleTime.IsGMT = "false"
$ScheduleTime.StartTime = $DateRequired
 
# Create Advertisment
$Advertisement = ([WMIClass] "\\$SiteServer\root\sms\site_$SiteCode`:SMS_Advertisement").CreateInstance()
 
$Advertisement.AdvertFlags = "36700160";
#$Advertisement.AdvertisementName = $AppName;
$Advertisement.CollectionID = $CollectionID;
$Advertisement.PackageID = $PackageID;
$Advertisement.AssignedSchedule = $ScheduleTime;
$Advertisement.DeviceFlags = 0x00000000;
$Advertisement.ProgramName = $Program.ProgramName;
$Advertisement.RemoteClientFlags = "34896";
$Advertisement.PresentTime = $DateAvailable;
$Advertisement.SourceSite = $SiteCode;
$Advertisement.TimeFlags = "8209"
 
# Apply Advertisement
$Advertisement.put()