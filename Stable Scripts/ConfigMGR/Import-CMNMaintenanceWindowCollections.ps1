Function Import-CMNMainteananceWindowCollections {
    <#
		.SYNOPSIS
            This function is used to import the Maintenance window collections from a spreadsheet

		.DESCRIPTION
            Manual window reboot at Start+30 minutes and End-60 minutes. MW Start time is start + 30, MW End time is End - 60
            Auto window will reboot at Start+0 minutes and End-60 minutes. MW Start time is Start + 15, MW End is End - 60

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

            Need to add check that user is Admin
            Need to correct Error removing CollectionSettings
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$SCCMConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Location of Excel file to import')]
        [String]$file,

        [Parameter(Mandatory = $true, HelpMessage = 'Limiting Collection ID')]
        [String]$limitingCollectionID,

        [Parameter(Mandatory = $true, HelpMessage = 'Reboot Package ID')]
        [String]$RebootPackageID,

        [Parameter(Mandatory = $false, HelpMessage = 'Invoke-SCCMUpdates Package ID')]
        [String]$InvokeUpdatesPackageID,

        [Parameter(Mandatory = $true, HelpMessage = 'Folder to put mainteance window collections in')]
        [String]$DestinationMWContainer,

        [Parameter(Mandatory = $false, HelpMessage = 'Deployment Collection Folder')]
        [String]$DeploymentFolder = 'NWS Patch Management\Deploy to Collections',

        [Parameter(Mandatory = $true, HelpMessage = 'Column number containing the collection cames')]
        [Int]$collectionColumn,

        [Parameter(Mandatory = $true, HelpMessage = 'Column number containing the machine names')]
        [Int]$nameColumn,

        [Parameter(Mandatory = $false, HelpMessage = 'Number of Maintenance Windows. Default is 12')]
        [Int]$NumberofMWs = 12,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5,

        [Parameter(Mandatory = $false, HelpMessage = 'Show Progress')]
        [Switch]$showProgress
    )

    Begin {
        #Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }

        #build splats
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Import-CMNMainteananceWindowCollections';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        $WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters
        #Add error checking
        $DestinationMWContainerID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name $DestinationMWContainer -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        #Do some logging
        if ($logEntries) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "file = $file" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "limitingCollectionID = $limitingCollectionID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "rebootPackageID = $RebootPackageID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "DestinationMWContainer = $DestinationMWContainer" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "DeploymentFolder = $deploymentFolder" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "destinationContainerID = $DestinationMWContainerID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "collectionColumn = $collectionColumn" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "nameColumn = $nameColumn" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "NumberofMWs = $NumberofMWs" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "showProgress = $showProgress" -type 1 @NewLogEntry
        }

        #Hash Tables
        $targetCollections = @{ } #This will hold the computers (value) in each collection (key) information from the spreadsheet
        $targetCollectionsStartDay = @{ } #This will hold the start day for the mainteance window on the collection
        $TargetCollectionsStartTime = @{ } #This will hold the start times
        $targetCollectionsDuration = @{ } #This will hold the duration in minutes for the maintenance window on the collection
        $targetCollectionsReboot = @{ } #This will hold if we need a reboot job or not
        $CollectionIDsToKeep = New-Object System.Collections.ArrayList #Used during cleanup to remove any collections that are not used anymore. May be rewritten to make more efficent
        $excel = New-Object -com excel.application
        $workbook = $excel.workbooks.open($File)
        $sheet = $workbook.Sheets.Item(1)
    }

    Process {
        #Start by building a hash table with the collection name as the key, and an array of WKID's for the value
        #We assume the first row is headers, so we skip.

        $totalRows = $sheet.UsedRange.Rows.Count - 1
        $patchTuesday = Get-Date (Get-Date (Get-CMNPatchTuesday)) -Format D
        for ($y = 2; $y -le $sheet.UsedRange.rows.Count; $y++) {
            #Show progress? If so, do it
            if ($PSBoundParameters['showProgress']) {
                Write-Progress -Activity 'Import Excel Info' -PercentComplete ((($y - 1) / $TotalRows) * 100) -CurrentOperation "$($y-1)/$TotalRows"
            }
            $Collection = $Sheet.Cells.Item($y, $collectionColumn).Value2
            if ($Collection) {
                $CurrentCollection = $Collection
                [Int]$day = $Collection.Substring(2, 2)
                $colType = $Collection.Substring(19, 4)
                If ($colType -eq 'Auto') {
                    [int]$startOffset = 15
                }
                else {
                    [Int]$startOffset = 30
                }
                [Int]$endOffset = -60
                $startTime = Get-Date (Get-Date ("$($Collection.Substring(9,2)):$($Collection.Substring(11,2))")).AddMinutes($startOffset) -Format t
                $endTime = Get-Date (Get-Date ("$($Collection.Substring(14,2)):$($Collection.Substring(16,2))")).AddMinutes($endOffset) -Format t
                if ((Get-Date $startTime).Hour -lt (Get-Date  $endTime).Hour) {
                    $duration = (New-TimeSpan -Start $startTime -End $endTime).TotalMinutes
                }
                else {
                    $duration = (New-TimeSpan -Start $startTime -End ((Get-Date $endTime).AddDays(1))).TotalMinutes
                }
                if ($colType -eq 'Auto') {
                    $reboot = (-15, $duration)
                }
                elseif ($colType -eq 'Manu') {
                    $reboot = (0, $duration)
                }
                else {
                    $reboot = 'No Reboot'
                }
                $targetCollectionsStartDay.Add($CurrentCollection, $day)
                $targetCollectionsDuration.Add($CurrentCollection, $duration)
                $targetCollectionsReboot.Add($CurrentCollection, $reboot)
                $TargetCollectionsStartTime.Add($CurrentCollection, $StartTime)
                if ($logEntries) {
                    New-CMNLogEntry -entry "[Collection = '$CurrentCollection'] [StartDay = '$($targetCollectionsStartDay[$CurrentCollection])'] [StartTime = '$($TargetCollectionsStartTime[$CurrentCollection])'] [Duration = '$($targetCollectionsDuration[$CurrentCollection]) minutes'] [Reboot = '$($targetCollectionsReboot[$CurrentCollection])']" -type 1 @NewLogEntry
                }
            }
            $Server = $Sheet.Cells.Item($y, $nameColumn).Value2
            if ($Server) {
                $TargetCollections[$CurrentCollection] += [Array]$Server
            }
        } #End of for($y=2;$y -le $sheet.UsedRange.rows.Count;$y++)
        if ($PSBoundParameters['showProgress']) {
            Write-Progress -Activity 'Import Excel Info' -Completed
        }
        $Workbook.Close($false)
        $excel.Quit()
        if ($logEntries) {
            New-CMNLogEntry -entry 'Finished with spreadsheet' -type 1 @NewLogEntry
        }

        #Get limiting collection
        $LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$limitingCollectionID'" @WMIQueryParameters
        $LimitingCollection.Get()
        #Cycle through each of the collections
        if ($logEntries) {
            New-CMNLogEntry -entry 'Starting to cycle through collection list' -type 1 @NewLogEntry
        }
        $CollectionProgress = 1
        $CollectionTotalTargets = $TargetCollections.Count
        foreach ($TargetCollection in $TargetCollections.GetEnumerator()) {
            if ($PSBoundParameters['showProgress']) {
                Write-Progress -Activity 'Cycling through collections' -Status "Collection $($TargetCollection.Key)" -PercentComplete (($CollectionProgress / $CollectionTotalTargets) * 100) -CurrentOperation "$CollectionProgress / $CollectionTotalTargets"
                $CollectionProgress++
            }
            if ($logEntries) {
                New-CMNLogEntry -entry "Working collection $($TargetCollection.Key)" -type 1 @NewLogEntry
            }
            #Does Collection Exist?
            $SCCMCollection = Get-WmiObject -Class SMS_Collection -Filter "Name = '$($TargetCollection.Key)'" @WMIQueryParameters
            if ($SCCMCollection) {
                if ($logEntries) {
                    New-CMNLogEntry -entry "Collection $($SCCMCollection.Name) exists, removing rules." -type 1 @NewLogEntry
                }
                $SCCMCollection.Get()
                #Remove existing rules
                if ($SCCMCollection.CollectionRules) {
                    $SCCMCollection.DeleteMembershipRules($SCCMCollection.CollectionRules) 
                }
                $CollectionIDsToKeep.add($SCCMCollection.CollectionID)
            }
            Else {
                if ($logEntries) {
                    New-CMNLogEntry -entry "Creating collection $($TargetCollection.Key)." -type 1 @NewLogEntry
                }
                $SCCMCollection = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_Collection").CreateInstance()
                $SCCMCollection.CollectionType = 2
                $SCCMCollection.Name = ($TargetCollection.Key)
                $SCCMCollection.LimitToCollectionID = ($LimitingCollection.CollectionID)
                $SCCMCollection.LimitToCollectionName = ($LimitingCollection.Name)
                $SCCMCollection.Put()
                $SCCMCollection.Get()
                $CollectionIDsToKeep.add($SCCMCollection.CollectionID)
                [Array]$DeviceCollectionID = ($SCCMCollection.CollectionID)
                Invoke-WmiMethod -Class SMS_ObjectContainerItem -Name MoveMembers -ArgumentList 0, $($SCCMCollection.CollectionID), 5000, ($DestinationMWContainerID) @WMIQueryParameters
            }
            #Set maintenance window on collection
            #Create CMSchedule and ServiceWindow Objects
            if ($targetCollectionsDuration[$targetCollection.Key] -ne 'None') {
                #Remove any existing maintenance windows
                # try {
                #     if ($logEntries) {
                #         New-CMNLogEntry -entry "Attempting to remove any schedules from $($SCCMCollection.Name)" -type 1 @NewLogEntry
                #     }
                #     $CollectionSettings = Get-WmiObject -Class SMS_CollectionSettings -Filter "CollectionID = '$($SCCMCollection.CollectionID)'" @WMIQueryParameters
                #     $CollectionSettings.Get()
                #     $SvcWindowItems = $CollectionSettings.ServiceWindows
                #     foreach ($SvcWindow in $SvcWindowItems) {
                #         if ($logEntries) {
                #             New-CMNLogEntry -entry "Removing $($SvcWindow.Description)" -type 1 @NewLogEntry
                #         }
                #         $SvcWindow.Remove()
                #     }
                #     #$CollectionSettings | Remove-WmiObject
                # }
                # Catch [System.Exception] {
                #     if ($logEntries) {
                #         New-CMNLogEntry -entry "Error removing CollectionSettings for $($SCCMCollection.Name)" -type 3 @NewLogEntry
                #     }
                # }
                if ($logEntries) {
                    New-CMNLogEntry -entry "Creating $($targetCollection.Key) Collection Settings instance" -type 1 @NewLogEntry
                }
                $CollectionSettings = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_CollectionSettings").CreateInstance()
                $CollectionSettings.CollectionID = "$($SCCMCollection.CollectionID)"
                for ($x = 0; $x -lt $NumberofMWs; $x++) {
                    $StartTime = "$(Get-Date -date (Get-Date -Date (Get-CMNPatchTuesday -date (Get-Date).AddMonths($x))).AddDays($targetCollectionsStartDay[$TargetCollection.Key] - 1) -Format d) $(Get-Date $TargetCollectionsStartTime[$TargetCollection.Key] -Format t)"
                    $CMSchedule = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_ST_NonRecurring").CreateInstance()
                    $ServiceWindow = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_ServiceWindow").CreateInstance()
                    #Specify Schedule
                    $CMSchedule.DayDuration = 0
                    $duration = $targetCollectionsDuration[$targetCollection.Key]
                    if ($duration -ge 60) {
                        [Int]$hourDuration = [Math]::Floor($duration / 60)
                        [Int]$minuteDuration = $duration % 60
                    }
                    else {
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
                    if ($logEntries) {
                        New-CMNLogEntry -entry "Setting $($targetCollection.Key) - Maintenance Window. Starts at $StartTime and goes for $hourDuration hours and $minuteDuration minutes." -type 1 @NewLogEntry
                    }
                    #Final step, it's just like we're hitting the "OK" button!
                    $CollectionSettings.put()
                }
            }

            #Add reboot Deployment

            if ($targetCollectionsReboot[$targetCollection.Key] -ne 'No Reboot') {
                New-CMNLogEntry -entry "Deploying [PackageID = '$RebootPackageID'] to [Collection = '$($targetCollection.Key)']" -type 1 @NewLogEntry
                $rebootTime = Get-Date '1/1/2000' -Format g
                $expireTime = $rebootTime
                $availableTime = Get-Date '1/1/2020' -Format g
                $rebootTimes = @()
                $StartTime = Get-Date "$(Get-Date -date (Get-Date (Get-CMNPatchTuesday -date (Get-Date))).AddDays($targetCollectionsStartDay[$TargetCollection.Key] - 1) -Format d) $($TargetCollectionsStartTime[$TargetCollection.Key])"
                foreach ($runTime in $targetCollectionsReboot[$targetCollection.Key]) {
                    $rebootTime = (Get-Date $StartTime).AddMinutes($runTime)
                    if ((New-TimeSpan -Start $rebootTime -End $expireTime).Minutes -le 20 -or (New-TimeSpan -Start $rebootTime -End $expireTime).Days -ne 0) {
                        $expireTime = (Get-Date $rebootTime).AddMinutes(15)
                    }
                    if ($rebootTime -lt $availableTime) {
                        $availableTime = $rebootTime
                    }
                    $rebootTimes += $rebootTime
                }
                $newCMNPackageDeploymentSplat = @{
                    ErrorAction                    = 'SilentlyContinue'
                    runTimes                       = $rebootTimes
                    reRunMode                      = 'Always Rerun'
                    programName                    = 'Reboot'
                    rebootOutsideMaintenanceWindow = $true
                    logFile                        = $logFile
                    packageID                      = $RebootPackageID
                    sccmConnectionInfo             = $SCCMConnectionInfo
                    expireTime                     = $expireTime
                    replaceExisting                = $true
                    rdp                            = $true
                    logEntries                     = $false
                    availableTime                  = $availableTime
                    collectionID                   = $SCCMCollection.CollectionID
                    overRideMaintenanceWindow      = $true
                }
                New-CMNPackageDeployment @newCMNPackageDeploymentSplat
            }

            #Add Invoke-SCCMUpdates deployment

            if ($PSBoundParameters.ContainsKey('InvokeUpdatesPackageID')) {
                New-CMNLogEntry -entry "Deploying [PackageID = '$InvokeUpdatesPackageID'] to [Collection = '$($targetCollection.Key)']" -type 1 @NewLogEntry
                $StartTime = "$(Get-Date -date (Get-Date -Date (Get-CMNPatchTuesday -date (Get-Date))).AddDays($targetCollectionsStartDay[$TargetCollection.Key] - 1) -Format d) $(Get-Date $TargetCollectionsStartTime[$TargetCollection.Key] -Format t)"
                $InvokeTimes = @((Get-Date $StartTime).AddMinutes(15), (Get-Date $StartTime).AddMinutes(30))
                $expireTime = (Get-Date $StartTime).AddMinutes(45)
                $newCMNPackageDeploymentSplat = @{
                    ErrorAction                    = 'SilentlyContinue'
                    runTimes                       = $InvokeTimes
                    reRunMode                      = 'Always Rerun'
                    programName                    = 'Invoke-SCCMUpdates'
                    rebootOutsideMaintenanceWindow = $false
                    logFile                        = $logFile
                    packageID                      = $InvokeUpdatesPackageID
                    sccmConnectionInfo             = $SCCMConnectionInfo
                    expireTime                     = $expireTime
                    replaceExisting                = $true
                    rdp                            = $true
                    logEntries                     = $false
                    availableTime                  = (Get-Date $StartTime)
                    collectionID                   = $SCCMCollection.CollectionID
                    overRideMaintenanceWindow      = $true
                }
                New-CMNPackageDeployment @newCMNPackageDeploymentSplat
            }


            #Build query for collection rule

            #Remove existing rules for collection
            if ($logEntries) {
                New-CMNLogEntry -entry "Removing Existing Collection Membership rules from $($SCCMCollection.Name)" -type 1 @NewLogEntry
            }
            $SCCMCollection.Get()
            if ($SCCMCollection.CollectionRules.Count -ne 0) {
                foreach ($rule in $SCCMCollection.CollectionRules) {
                    $Results = $SCCMCollection.DeleteMembershipRules($rule) 
                    $SCCMCollection.Get()
                }
            }
            #Add query rule
            $colQuery = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.NetbiosName in "
            $colQuery = [string]::Format("{0}('{1}')", $colQuery, [string]::Join("', '", $TargetCollection.Value))
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
        } #End of $CollectionTotalTargets = $TargetCollections.Count
        if ($PSBoundParameters['showProgress']) {
            Write-Progress -Activity 'Cycling through collections' -Completed
        }

        #Update DeployTo Collections
        $DeploymentFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name $deploymentFolder -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        $DeploymentRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name "$deploymentFolder\Reboot" -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        $deploymentNoRebootFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name "$deploymentFolder\NoReboot" -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        $deployToCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $DeploymentFolderID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
        $rebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $DeploymentRebootFolderID -ObjectType SMS_Collection_Device -Recurse -logFile $logFile -logEntries
        $noRebootCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $deploymentNoRebootFolderID -ObjectType SMS_Collection_Device -Recurse -logFile $logFile -logEntries
        $mwCollectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $DestinationMWContainerID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries | Where-Object { $_ -ne '' }
        $CollIdsToUpdate = $rebootCollectionIDs + $noRebootCollectionIDs

        if ($logEntries) {
            New-CMNLogEntry -entry 'Remove existing DeployTo Rules' -type 1 @NewLogEntry
        }
        foreach ($CollIdToUpdate in $CollIdsToUpdate) {
            $Collection = Get-WmiObject -Query "Select * from SMS_Collection where CollectionID = '$CollIdToUpdate'" @WMIQueryParameters
            ##** Need to deal with no Collection
            $Collection.Get()
            if ($Collection.CollectionRules) {
                if ($logEntries) {
                    New-CMNLogEntry -entry "Removing rules from $($Collection.Name) ($($Collection.CollectionID))" -type 1 @NewLogEntry
                }
                $Collection.DeleteMembershipRules($Collection.CollectionRules)
            }
        }

        if ($logEntries) {
            New-CMNLogEntry -entry 'Remove extra collections from Maintenance Window container' -type 1 @NewLogEntry
        }
        $CollectionsToRemove = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $DestinationMWContainerID -ObjectType SMS_Collection_Device | Where-Object { $_ -notin $CollectionIDsToKeep -and $_ -ne '' }
        foreach ($CollectionToRemove in $CollectionsToRemove) {
            Remove-CMNCollection -sccmConnectionInfo $SCCMConnectionInfo -collectionID $CollectionToRemove -doForce -logFile $logFile -logEntries
        }

        #Cycle through the ID's and build the Reboot/NoReboot Collection Objects
        if ($logEntries) {
            New-CMNLogEntry -entry 'Building include rules for later' -type 1 @NewLogEntry
        }
        $noRebootColRules = New-Object System.Collections.ArrayList
        $rebootColRules = New-Object System.Collections.ArrayList
        foreach ($mwCollectionID in $mwCollectionIDs) {
            $query = "select * from sms_collection where collectionID = '$mwCollectionID'"
            $collection = Get-WmiObject -Query $query @WMIQueryParameters
            $includeRule = ([WMIClass]"//$($SCCMConnectionInfo.ComputerName)/$($SCCMConnectionInfo.NameSpace):SMS_CollectionRuleIncludeCollection").CreateInstance()
            $includeRule.IncludeCollectionID = $mwCollectionID
            $includeRule.RuleName = $collection.Name
            if ($collection.Name -match 'NoRe' -or $collection.Name -match 'No Reboot') {
                if ($logEntries) {
                    New-CMNLogEntry -entry "Adding $($collection.Name) ($($collection.CollectionID)) to noReboot rules" -type 1 @NewLogEntry
                }
                $noRebootColRules.Add($includeRule) 
            }
            elseif ($collection.name -notmatch 'Do Not Patch') {
                if ($logEntries) {
                    New-CMNLogEntry -entry "Adding $($collection.Name) ($($collection.CollectionID)) to reboot rules" -type 1 @NewLogEntry
                }
                $rebootColRules.Add($includeRule) 
            }
        } #End foreach($mwCollectionID in $mwCollectionIDs)

        #Cycle throgh and verify/create reboot/noreboot collections
        if ($logEntries) {
            New-CMNLogEntry -entry 'Updating Deploy to collections with new include rules' -type 1 @NewLogEntry
        }
        foreach ($deployToCollectionID in $deployToCollectionIDs) {
            $query = "Select * from SMS_Collection where CollectionID = '$deployToCollectionID'"
            $collection = Get-WmiObject -Query $query @WMIQueryParameters
            if ($logEntries) {
                New-CMNLogEntry -entry "Processing $($collection.Name)" -type 1 @NewLogEntry
            }

            #if we don't get a collection, we've got a problem
            if ($collection) {
                $rebootCollectionName = "$($collection.Name) - Reboot"
                $noRebootCollectionName = "$($collection.Name) - NoReboot"
                #See if Reboot Collection Exists
                $query = "Select * from SMS_Collection where Name = '$rebootCollectionName'"
                $rebootCollection = Get-WmiObject -Query $query @WMIQueryParameters
                if (-not($rebootCollection)) {
                    if ($logEntries) {
                        New-CMNLogEntry -entry "$rebootCollectionName doesn't exist, creating." -type 1 @NewLogEntry
                    }
                    $rebootCollection = New-CMNDeviceCollection -SCCMConnectionInfo $SCCMConnectionInfo -limitToCollectionID $collection.CollectionID -name $rebootCollectionName -comment 'Created by script'
                    Move-CMNObject -SCCMConnectionInfo $SCCMConnectionInfo -objectID $rebootCollection.CollectionID -destinationContainerID $DeploymentRebootFolderID -objectType SMS_Collection_Device
                }

                #See if NoReboot Collection Exists
                $query = "Select * from SMS_Collection where name = '$noRebootCollectionName'"
                $noRebootCollection = Get-WmiObject -Query $query @WMIQueryParameters
                if (-not($noRebootCollection)) {
                    if ($logEntries) {
                        New-CMNLogEntry -entry "$noRebootCollectionName doesn't exist, creating." -type 1 @NewLogEntry
                    }
                    $noRebootCollection = New-CMNDeviceCollection -SCCMConnectionInfo $SCCMConnectionInfo -limitToCollectionID $collection.CollectionID -name $noRebootCollectionName -comment 'Created by script'
                    Move-CMNObject -SCCMConnectionInfo $SCCMConnectionInfo -objectID $noRebootCollection.CollectionID -destinationContainerID $deploymentNoRebootFolderID -objectType SMS_Collection_Device
                }

                if ($logEntries) {
                    New-CMNLogEntry -entry "Adding rules to $rebootCollectionName" -type 1 @NewLogEntry
                }
                $rebootCollection.get()
                $rebootCollection.AddMemberShipRules($rebootColRules) 

                if ($logEntries) {
                    New-CMNLogEntry -entry "Adding rules to $noRebootCollectionName" -type 1 @NewLogEntry
                }
                $noRebootCollection.get()
                $noRebootCollection.AddMemberShipRules($noRebootColRules) 
            } #End if($collection)
        } #End foreach($deployToCollectionID in $deployToCollectionIDs)
    }

    End {
        #Finished!!
        if ($logEntries) {
            New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry
        }
    }
} #End Import-CMNMainteananceWindowCollections

