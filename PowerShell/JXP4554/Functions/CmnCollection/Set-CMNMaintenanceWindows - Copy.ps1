Function Set-CMNMaintenanceWindows
{
	<#
		.SYNOPSIS
            This function is used to import the Maintenance window collections from a spreadsheet

		.DESCRIPTION
            Manual window reboot at Start+30 minutes and End-60 minutes.
            Auto window will reboot at Start+0 minutes and End-60 minutes.
		
		.PARAMETER ObjectID

		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES
			Author:	Jim Parris
			Email:	Jim@ConfigMan-Notes
			Date:	
			PSVer:	2.0/3.0
			Updated: 
			http://www.connectionstrings.com/excel/
			CAS Limiting Collection - CAS0191C
			SP1 Limiting Collection - SP100020
			SQ1 Limiting Collection - SQ100022

			Container Node IDs
			SQ1 - 16777237 HGB - 16778236
			SP1 - 16777308
			CAS - 5943

			RebootPackageID
			SQ1 - SQ10000C
			SP1 - SP10000D

			Formats of collection names:
			Patch Day 03 - 01 Crash & Burn Reboot 12:00PM
			PD04 - FRI - MW01 - 23:00PM-03:00AM - AUTO
	#>

	[CmdletBinding(SupportsShouldProcess = $true, 
		ConfirmImpact = 'Low')]
	PARAM(
 		[Parameter(Mandatory = $true,
			HelpMessage = 'SCCM Connection Info')]
		[PSObject]$SCCMConnectionInfo,

		[Parameter(Mandatory = $true,
			HelpMessage = 'Location of Excel file to import')]
		[String]$file,

		[Parameter(Mandatory = $true,
			HelpMessage = 'Limiting Collection ID')]
		[String]$limitingCollectionID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Reboot Package ID')]
        [String]$rebootPackageID,

		[Parameter(Mandatory = $true,
			HelpMessage = 'Folder to put collections')]
		[String]$destinationContainer,

		[Parameter(Mandatory = $false,
			HelpMessage = 'Deployment Collection Folder')]
		[String]$deploymentFolder = 'NWS Patch Management\Deploy to Collections',

		[Parameter(Mandatory = $true,
			HelpMessage = 'Column number containing the collection names')]
		[Int16]$collectionColumn,

		[Parameter(Mandatory = $true,
			HelpMessage = 'Column number containing the machine names')]
		[Int16]$nameColumn,
        
        [Parameter(Mandatory = $false,
            HelpMessage = 'Default duration for window')]
        [Int16]$defaultDuration = 30,

		[Parameter(Mandatory = $false,
			HelpMessage = 'Number of Maintenance Windows to create')]
		[Int]$numWindows = 12,

 		[Parameter(Mandatory = $false,
			HelpMessage = 'LogFile Name')]
		[String]$logFile = 'C:\Temp\Error.log',

		[Parameter(Mandatory = $false,
			HelpMessage = 'Log entries')]
		[Switch]$logEntries,

		[Parameter(Mandatory = $false,
			HelpMessage = 'Max Log size')]
		[Int32]$maxLogSize = 5242880,

		[Parameter(Mandatory = $false,
			HelpMessage = 'Max number of history logs')]
		[Int32]$maxHistory = 5,

		[Parameter(Mandatory = $false,
			HelpMessage = 'Show Progress')]
		[Switch]$showProgress
	)

	Begin
	{
		#build splats
		$NewLogEntry = @{
			LogFile = $logFile;
			Component = 'Set-CMNMaintenanceWindows';
			maxLogSize = $maxLogSize;
			maxHistory = $maxHistory;
		}

		$WMIQueryParameters = @{
			ComputerName = $SCCMConnectionInfo.ComputerName;
			NameSpace = $SCCMConnectionInfo.NameSpace;
		}
        
        # Set the current location to be the site code.
        Set-Location "$($SiteCode):\" @initParams

		if($PSBoundParameters['logEntries'])
		{
			$destinationContainerID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name $destinationContainer -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
			$deploymentFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name $deploymentFolder -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
			$deploymentRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name "$deploymentFolder\Reboot" -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
			$deploymentNoRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name "$deploymentFolder\NoReboot" -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
            $deployToCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $deploymentFolderID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
			New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
			New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "file = $file" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "limitingCollectionID = $limitingCollectionID" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "rebootPackageID = $rebootPackageID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "deploymentFolder = $deploymentFolder" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "destinationContainer = $destinationContainer" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "destinationContainerID = $destinationContainerID" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "collectionColumn = $collectionColumn" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "nameColumn = $nameColumn" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "defaultDuration = $defaultDuration" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "numWindows = $numWindows" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "showProgress = $showProgress" -type 1 @NewLogEntry
		}
		else
		{
			$destinationContainerID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name $destinationContainer -ObjectType SMS_Collection_Device
			$deploymentFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name $deploymentFolder -ObjectType SMS_Collection_Device
			$deploymentRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name $"$deploymentFolder\Reboot" -ObjectType SMS_Collection_Device
			$deploymentNoRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name "$deploymentFolder\NoReboot" -ObjectType SMS_Collection_Device
            $deployToCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $deploymentFolderID -ObjectType SMS_Collection_Device
		}
		
		#Hash Tables
		$targetCollections = @{} # This will hold the information from the spreadsheet
        $targetCollectionsStartDay = @{} # This will hod the start day for the mainteance window on the collection
		$targetCollectionsStartTime = @{} # This will hold the start times for the mainteance window on the collection
		$targetCollectionsDuration = @{} # This will hold the duration in minutes for the maintenance window on the collection
		$targetCollectionsReboot = @{} # This will hold if we need a reboot job or not
		$collectionIDs = New-Object System.Collections.ArrayList # This keeps the Collection ID's we create/reuse so we can remove any extras
		
		#Arrays for Collection Rules
		$noRebootColRules = New-Object System.Collections.ArrayList
		$rebootColRules = New-Object System.Collections.ArrayList

		#Start with the spreadsheet
		$excel = New-Object -com excel.application
		$workbook = $excel.workbooks.open($File)
		$sheet = $workbook.Sheets.Item(1)
	}

	Process
	{
		#Start by building a hash table with the collection name as the key, and an array of WKID's for the value
		#We assume the first row is headers, so we skip.

		$totalRows = $sheet.UsedRange.Rows.Count-1
		For($y=2;$y -le $sheet.UsedRange.rows.Count;$y++)
		{
			#Show progress? If so, do it
			if($PSBoundParameters['showProgress']){Write-Progress -Activity 'Import Excel Info' -PercentComplete ((($y-1) / $TotalRows) * 100) -CurrentOperation "$($y-1)/$TotalRows"}
			$Collection = $Sheet.Cells.Item($y,$collectionColumn).Value2
			if($Collection)
			{
				$CurrentCollection = $Collection
                #PD04 - FRI - MW01 - 23:00PM-03:00AM - AUTO
				if($CurrentCollection -match 'PD\d+.*')
				{
					[Int16]$day = $CurrentCollection -replace 'PD(\d+).*','$1'
                    $day-- 
					$Matches.Clear() | Out-Null
					$CurrentCollection -match '.* (\d{1,2}:\d{1,2}..)-(\d{1,2}:\d{1,2}..).*' | Out-Null
					$startTime = $Matches[1]
					$endTime = $Matches[2]
                    
					if((Get-Date $startTime).Hour -lt (Get-Date  $endTime).Hour)
					{
						$duration = (New-TimeSpan -Start $startTime -End $endTime).TotalMinutes - 60
					}
					else
					{
						$duration = (New-TimeSpan -Start $startTime -End ((Get-Date $endTime).AddDays(1))).TotalMinutes - 60
					}
					if((Get-Date $startTime).Hour -le 6)
					{
						$day++
					}
					$Matches.Clear()
					if($CurrentCollection -match 'Auto') # Auto window will reboot at Start+0 minutes and End-60 minutes.
					{
						$reboot = [Array]0
						$reboot += [Array]$duration
					}
					elseif($CurrentCollection -match 'Manual') # Manual window reboot at Start+30 minutes and End-60 minutes.
					{
						$reboot = [Array]0
						$startTime = (Get-Date ((Get-Date $startTime).AddMinutes(30)) -Format t)
						$duration = $duration - 30
                        $reboot += [Array]$duration
					}
					else
					{
						$reboot = 'No Reboot'
					}
                    $targetCollectionsStartDay.Add($CurrentCollection,$day)
					$targetCollectionsStartTime.Add($CurrentCollection,$startTime)
					$targetCollectionsDuration.Add($CurrentCollection,$duration)
					$targetCollectionsReboot.Add($CurrentCollection,$reboot)
				}
				else
				{
					$targetCollectionsStartTime.Add($CurrentCollection,'None')
					$targetCollectionsDuration.Add($CurrentCollection,'None')
					$targetCollectionsReboot.Add($CurrentCollection,'No Reboot')
				}
				if($PSBoundParameters['logEntries'])
				{
					New-CMNLogEntry -entry "$CurrentCollection is now selected" -type 1 @NewLogEntry
					New-CMNLogEntry -entry "Starting on day $($targetCollectionsStartDay[$CurrentCollection]) at $($targetCollectionsStartTime[$CurrentCollection]) and going for $($targetCollectionsDuration[$CurrentCollection]) minutes" -type 1 @NewLogEntry
					New-CMNLogEntry -entry "Reboot is $($targetCollectionsReboot[$CurrentCollection])" -type 1 @NewLogEntry
				}
			}
			$Server = $Sheet.Cells.Item($y,$nameColumn).Value2
			if($Server)
			{
				$TargetCollections[$CurrentCollection] += [Array]$Server
			}
		}
		if($PSBoundParameters['showProgress']){Write-Progress -Activity 'Import Excel Info' -Completed}
		$Workbook.Close($false)
		$Excel.Quit()
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Finished with spreadsheet' -type 1 @NewLogEntry}

		#$LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$limitingCollectionID'" @WMIQueryParameters
		#$LimitingCollection.Get()
        $LimitingCollection = Get-CMDeviceCollection -id $limitingCollectionID
		#Cycle through each of the collections
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Starting to cycle through collection list' -type 1 @NewLogEntry}
		$CollectionProgress = 1
		$CollectionTotalTargets = $TargetCollections.Count
		foreach($TargetCollection in $TargetCollections.GetEnumerator())
		{
			if($PSBoundParameters['showProgress'])
			{
				Write-Progress -Activity 'Cycling through collections' -Status "Collection $($TargetCollection.Key)" -PercentComplete (($CollectionProgress / $CollectionTotalTargets) * 100) -CurrentOperation "$CollectionProgress / $CollectionTotalTargets"
				$CollectionProgress++
			}
			
            #Does the hash table have any machines?
            if($TargetCollection -ne $null -and $TargetCollection -ne '')
            {
                #Does Collection Exist?
                $SCCMCollection = Get-CMDeviceCollection -Name $TargetCollection.Key
			    if($SCCMCollection) # Collection exists
			    {
				    if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Collection $($SCCMCollection.Name) exists, removing existing maintenance windows" -type 1 @NewLogEntry}
				    Get-CMMaintenanceWindow -CollectionId $SCCMCollection.CollectionID | ForEach-Object {Remove-CMMaintenanceWindow -CollectionId $SCCMCollection.CollectionID -MaintenanceWindowName $_.Name -ErrorAction SilentlyContinue -Force | Out-Null}
                    if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Removing existing deployments" -type 1 @NewLogEntry}
                    Get-CMDeployment -CollectionName $SCCMCollection.Name -FeatureType Package | Remove-CMDeployment -Force | Out-Null
                    $collectionIDs.Add($SCCMCollection.CollectionID) | Out-Null
			    }
			    Else
			    {
				    if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Creating collection $($TargetCollection.Key)." -type 1 @NewLogEntry}
                    $CMSchedule = New-CMSchedule -Start (Get-Date 01:00AM) -DurationInterval Days -DurationCount 0 -RecurInterval Days -RecurCount 1
                    $SCCMCollection = New-CMDeviceCollection -LimitingCollectionId $LimitingCollection.CollectionID -Name $TargetCollection.Key -RefreshType Periodic -RefreshSchedule $CMSchedule
                    Move-CMObject -FolderPath "$($SCCMConnectionInfo.SiteCode):\DeviceCollection\$destinationContainer" -InputObject $SCCMCollection
                    $collectionIDs.Add($SCCMCollection.CollectionID) | Out-Null
			    }
			    #Set maintenance window on collection
			    #Create CMSchedule and ServiceWindow Objects
			    if($targetCollectionsDuration[$targetCollection.Key] -ne 'None')
			                                                                                                                                                                        {
                $month = (Get-Date).Month - 1
                $year = (Get-Date).Year
                if($month -lt 1)
                {
                    $month = 12
                    $year--
                }
                for($x = 0 ; $x -lt $numWindows ; $x++)
                {
                    $patchTuesday = Get-Date(Get-CMNPatchTuesday -date "$month/01/$year") -Format d
                    $month++
                    if($month -gt 12)
                    {
                        $month = 1
                        $year++
                    }
                    #if($targetCollectionsStartTime[$targetCollection.Key] -le "06:00AM"){$offset = 0}
                    #else{$offset = 1}
                    $startTime = Get-Date (Get-Date "$patchtuesday $($targetCollectionsStartTime[$targetCollection.Key])").AddDays($targetCollectionsStartDay[$targetCollection.key]) -Format g
				    $CMSchedule = New-CMSchedule -Start $startTime -Nonrecurring
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
				    #$CMSchedule.StartTime = $ServiceWindow.ConvertFromDateTime($targetCollectionsStartTime[$targetCollection.Key])
				    $CMSchedule.IsGMT = $false
                    if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Creating maintenance window for $startTime" -type 1 @NewLogEntry}
				    New-CMMaintenanceWindow -CollectionId $SCCMCollection.CollectionID -Schedule $CMSchedule -Name "$($targetCollection.Key) - $x" | Out-Null
                }
			}

			    #Add reboot Deployment

			    if($targetCollectionsReboot[$targetCollection.Key] -ne 'No Reboot')
			                                                                                                                                                        {
                if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Creating Reboot Job' -type 1 @NewLogEntry}
                $month = (Get-Date).Month - 1
                $year = (Get-Date).Year
                if($month -lt 1)
                {
                    $month = 12
                    $year--
                }
                $patchTuesday = Get-Date(Get-CMNPatchTuesday -date "$month/01/$year") -Format d
                $month++
                if($month -gt 12)
                {
                    $month = 1
                    $year++
                }
                #if($targetCollectionsStartTime[$targetCollection.Key] -le "06:00AM"){$offset = 1}
                #else{$offset = 0}
                $startTime = (Get-Date "$patchtuesday $($targetCollectionsStartTime[$targetCollection.Key])").AddDays($targetCollectionsStartDay[$targetCollection.key])
                if($startTime -lt (Get-Date))
                {
                    $patchTuesday = Get-Date(Get-CMNPatchTuesday -date "$month/01/$year") -Format d
                    $startTime = (Get-Date "$patchtuesday $($targetCollectionsStartTime[$targetCollection.Key])").AddDays($targetCollectionsStartDay[$targetCollection.key])
                }
                $rebootTime = Get-Date '1/1/2000' -Format g
				$expireTime = $rebootTime
				$availableTime = Get-Date '1/1/2120' -Format g
				$rebootTimes = @()
				foreach($runTime in $targetCollectionsReboot[$targetCollection.Key])
				{
					$rebootTime = (get-date $startTime).AddMinutes($runtime - 5)
					if((New-TimeSpan -Start $rebootTime -End $expireTime).Minutes -le 20 -or (New-TimeSpan -Start $rebootTime -End $expireTime).Days -ne 0){$expireTime = (get-date $rebootTime).AddMinutes(15)}
					if($rebootTime -lt $availableTime){$availableTime = $rebootTime}
					$rebootTimes += New-CMSchedule -Start $rebootTime -Nonrecurring
				}
				New-CMPackageDeployment -PackageId $rebootPackageID -ProgramName 'Reboot' -CollectionId $SCCMCollection.CollectionID -StandardProgram -DeployPurpose Required -RerunBehavior AlwaysRerunProgram -AvailableDateTime $availableTime -Schedule $rebootTimes -FastNetworkOption RunProgramFromDistributionPoint -SlowNetworkOption RunProgramFromDistributionPoint | Out-Null
                Set-CMPackageDeployment -PackageId $rebootPackageID -StandardProgramName 'Reboot' -CollectionId $SCCMCollection.CollectionID -EnableExpireSchedule $true -DeploymentExpireDateTime $expireTime -Schedule $rebootTimes | Out-Null
			}

			    #Build query for collection rule

			    #Remove existing rules for collection
			    if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Removing items from $($SCCMCollection.Name)" -type 1 @NewLogEntry}
			    Get-CMDeviceCollectionQueryMembershipRule -CollectionId $SCCMCollection.CollectionID | ForEach-Object {Remove-CMDeviceCollectionQueryMembershipRule -RuleName $_.RuleName -CollectionId $SCCMCollection.CollectionID -Force}
			    #Add query rule
			    $colQuery = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.NetbiosName in ("
			    foreach($Target in $TargetCollection.Value)
			    {
				    $colQuery = "$colQuery'$Target',"
			    }
			    $colQuery = "$($colQuery.Substring(0,$colQuery.Length - 1)))"
			    Add-CMDeviceCollectionQueryMembershipRule -CollectionId $SCCMCollection.CollectionID -RuleName 'Query' -QueryExpression $colQuery
                Invoke-CMCollectionUpdate -CollectionId $SCCMCollection.CollectionID
                if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Updating Collection membership for $($SCCMCollection.Name)" -type 1 @NewLogEntry}
            }
            else{if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "$($TargetCollection.Name) Does not have any members, skipping" -type 2 @NewLogEntry}}
		}
		if($PSBoundParameters['showProgress']){Write-Progress -Activity 'Cycling through collections' -Completed}

        #Clean up collections in Maintenance Window folder
        if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Cleaning up extra collections' -type 1 @NewLogEntry}
        $collectionIDsToRemove = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $destinationContainerID -ObjectType SMS_Collection_Device | Where-Object {$_ -notin $collectionIDs}
        ForEach($collectionIDToRemove in $collectionIDsToRemove)
        {
            #First, find out if they have any dependencies
            if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "CollectionID $collectionIDToRemove" -type 1 @NewLogEntry}
            $dependentCollectionIDs = (Get-WmiObject -Query "Select * from SMS_CollectionDependencies WHERE SourceCollectionID = '$collectionIDToRemove' and RelationshipType = 2" @WMIQueryParameters).DependentCollectionID
            foreach($dependentCollectionID in $dependentCollectionIDs){Remove-CMDeviceCollectionIncludeMembershipRule -CollectionId $dependentCollectionID -IncludeCollectionId $collectionIDToRemove -Force}
            Remove-CMDeviceCollection -ID $collectionIDToRemove -Force 
        }

        #update deployment collections 
 
        if($PSBoundParameters['logEntries'])
        {
            New-CMNLogEntry -entry 'Building include rules for later' -type 1 @NewLogEntry
            $mwCollectionIDs = (Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $destinationContainerID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries | Where-Object {$_ -ne ''})
        }
		else{$mwCollectionIDs = (Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $destinationContainerID -ObjectType SMS_Collection_Device | Where-Object {$_ -ne ''})}
		foreach($mwCollectionID in $mwCollectionIDs)
		{
            $query = "select * from sms_collection where collectionID = '$mwCollectionID'"
			$collection = Get-WmiObject -Query $query @WMIQueryParameters
            $includeRule = ([WMIClass]"//$($SCCMConnectionInfo.ComputerName)/$($SCCMConnectionInfo.NameSpace):SMS_CollectionRuleIncludeCollection").CreateInstance()
			$includeRule.IncludeCollectionID = $mwCollectionID
			$includeRule.RuleName = $collection.Name
			if($collection.Name -match 'NoReboot' -or $collection.Name -match 'No Reboot')
            {
                if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Adding $($collection.Name) to noReboot rules" -type 1 @NewLogEntry}
                $noRebootColRules.Add($includeRule) | Out-Null
            }
			elseif($collection.name -notmatch 'Do Not Patch')
            {
                if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Adding $($collection.Name) to reboot rules" -type 1 @NewLogEntry}
                $rebootColRules.Add($includeRule) | Out-Null
            }
		}

		# Cycle throgh and verify/create reboot/noreboot collections
        if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Updating Deploy to collections with new include rules' -type 1 @NewLogEntry}
		foreach($deployToCollectionID in $deployToCollectionIDs)
		{
			$query = "Select * from SMS_Collection where CollectionID = '$deployToCollectionID'"
			$collection = Get-WmiObject -Query $query @WMIQueryParameters
            if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Processing $($collection.Name)" -type 1 @NewLogEntry}

			# if we don't get a collection, we've got a problem
			if($collection)
			{
				$rebootCollectionName = "$($collection.Name) - Reboot"
				$noRebootCollectionName = "$($collection.Name) - NoReboot"
				# See if Reboot Collection Exists
				$query = "Select * from SMS_Collection where Name = '$rebootCollectionName'"
				$rebootCollection = Get-WmiObject -Query $query @WMIQueryParameters
				if(-not($rebootCollection))
                {
                    if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "$rebootCollectionName doesn't exist, creating." -type 1 @NewLogEntry}
                    $rebootCollection = New-CMNDeviceCollection -SCCMConnectionInfo $SCCMConnectionInfo -limitToCollectionID $collection.CollectionID -name $rebootCollectionName -comment 'Created by script'
                    Move-CMNObject -SCCMConnectionInfo $SCCMConnectionInfo -objectID $rebootCollection.CollectionID -destinationContainerID $deploymentRebootFolderID -objectType SMS_Collection_Device
                    $rebootCollection = Get-WmiObject -Query $query @WMIQueryParameters | Out-Null
                }

				# See if NoReboot Collection Exists
				$query = "Select * from SMS_Collection where name = '$noRebootCollectionName'"
				$noRebootCollection = Get-WmiObject -Query $query @WMIQueryParameters
				if(-not($noRebootCollection))
                {
                    if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "$noRebootCollectionName doesn't exist, creating." -type 1 @NewLogEntry}
                    $noRebootCollection = New-CMNDeviceCollection -SCCMConnectionInfo $SCCMConnectionInfo -limitToCollectionID $collection.CollectionID -name $noRebootCollectionName -comment 'Created by script'
                    Move-CMNObject -SCCMConnectionInfo $SCCMConnectionInfo -objectID $noRebootCollection.CollectionID -destinationContainerID $deploymentNoRebootFolderID -objectType SMS_Collection_Device
                    $noRebootCollection = Get-WmiObject -Query $query @WMIQueryParameters | Out-Null
                }

				# Get rid of the existing rules
                if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Removing rules from $rebootCollectionName" -type 1 @NewLogEntry}
				$rebootCollection.get()
                if($rebootCollection.CollectionRules.Count -gt 0){$rebootCollection.DeleteMembershipRules($rebootCollection.CollectionRules) | Out-Null}
                if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Adding rules to $rebootCollectionName" -type 1 @NewLogEntry}
                $rebootCollection.get()
                $rebootCollection.AddMemberShipRules($rebootColRules) | Out-Null
                $rebootCollection.RequestRefresh() | Out-Null

                if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Removing rules from $noRebootCollectionName" -type 1 @NewLogEntry}
                $noRebootCollection.get()
                if($noRebootCollection.CollectionRules.Count -gt 0){$noRebootCollection.DeleteMembershipRules($noRebootCollection.CollectionRules) | Out-Null}
                if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Adding rules to $noRebootCollectionName" -type 1 @NewLogEntry}
                $noRebootCollection.get()
                $noRebootCollection.AddMemberShipRules($noRebootColRules) | Out-Null
                $noRebootCollection.RequestRefresh() | Out-Null
			}
		}

		#Finished!!
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry}
	}
}#End Set-CMNMaintenanceWindows
$logFile = 'c:\temp\Set-CMNMaintenanceWindows.log'
#if(Test-Path -Path $logFile){Remove-Item -Path $logFile}

