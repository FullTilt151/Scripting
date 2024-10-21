Function New-CMNDailySchedule {
    <#
		.SYNOPSIS
			Returns a SMS_ST_RecurInterval object for a non-repeating schedule.

		.DESCRIPTION

		.PARAMETER Text

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.EXAMPLE

		.NOTES

		.LINK
			http://configman-notes.com
	#>
    Param
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Collection ID')]
        [String]$collectionID,

        [Parameter(Mandatory = $false, HelpMessage = 'Start time')]
        [DateTime]$startTime
    )

    $collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$collectionID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
    if ($collection) {
        $ScheduleTime = ([WMIClass] "\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_ST_RecurInterval").CreateInstance()

        $ScheduleTime.DayDuration = 0
        $ScheduleTime.DaySpan = 1
        $ScheduleTime.HourDuration = 0
        $ScheduleTime.HourSpan = 0
        $ScheduleTime.MinuteDuration = 0
        $ScheduleTime.MinuteSpan = 0
        $ScheduleTime.IsGMT = $false
        $ScheduleTime.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-date $startTime -Format "MM/dd/yyy hh:mm:ss"))
        $collection.Get()
        $collection.RefreshType = 2
        $collection.RefreshSchedule = $ScheduleTime
        $collection.Put()
        $collection.RequestRefresh()
    }
    else {
        Write-Verbose "Collection $collectionID does not exist"
    }
} #End New-CMNDailySchedule