Function Set-CMNServerDayCollections {
    <#
    .SYNOPSIS

    .DESCRIPTION
        All my functions assume you are using the Get-CMNSCCMConnectoinInfo and New-CMNLogEntry functions for these scripts,
        please make sure you account for that.

    .PARAMETER sccmConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNsccmConnectionInfo in a variable and passing that variable.

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    yyyy-mm-dd
        Updated:
        PSVer:	    3.0
        Version:    1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Limiting Collection ID')]
        [String]$limitingCollectionID,

        [Parameter(Mandatory = $true, HelpMessage = 'Maintenance Container ID')]
        [Int]$maintenanceWindowContainerID,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {
            $logEntries = $true
        }
        else {
            $logEntries = $false
        }

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Set-CMNServerDayCollections';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        # Create a hashtable with your output info
        $returnHashTable = @{ }

        if ($logEntries) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "limitingCollectionID = $limitingCollectionID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maintenanceWindowContainerID = $maintenanceWindowContainerID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($logEntries) {
            New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        }

        if ($PSCmdlet.ShouldProcess($maintenanceWindowContainerID)) {
            #Make sure the NWS Patch Management\Servers By Patch Day folder exists
            $serverByPatchDayContainerID = Get-CMNObjectContainerNodeIDbyName -sccmConnectionInfo $sccmConnectionInfo -Name 'NWS Patch Management\Servers By Patch Day' -ObjectType SMS_Collection_Device -logFile $logFile -logEntries -ErrorAction SilentlyContinue
            if ($serverByPatchDayContainerID -eq 0 -or $serverByPatchDayContainerID -eq $null) {
                New-CMNLogEntry -entry "NWS Patch Management\Servers By Patch Day folder does not exist, please create" -type 3 @NewLogEntry
                throw "NWS Patch Management\Servers By Patch Day folder does not exist, please create"
            }
            else {
                New-CMNLogEntry -entry "PatchDay container ID $serverByPatchDayContainerID" -type 1 @NewLogEntry
            }

            #Delete all collections in folder
            $collectionIDs = Get-CMNObjectIDsBelowFolder -sccmConnectionInfo $sccmConnectionInfo -parentContainerNodeID $serverByPatchDayContainerID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
            foreach ($collectionID in $collectionIDs) {
                Remove-CMNCollection -sccmConnectionInfo $sccmConnectionInfo -collectionID $collectionID -logFile $logFile -logEntries -doForce
            }
            $limitingCollection = Get-CimInstance -query "Select * from SMS_Collection where CollectionID = '$limitingCollectionID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
            $limitingCollection = $limitingCollection | Get-CimInstance
            if (!$limitingCollection) {
                New-CMNLogEntry -entry 'No limiting collection, please create.' -type 3 @NewLogEntry
                throw 'No limiting collection, please create.'
            }

            $collectionIDs = Get-CMNObjectIDsBelowFolder -sccmConnectionInfo $sccmConnectionInfo -parentContainerNodeID $maintenanceWindowContainerID -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
            $htAllGroups = @{ }
            $htServerGroups = @{ }
            $htManualGroups = @{ }

            foreach ($collectionID in $collectionIDs) {
                New-CMNLogEntry -entry "Processing $collectionID" -type 1 @NewLogEntry
                $collection = Get-CimInstance -Query "Select * from SMS_Collection where CollectionID = '$collectionID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
                if ($collection.Name -match '^PD(\d+)') {
                    [Int]$day = ($collection.Name -replace 'PD(\d+).*', '$1')
                    $Start = $Collection.Name.Substring(9, 4)
                    $End = $Collection.Name.Substring(14, 4)
                    if ($Start -eq '0000' -or $End -eq '0600') {
                        $Day--
                    }

                    #Create All Prod Groups (PD11+)
                    if ($day -ge 11) {
                        New-CMNLogEntry -entry "Adding $collectionID to All Prod Groups" -type 1 @NewLogEntry
                        $htAllGroups['Prod'] += [array]$collectionID
                    }

                    #Create All TDQA Groups (PD10-)
                    if ($day -le 10) {
                        New-CMNLogEntry -entry "Adding $collectionID to All TDQA Groups" -type 1 @NewLogEntry
                        $htAllGroups['TDQA'] += [array]$collectionID
                    }

                    #Create All Server Groups by Day
                    New-CMNLogEntry -entry "Adding $collectionID to PD$day All Servers" -type 1 @NewLogEntry
                    $htServerGroups[$day] += [array]$collectionID

                    #Create All Manual Groups By Day}
                    if ($collection.Name -match 'Manual') {
                        New-CMNLogEntry -entry "Adding $collectionID to PD$day All Manuals" -type 1 @NewLogEntry
                        $htManualGroups[$day] += [array]$collectionID
                    }
                }
                else {
                    New-CMNLogEntry -entry "$($collection.Name) is not added" -type 2 @NewLogEntry
                }
            }

            #Time to build All Servers collections
            foreach ($allProdGroups in $htServerGroups.GetEnumerator()) {
                $colName = "PD$($allProdGroups.Name.ToString("00")) - All Servers"
                New-CMNLogEntry -entry "Creating colleciton $colName" -type 1 @NewLogEntry
                $allProdCollection = New-CMNDeviceCollection -sccmConnectionInfo $sccmConnectionInfo -comment 'All Prod Server collection' -limitToCollectionID $limitingCollectionID -name $colName
                Move-CMNObject -sccmConnectionInfo $sccmConnectionInfo -objectID $allProdCollection.CollectionID -destinationContainerID $serverByPatchDayContainerID -objectType SMS_Collection_Device
                foreach ($colID in $allProdGroups.value) {
                    New-CMNLogEntry -entry "Adding include rule for collection $colID" -type 1 @NewLogEntry
                    New-CMNDeviceCollectionIncludeRule -sccmConnectionInfo $sccmConnectionInfo -CollectionID $allProdCollection.CollectionID -includeCollectionID $colID -ruleName $colID -logFile $logFile -logEntries 
                }
            }

            #Time to build All Manuals collections
            foreach ($allManualGroups in $htManualGroups.GetEnumerator()) {
                $colName = "PD$($allManualGroups.Name.ToString("00")) - All Manuals"
                New-CMNLogEntry -entry "Creating colleciton $colName" -type 1 @NewLogEntry
                $allManualCollection = New-CMNDeviceCollection -sccmConnectionInfo $sccmConnectionInfo -comment 'All Prod Server collection' -limitToCollectionID $limitingCollectionID -name $colName
                Move-CMNObject -sccmConnectionInfo $sccmConnectionInfo -objectID $allManualCollection.CollectionID -destinationContainerID $serverByPatchDayContainerID -objectType SMS_Collection_Device
                foreach ($colID in $allManualGroups.value) {
                    New-CMNLogEntry -entry "Adding include rule for collection $colID" -type 1 @NewLogEntry
                    New-CMNDeviceCollectionIncludeRule -sccmConnectionInfo $sccmConnectionInfo -CollectionID $allManualCollection.CollectionID -includeCollectionID $colID -ruleName $colID -logFile $logFile -logEntries 
                }
            }

            #Time to build All Prod/TDQA Servers collections
            foreach ($group in $htAllGroups.GetEnumerator()) {
                $colName = "All $($group.Name) Servers"
                New-CMNLogEntry -entry "Creating colleciton $colName" -type 1 @NewLogEntry
                $allProdCollection = New-CMNDeviceCollection -sccmConnectionInfo $sccmConnectionInfo -comment 'All Prod Server collection' -limitToCollectionID $limitingCollectionID -name $colName
                Move-CMNObject -sccmConnectionInfo $sccmConnectionInfo -objectID $allProdCollection.CollectionID -destinationContainerID $serverByPatchDayContainerID -objectType SMS_Collection_Device
                foreach ($colID in $group.value) {
                    New-CMNLogEntry -entry "Adding include rule for collection $colID" -type 1 @NewLogEntry
                    New-CMNDeviceCollectionIncludeRule -sccmConnectionInfo $sccmConnectionInfo -CollectionID $allProdCollection.CollectionID -includeCollectionID $colID -ruleName $colID -logFile $logFile -logEntries 
                }
            }
        }
    }

    End {
        if ($logEntries) {
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj
    }
} #End Set-CMNServerDayCollections