$destinationContainer = 'Maintenance Windows'

# MT1 Info
$file = 'C:\temp\SCCM - Device Collections - 4 Hour.xlsm'
$lmtgCollectionID = 'SMS00001'
$rebootPackageID = 'WP100121'
$SCCMCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWTS1140
$SiteCode = $SCCMCon.SiteCode 
$ProviderMachineName = $SCCMCon.ComputerName

$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
Push-Location
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}
#Set-CMNMaintenanceWindows -SCCMConnectionInfo $SCCMCon -file $file -limitingCollectionID $lmtgCollectionID -rebootPackageID $rebootPackageID -destinationContainer $destinationContainer -collectionColumn 1 -nameColumn 2 -logFile $logFile -logEntries -showProgress
Pop-Location

# SQ1 Information
$file = 'http://teams.humana.com/sites/NWO/NWO%20Doc%20Library/SCCM/SCCM%20-%20Device%20Collections%20-%204%20Hour.xlsm'
$lmtgCollectionID = 'SQ100022'
$rebootPackageID = 'SQ10000C'
$SCCMCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWQS1150
$SiteCode = $SCCMCon.SiteCode 
$ProviderMachineName = $SCCMCon.ComputerName

$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
Push-Location
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}
#Set-CMNMaintenanceWindows -SCCMConnectionInfo $SCCMCon -file $file -limitingCollectionID $lmtgCollectionID -rebootPackageID $rebootPackageID -destinationContainer $destinationContainer -collectionColumn 1 -nameColumn 2 -logFile $logFile -logEntries -showProgress
Pop-Location

# SP1 Information
$lmtgCollectionID = 'SP100020'
$rebootPackageID = 'SP10000D'
$SCCMCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1825

#$file = 'http://teams.humana.com/sites/NWO/NWO%20Doc%20Library/SCCM/SCCM%20-%20Device%20Collections%20-%204%20Hour.xlsm'
$file = 'http://teams.humana.com/sites/NWO/NWO%20Doc%20Library/SCCM/SCCM%20-%20Device%20Collections%20-%20SQL%20Removed.xlsm'
$destinationContainer = 'Maintenance Windows'
$SiteCode = $SCCMCon.SiteCode 
$ProviderMachineName = $SCCMCon.ComputerName

$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
Push-Location
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}
Set-CMNMaintenanceWindows -SCCMConnectionInfo $SCCMCon -file $file -limitingCollectionID $lmtgCollectionID -rebootPackageID $rebootPackageID -destinationContainer $destinationContainer -collectionColumn 1 -nameColumn 2 -logFile $logFile -logEntries -showProgress
Pop-Location
