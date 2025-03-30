Function Set-CMNMaintenanceWindowCollection
{
	<#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

 	.PARAMETER logFile
		File for writing logs to

	.PARAMETER logEntries
		Switch to say whether or not to create a log file

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.PARAMETER maxHistory
			Specifies the number of history log files to keep, default is 5

 	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Set-CMNMaintenanceWindowCollection.ps1
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     2017-11-21
		Updated:
		Version:     1.0.0
	#>

	[CmdletBinding(SupportsShouldProcess = $true,
		ConfirmImpact = 'Low')]

	PARAM
	(
		[Parameter(Mandatory = $true,
			HelpMessage = 'SCCM Connection Info')]
		[PSObject]$SCCMConnectionInfo,

		[Parameter(Mandatory = $true,
			HelpMessage = 'Colleciton object')]
		[PSObject]$Collection,

		[Parameter(Mandatory = $true,
			HelpMessage = 'Limiting Collection Object')]
		[PSObject]$LimitingCollection,

 		[Parameter(Mandatory = $false,
			HelpMessage = 'LogFile Name')]
		[String]$LogFile = 'C:\Temp\Error.log',

		[Parameter(Mandatory = $false,
			HelpMessage = 'Log entries')]
		[Switch]$LogEntries,

		[Parameter(Mandatory = $false,
			HelpMessage = 'Max Log size')]
		[Int32]$MaxLogSize = 5242880,

		[Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs')]
        [Int32]$MaxLogHistory = 5
	)

	Begin
	{
		#Build splat for log entries
		$NewLogEntry = @{
			LogFile = $LogFile;
			Component = 'Set-CMNMaintenanceWindowCollection';
			MaxLogSize = $MaxLogSize;
			MaxLogHistory = $MaxLogHistory;
		}
		#Build splats for WMIQueries
        $WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters
		if($PSBoundParameters['logEntries'])
		{
			New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
			New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "LimitingCollection ID = $($LimitingCollection.CollectionID)" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logFile = $LogFile" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logEntries = $LogEntries" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxLogSize = $MaxLogSize" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxHistory = $MaxLogHistory" -type 1 @NewLogEntry
		}
	}

	Process
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}

		#Does Collection Exist?
		$SCCMCollection = Get-WmiObject -Class SMS_Collection -Filter "Name = '$($TargetCollection.Key)'" @WMIQueryParameters
		if($SCCMCollection)
		{
			if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Collection $($SCCMCollection.Name) exists" -type 1 @NewLogEntry}
			$SCCMCollection.Get()
			#Remove existing rules
			if($SCCMCollection.CollectionRules){$Results = $SCCMCollection.DeleteMembershipRules($SCCMCollection.CollectionRules) | Out-Null}
		}
		Else
		{
			if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Creating collection $($TargetCollection.Key)." -type 1 @NewLogEntry}
			$SCCMCollection = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_Collection").CreateInstance()
			$SCCMCollection.CollectionType = 2
			$SCCMCollection.Name = ($TargetCollection.Key)
			$SCCMCollection.LimitToCollectionID = ($LimitingCollection.CollectionID)
			$SCCMCollection.LimitToCollectionName = ($LimitingCollection.Name)
			$SCCMCollection.Put() | Out-Null
			$SCCMCollection.Get()
            $CollectionIDsToKeep.add($SCCMCollection.CollectionID)
			[Array]$DeviceCollectionID = ($SCCMCollection.CollectionID)
			$TargetFolderID = ($DestinationMWContainerID)
			Invoke-WmiMethod -Class SMS_ObjectContainerItem -Name MoveMembers -ArgumentList 0, $($SCCMCollection.CollectionID), 5000,($DestinationMWContainerID) @WMIQueryParameters
		}
		#Set maintenance window on collection
		#Create CMSchedule and ServiceWindow Objects
		if($targetCollectionsDuration[$targetCollection.Key] -ne 'None')
		{
            try #Remove any existing maintenance windows
            {
                $CollectionSettings = Get-WmiObject -Class $SMS_CollectionSettings -Filter "CollectionID = '$($SCCMCollection.CollectionID)'" @WMIQueryParameters
                $CollectionSettings.Get()
                $CollectionSettings | Remove-WmiObject
            }
            Catch [System.Exception]
            {}
            if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Creating $($targetCollection.Key) Collection Settings instance" -type 2 @NewLogEntry}
			$CollectionSettings = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_CollectionSettings").CreateInstance()
			$CollectionSettings.CollectionID = "$($SCCMCollection.CollectionID)"
            for($x = 0;$x -lt $NumberofMWs;$x++)
            {
                $StartTime = Get-Date "$(Get-Date -date (Get-Date (Get-CMNPatchTuesday -date (Get-Date).AddMonths($x))).AddDays($targetCollectionsStartDay[$TargetCollection.Key]) -Format d) $($TargetCollectionsStartTime[$TargetCollection.Key])"
				$CMSchedule = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_ST_NonRecurring").CreateInstance()
				$ServiceWindow = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_ServiceWindow").CreateInstance()
				#Specify Schedule
				$CMSchedule.DayDuration = 0
				$duration = $targetCollectionsDuration[$targetCollection.Key]
				if($duration -ge 60)
				{
					[Int]$hourDuration = [Math]::Floor($duration / 60)
					[Int]$minuteDuration = $duration % 60
				}
				else
				{
					[Int]$hourDuration = 0
					[Int]$minuteDuration = $duration
				}
				$CMSchedule.HourDuration = $hourDuration
				$CMSchedule.MinuteDuration = $minuteDuration
				$CMSchedule.StartTime = $ServiceWindow.ConvertFromDateTime($StartTime)
				$CMSchedule.IsGMT = $false
				$ServiceWindow.Name = "$($SCCMCollection.Name) - $x"
				$ServiceWindow.Description = "$($SCCMCollection.Name) - $x"
				$ServiceWindow.IsEnabled = $true
				$ServiceWindow.ServiceWindowSchedules = (Invoke-WmiMethod -Name WriteToString -Class SMS_ScheduleMethods @WMIQueryParameters $CMSchedule).StringData
				#Now, we're duplicating some data, but such is life.
				$ServiceWindow.Duration = $($targetCollectionsDuration[$targetCollection.Key])
				#This says non-repeating
				$ServiceWindow.RecurrenceType = 1
				#This is for updates only
				$ServiceWindow.ServiceWindowType = 1 #1 = General, 4 = Software Updates
				$ServiceWindow.StartTime = $ServiceWindow.ConvertFromDateTime($targetCollectionsStartDay[$targetCollection.Key])
				#And we set it
				$CollectionSettings.ServiceWindows += $ServiceWindow.PSObject.BaseObject
				if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Setting $($targetCollection.Key) - Maintenance Window. Starts at $StartTime and goes for $hourDuration hours and $minuteDuration minutes." -type 2 @NewLogEntry}

				#Final step, it's just like we're hitting the "OK" button!
				$CollectionSettings.put() | Out-Null
            }
		}

		#Add reboot Deployment

		if($targetCollectionsReboot[$targetCollection.Key] -ne 'No Reboot')
		{
			$rebootTime = Get-Date '1/1/2000' -Format g
			$expireTime = $rebootTime
			$availableTime = Get-Date '1/1/2020' -Format g
			$rebootTimes = @()
            $StartTime = Get-Date "$(Get-Date -date (Get-Date (Get-CMNPatchTuesday -date (Get-Date))).AddDays($targetCollectionsStartDay[$TargetCollection.Key]) -Format d) $($TargetCollectionsStartTime[$TargetCollection.Key])"
			foreach($runTime in $targetCollectionsReboot[$targetCollection.Key])
			{
				$rebootTime = (get-date $StartTime).AddMinutes($runtime - 5)
				if((New-TimeSpan -Start $rebootTime -End $expireTime).Minutes -le 20 -or (New-TimeSpan -Start $rebootTime -End $expireTime).Days -ne 0){$expireTime = (get-date $rebootTime).AddMinutes(15)}
				if($rebootTime -lt $availableTime){$availableTime = $rebootTime}
				$rebootTimes += $rebootTime
			}
			New-CMNPackageDeployment -SCCMConnectionInfo $SCCMConnectionInfo -packageID $RebootPackageID -programName 'Reboot' -collectionID $SCCMCollection.CollectionID -availableTime $availableTime -runTimes $rebootTimes -rdp -reRunMode 'Always Rerun' -overRideMaintenanceWindow -rebootOutsideMaintenanceWindow -expireTime $expireTime -replaceExisting -logFile $LogFile -logEntries -ErrorAction SilentlyContinue
		}

		#Build query for collection rule

		#Remove existing rules for collection
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Removing items from $($SCCMCollection.Name)" -type 1 @NewLogEntry}
		$SCCMCollection.Get()
		if($SCCMCollection.CollectionRules.Count -ne 0)
		{
			foreach($rule in $SCCMCollection.CollectionRules)
			{
				$Results = $SCCMCollection.DeleteMembershipRules($rule) | Out-Null
				$SCCMCollection.Get()
			}
		}
		#Add query rule
		$colQuery = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.NetbiosName in ("
		foreach($Target in $TargetCollection.Value)
		{
			$colQuery = "$colQuery'$Target',"
		}
		$colQuery = "$($colQuery.Substring(0,$colQuery.Length - 1)))"
		$queryMemberRule = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_CollectionRuleQuery").CreateInstance()
		$queryMemberRule.QueryExpression = $colQuery
		$queryMemberRule.RuleName = 'Query'
		$SCCMCollection.AddMembershipRule($queryMemberRule)

		#Set collection to update daily
		$ScheduleTime = ([WMIClass] "\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_ST_RecurInterval").CreateInstance()
		$ScheduleTime.DayDuration = 0
		$ScheduleTime.DaySpan = 1
		$ScheduleTime.HourDuration = 0
		$ScheduleTime.HourSpan = 0
		$ScheduleTime.MinuteDuration = 0
		$ScheduleTime.MinuteSpan = 0
		$ScheduleTime.IsGMT = $false
		$ScheduleTime.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime('01/01/2017 01:00:00')
		$SCCMCollection.RefreshType = 2
		$SCCMCollection.RefreshSchedule = $ScheduleTime
		$SCCMCollection.Put()
		$SCCMCollection.RequestRefresh()
	}

	End
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
	}
} #End Set-CMNMaintenanceWindowCollection

$CollectionObj = New-Object PSObject
Add-Member -InputObject $CollectionObj -MemberType NoteProperty -Name Collection -Value $TargetCollection.Name
Add-Member -InputObject $CollectionObj -MemberType NoteProperty -Name StartDay -Value $TargetCollectionsStartDay[$TargetCollection.Name]
Add-Member -InputObject $CollectionObj -MemberType NoteProperty -Name StartTime -Value $TargetCollectionsStartTime[$TargetCollection.Name]
Add-Member -InputObject $CollectionObj -MemberType NoteProperty -Name Duration -Value $TargetCollectionsDuration[$TargetCollection.Name]
Add-Member -InputObject $CollectionObj -MemberType NoteProperty -Name Reboot -Value $TargetCollectionsReboot[$TargetCollection.Name]
Add-Member -InputObject $CollectionObj -MemberType NoteProperty -Name Members -Value $TargetCollections[$TargetCollection.Name]