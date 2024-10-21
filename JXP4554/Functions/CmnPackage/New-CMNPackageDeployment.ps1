Function New-CMNPackageDeployment {
    <#
		.SYNOPSIS
            Creates a new package deployment

		.DESCRIPTION
            Creates a new package deployment.

		.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

        .PARAMETER packageID
            Package ID in source site

        .PARAMETER programName
            Program name to be used in the deployment

        .PARAMETER collectionID
            Destination collection ID

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.PARAMETER maxLogSize
			Max size for the log. Defaults to 5MB.

		.PARAMETER maxLogHistory
				Specifies the number of history log files to keep, default is 5

		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES
			FileName:    New-CMNPackageDeployment.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2016-03-22
			Updated:     2016-03-22
			Version:     1.0.0

            SMS_Advertisement
            SMS_Package
            SMS_Program
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Source SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'package ID')]
        [String]$packageID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Program Name')]
        [String]$programName,

        [Parameter(Mandatory = $true,
            HelpMessage = 'collection ID')]
        [String]$collectionID,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Comment')]
        [String]$comment,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Available time')]
        [Alias('startTime')]
        [DateTime]$availableTime = $(get-date),

        [Parameter(Mandatory = $false,
            HelpMessage = 'Time to expire deployment')]
        [DateTime]$expireTime,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Array of runtimes for the schedule')]
        [DateTime[]]$runTimes,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Override maintenance windows')]
        [Switch]$overRideMaintenanceWindow,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Reboot outside of maintenance windows')]
        [Switch]$rebootOutsideMaintenanceWindow,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Run From DP')]
        [Switch]$rdp,

        [Parameter(Mandatory = $false,
            HelpMessage = "Rerun mode, valid options are 'Always Rerurn', 'Rerun if Failed', and 'Never Rerun'")]
        [ValidateSet('Always Rerun', 'Rerun if Failed', 'Never Rerun')]
        [String]$reRunMode = 'Rerun if Failed',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Remove existing deployment if present')]
        [Switch]$replaceExisting,

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
        [Int32]$maxLogHistory = 5
    )

    begin {
        $NewLogEntry = @{
            logFile = $logFile;
            component = 'New-CMNPackageDeployment';
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace = $sccmConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['clearLog']) {if (Test-Path -Path $logFile) {Remove-Item -Path $logFile}}
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "availableTime = $availableTime" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "collectionID = $collectionID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "comment = $comment" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "expireTime = $expireTime" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "overRideMaintenanceWindow = $overRideMaintenanceWindow" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "packageID = $packageID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "rebootOutsideMaintenanceWindow = $rebootOutsideMaintenanceWindow" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "rdp = $rdp" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "reRunMode = $reRunMode" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "replaceExisting = $replaceExisting" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "runTimes = $runTimes" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        if ($PSCmdlet.ShouldProcess($packageID)) {
            #Verify package
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Verifying package' -type 1 @NewLogEntry}
            $query = "Select * from SMS_Package where PackageID = '$packageID'"
            $package = Get-WmiObject -Query $query @WMIQueryParameters
            if ($package) {
                #Verify program
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Package exists, checking that program exists' -type 1 @NewLogEntry}
                $query = "SELECT * from SMS_Program where PackageID = '$packageID' and ProgramName = '$programName'"
                $program = Get-WmiObject -Query $query @WMIQueryParameters
                if ($program) {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Program exists, checking if deployment already exists' -type 1 @NewLogEntry}
                    $query = "Select * from SMS_Advertisement where CollectionID = '$collectionID' and PackageID = '$packageID' and ProgramName = '$programName'"
                    $deployment = Get-WmiObject -Query $query @WMIQueryParameters
                    if (-not ($deployment) -or $PSBoundParameters['replaceExisting']) {
                        if ($deployment -and $PSBoundParameters['replaceExisting']) {
                            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Deployment exists, but is being replaced. Removing and verifying collection exist' -type 2 @NewLogEntry}
                            $result = $deployment | Remove-WmiObject
                            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Results = $result" -type 2 @NewLogEntry}
                        }
                        else {
                            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Deployment does not exist, verifying collection exists' -type 1 @NewLogEntry}
                        }
                        $query = "Select * from SMS_Collection where CollectionID = '$collectionID'"
                        $collection = Get-WmiObject -Query $query @WMIQueryParameters
                        if ($collection) {
                            $deploymentName = "$($package.Name) ($($package.PackageID)) - $($collection.Name) ($($collection.CollectionID))"
                            #Create deployment
                            $deployment = ([WMIClass]"\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_Advertisement").CreateInstance()
                            #set advertFlags
                            #user can not run independent of assignment
                            $advertFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName NO_DISPLAY -CurrentValue 0
                            #mandatory over slow networks
                            $advertFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName ONSLOWNET -CurrentValue $advertFlags
                            #if requested, override maintenance window
                            if ($PSBoundParameters['overRideMaintenanceWindow']) {$advertFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName OVERRIDE_SERVICE_WINDOWS -CurrentValue $advertFlags}
                            #if requested, reboot outside of maintenance window
                            if ($PSBoundParameters['rebootOutsideMaintenanceWindow']) {$advertFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_AdvertFlags -KeyName REBOOT_OUTSIDE_OF_SERVICE_WINDOWS -CurrentValue $advertFlags}
                            $deployment.AdvertFlags = $advertFlags
                            $deployment.AdvertisementName = $deploymentName
                            foreach ($runTime in $runTimes) {
                                $ScheduleTime = ([WMIClass] "\\$($sccmConnectionInfo.ComputerName)\$($sccmConnectionInfo.NameSpace):SMS_ST_NonRecurring").CreateInstance()
                                $ScheduleTime.DayDuration = 0
                                $ScheduleTime.HourDuration = 0
                                $ScheduleTime.IsGMT = $false
                                $ScheduleTime.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-date $runTime -Format G))
                                $deployment.AssignedSchedule += $ScheduleTime
                            }
                            $deployment.AssignedScheduleEnabled = $true
                            $deployment.AssignedScheduleIsGMT = $false
                            $deployment.CollectionID = $collectionID
                            $deployment.Comment = $comment
                            if ($expireTime) {
                                $deployment.ExpirationTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((get-date $expireTime -Format G))
                                $deployment.ExpirationTimeEnabled = $true
                            }
                            $deployment.PackageID = $packageID
                            $deployment.PresentTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-date $availableTime -Format G))
                            $deployment.PresentTimeEnabled = $true
                            $deployment.PresentTimeIsGMT = $false
                            $deployment.Priority = 2
                            $deployment.ProgramName = $programName
                            #set RemoteClientFlags
                            #if run from dp
                            if ($PSBoundParameters['rdp']) {
                                $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RUN_FROM_LOCAL_DISPPOINT -CurrentValue 0
                                $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RUN_FROM_REMOTE_DISPPOINT -CurrentValue $remoteClientFlags
                            }
                            else {
                                $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName DOWNLOAD_FROM_LOCAL_DISPPOINT -CurrentValue 0
                                $remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName DOWNLOAD_FROM_REMOTE_DISPPOINT -CurrentValue $remoteClientFlags
                            }
                            switch ($reRunMode) {
                                'Always Rerurn' {$remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RERUN_ALWAYS -CurrentValue $remoteClientFlags}
                                'Rerun if Failed' {$remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RERUN_IF_FAILED -CurrentValue $remoteClientFlags}
                                'Never Rerun' {$remoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName RERUN_NEVER -CurrentValue $remoteClientFlags}
                            }
                            $deployment.RemoteClientFlags = $remoteClientFlags
                            #set TimeFlags
                            $timeFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_TimeFlags -KeyName ENABLE_PRESENT -CurrentValue 0
                            $timeFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_TimeFlags -KeyName ENABLE_MANDATORY -CurrentValue $timeFlags
                            $deployment.TimeFlags = $timeFlags
                            $deployment.Put() | Out-Null
                        }
                        else {
                            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Collection $collectionID does not exist" -type 3 @NewLogEntry}
                        }
                    }
                    else {
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Deployment already exists on collection $collectionID" -type 2 @NewLogEntry}
                        Throw 'Already exists'
                    }
                }
                else {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Program does not exist on source package' -type 3 @NewLogEntry}
                    Throw 'Program does not exist on source'
                }
            }
            else {
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Package $srcPackageID does not exist on source" -type 3 @NewLogEntry}
                Throw 'Source Package does not exist'
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End New-CMNPackageDeployment