$LogFile = 'C:\Temp\Import-CMNMainteananceWindowCollections.log'
$file = 'http://teams.humana.com/sites/NWO/NWO%20Doc%20Library/SCCM/SCCM%20-%20Device%20Collections%20-%204%20Hour.xlsm'
$DestinationMWContainer = 'Maintenance Windows'
$DeploymentFolder = 'NWS Patch Management\Deploy to Collections'

#SP1 Information
$lmtgCollectionID = 'SP100020'
$RebootPackageID = 'SP10000D'
$InvokeUpdatesPackageID = 'SP100229'
$SCCMCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1825
$destinationMWContainerID = Get-CMNObjectContainerNodeIDbyName -sccmConnectionInfo $SCCMCon -Name $DestinationMWContainer -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
Import-CMNMainteananceWindowCollections -SCCMConnectionInfo $SCCMCon -file $file -limitingCollectionID $lmtgCollectionID -RebootPackageID $RebootPackageID -DestinationMWContainer $DestinationMWContainer -DeploymentFolder $DeploymentFolder -collectionColumn 1 -nameColumn 2 -logFile $LogFile -logEntries -showProgress -InvokeUpdatesPackageID $InvokeUpdatesPackageID -NumberofMWs 1
Set-CMNServerDayCollections -sccmConnectionInfo $SCCMCon -limitingCollectionID $lmtgCollectionID -maintenanceWindowContainerID $destinationMWContainerID -logFile $logFile -logEntries

