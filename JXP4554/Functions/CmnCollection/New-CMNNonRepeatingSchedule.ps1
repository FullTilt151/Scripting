Function New-CMNNonRepeatingSchedule {
    $Program = Get-WmiObject -ComputerName $SiteServer -Namespace "root\SMS\Site_$SiteCode" -Query "Select * from SMS_Program WHERE PackageID = '$packageID'"

    # Get the available time
    $FormatAvailable = get-date -Day 25 -Hour 10 -Minute 0 -Second 0
    $DateAvailable = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($(get-date -Day $Day -Hour $Hour -Minute $Minute -Second $Second))

    # Get the required time
    $FormatRequired = get-date -format yyyyMMddHHmmss -Day 25 -Hour 22 -Minute 0 -Second 0
    $DateRequired = $FormatRequired + ".000000+***"

    # Create Assigment Time
    $ScheduleTime = ([WMIClass] "\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_ST_NonRecurring").CreateInstance()

    $ScheduleTime.DayDuration = 0
    $ScheduleTime.HourDuration = 0
    $ScheduleTime.MinuteDuration = 0
    $ScheduleTime.IsGMT = "false"
    $ScheduleTime.StartTime = $DateRequired

    # Create Advertisment
    $Advertisement = ([WMIClass] "\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_Advertisement").CreateInstance()

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
} #End New-CMNNonRepeatingSchedule