<# 
    Removing SQ1 from this script per Jeff Kinjerski's request
    #SQ1 Information
    $lmtgCollectionID = 'SQ100022'
    $RebootPackageID = 'SQ10000C'
    $SCCMCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWQS1150
    $destinationMWContainerID = Get-CMNObjectContainerNodeIDbyName -sccmConnectionInfo $SCCMCon -Name $DestinationMWContainer -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
    Import-CMNMainteananceWindowCollections -SCCMConnectionInfo $SCCMCon -file $file -limitingCollectionID $lmtgCollectionID -RebootPackageID $RebootPackageID -DestinationMWContainer $DestinationMWContainer -DeploymentFolder $DeploymentFolder -collectionColumn 1 -nameColumn 2 -logFile $LogFile -logEntries -showProgress -NumberofMWs 1
    Set-CMNServerDayCollections -sccmConnectionInfo $SCCMCon -limitingCollectionID $lmtgCollectionID -maintenanceWindowContainerID $destinationMWContainerID -logFile $logFile -logEntries
#>

#WQ1 Information
$lmtgCollectionID = 'WQ100649'
$RebootPackageID = 'SQ10000C'
$SCCMCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWQS1151
$destinationMWContainerID = Get-CMNObjectContainerNodeIDbyName -sccmConnectionInfo $SCCMCon -Name $DestinationMWContainer -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
Import-CMNMainteananceWindowCollections -SCCMConnectionInfo $SCCMCon -file $file -limitingCollectionID $lmtgCollectionID -RebootPackageID $RebootPackageID -DestinationMWContainer $DestinationMWContainer -DeploymentFolder $DeploymentFolder -collectionColumn 1 -nameColumn 2 -logFile $LogFile -logEntries -showProgress -NumberofMWs 1
Set-CMNServerDayCollections -sccmConnectionInfo $SCCMCon -limitingCollectionID $lmtgCollectionID -maintenanceWindowContainerID $destinationMWContainerID -logFile $logFile -logEntries

#WP1 Information
$lmtgCollectionID = 'WP100035'
$RebootPackageID = 'WP100121'
$SCCMCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1658
$destinationMWContainerID = Get-CMNObjectContainerNodeIDbyName -sccmConnectionInfo $SCCMCon -Name $DestinationMWContainer -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
Import-CMNMainteananceWindowCollections -SCCMConnectionInfo $SCCMCon -file $file -limitingCollectionID $lmtgCollectionID -RebootPackageID $RebootPackageID -DestinationMWContainer $DestinationMWContainer -DeploymentFolder $DeploymentFolder -collectionColumn 1 -nameColumn 2 -logFile $LogFile -logEntries -showProgress -NumberofMWs 1
Set-CMNServerDayCollections -sccmConnectionInfo $SCCMCon -limitingCollectionID $lmtgCollectionID -maintenanceWindowContainerID $destinationMWContainerID -logFile $logFile -logEntries

<#
    Removing MT1, but leaving code for ad-hoc runs and testing
    If a server ends up in MT1 it is going to have a nightly MW. Scream test!

    #MT1 Info
    $SCCMCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWTS1441
    $lmtgCollectionID = 'SMS00001'
    $RebootPackageID = 'MT100014'
    $InvokeUpdatesPackageID = 'MT10006A'
    $destinationMWContainerID = Get-CMNObjectContainerNodeIDbyName -sccmConnectionInfo $SCCMCon -Name $DestinationMWContainer -ObjectType SMS_Collection_Device -logFile $logFile -logEntries
    Import-CMNMainteananceWindowCollections -SCCMConnectionInfo $SCCMCon -file $file -limitingCollectionID $lmtgCollectionID -RebootPackageID $RebootPackageID -DestinationMWContainer $DestinationMWContainer -DeploymentFolder $DeploymentFolder -collectionColumn 1 -nameColumn 2 -logFile $LogFile -logEntries -showProgress -InvokeUpdatesPackageID $InvokeUpdatesPackageID -NumberofMWs 1
    Set-CMNServerDayCollections -sccmConnectionInfo $SCCMCon -limitingCollectionID $lmtgCollectionID -maintenanceWindowContainerID $destinationMWContainerID -logFile $logFile -logEntries
#>