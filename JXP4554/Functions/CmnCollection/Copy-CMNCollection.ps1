Function Copy-CMNCollection {
    <#
	.SYNOPSIS
		Copies collection from one site to another

	.DESCRIPTION
		This function will copy the collections from the source site to the desitnation site

	.PARAMETER sourceConnection
		This is a PSObject that is the result of Get-CMNSCCMConnectionInfo pointing to the source site server

	.PARAMETER destinationConnection
		This is a PSObject that is the result of Get-CMNSCCMConnectionInfo pointing to the destination site server

	.PARAMETER collectionIDs
		Array of Collection IDs to be copied from the source to the destination site

	.PARAMETER MatchByName
		If set, collections will be matched by names, not collection ID's.

	.PARAMETER overWriteExisting
		Switch to signal if we should overwrite the collection in the destination site if it exists

	.PARAMETER logFile
		File for writing logs to

	.PARAMETER logEntries
		Switch to say whether or not to create a log file

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.PARAMETER maxLogHistory
			Specifies the number of history log files to keep, default is 5

	.EXAMPLE
		Copy-CMNCollection -sourceConnectionInfo $SP1ConnectionInfo -destinationConnectionInfo $SP2Connection Info -collectionIDs 'SP100334', 'SP100335' -overWriteExisting

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	    Jim Parris
		Email:	    Jim@ConfigMan-Notes
		Date:	    8/12/2016
		PSVer:	    2.0/3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'Source SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sourceConnection,

        [Parameter(Mandatory = $true, HelpMessage = 'Destination SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$destinationConnection,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'CollectionID(s) you want to copy')]
        [string[]]$collectionIDs,

        [Parameter(Mandatory = $false, HelpMessage = 'If set, collections are matched by name, otherwise by CollectionID')]
        [Switch]$matchByName,

        [Parameter(Mandatory = $false, HelpMessage = 'Overwrite Existing Collection')]
        [Switch]$overWriteExisting,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5
    )

    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'FunctionName';
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMISourceQueryParameters = @{
            ComputerName = $sourceConnection.ComputerName;
            NameSpace = $sourceConnection.NameSpace;
        }
        $WMIDestinationQueryParameters = @{
            ComputerName = $destinationConnection.ComputerName;
            NameSpace = $destinationConnection.NameSpace;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "sourceConnection = $sourceConnection" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "destinationConnection = $destinationConnection" -type 1 @NewLogEntry
            foreach ($collectionID in $collectionIDs) {
                New-CMNLogEntry -entry "collectionID = $collectionID" -type 1 @NewLogEntry
            }
            New-CMNLogEntry -entry "matchByName = $matchByName" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning process loop' -Type 1 @NewLogEntry}

        foreach ($collectionID in $collectionIDs) {
            $sourceCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$collectionID'" @WMISourceQueryParameters
            $sourceCollection.get()
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Processing $($sourceCollection.Name)" -Type 1 @NewLogEntry}

            if ($PSCmdlet.ShouldProcess($sourceCollection.Name)) {
                #note if collection already exists
                if ($matchByName) {$query = "select * from SMS_Collection where Name = '$($sourceCollection.Name)'"}
                else {$query = "select * from SMS_Collection where CollectionID = '$collectionID'"}
                $destinationCollection = Get-WmiObject -Query $query @WMIDestinationQueryParameters
                if ($destinationCollection) {$isCollectionExist = $true}
                else {$isCollectionExist = $false}
                if ($isCollectionExist -and -not($overWriteExisting)) {
                    if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Collection $($destinationCollection.Name) already exists" -type 3 @NewLogEntry}
                    Write-Error "Collection $($destinationCollection.Name) already exists"
                }
                else {
                    #Get limiting colleciton info
                    $query = "Select * from SMS_Collection where CollectionID = '$($sourceCollection.LimitToCollectionID)'"
                    $sourceLimitingCollection = Get-WmiObject -Query $query @WMISourceQueryParameters
                    $sourceLimitingCollection.get()
                    $filterName = [regex]::Replace($sourceLimitingCollection.Name, '(?<SingleQuote>'')', '\${SingleQuote}')
                    $query = "Select * from SMS_Collection where Name  = '$filterName'"
                    $destinationLimitingCollection = Get-WmiObject -Query $query @WMIDestinationQueryParameters
                    $destinationLimitingCollection.get()

                    if (-not($destinationLimitingCollection)) {
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'No matching limiting collection' -type 3 @NewLogEntry}
                        Write-Error 'No matching limiting collection'
                    }

                    if ($destinationLimitingCollection.count -gt 1) {
                        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Ambiguious limiting collection' -type 3 @NewLogEntry}
                        Write-Error 'Ambiguious limiting collection'
                    }

                    #Create collection in destination site
                    if (-not ($isCollectionExist)) {
                        $destinationCollection = ([WMIClass]"\\$($destinationConnection.ComputerName)\Root\sms\site_$($destinationConnection.SiteCode):SMS_Collection").CreateInstance()
                        $destinationCollection.CollectionID = $sourceCollection.CollectionID
                    }
                    #Copy properties
                    $destinationCollection.CollectionType = $sourceCollection.CollectionType
                    $destinationCollection.Comment = $sourceCollection.Comment
                    $destinationCollection.LimitToCollectionID = $destinationLimitingCollection.CollectionID
                    $destinationCollection.LimitToCollectionName = $destinationLimitingCollection.Name
                    $destinationCollection.MonitoringFlags = $sourceCollection.MonitoringFlags
                    $destinationCollection.Name = $sourceCollection.Name
                    if ($sourceCollection.RefreshType -ne 1) {$destinationCollection.RefreshSchedule = $sourceCollection.RefreshSchedule}
                    $destinationCollection.RefreshType = $sourceCollection.RefreshType

                    $destinationCollection.Put() | Out-Null

                    #Copy Collection Rules
                    foreach ($collectionRule in $sourceCollection.CollectionRules) {
                        if ($collectionRule.QueryID -gt 0) {
                            #We have a query rule, time to create
                            New-CMNDeviceCollectionQueryMemberRule -SCCMConnectionInfo $destinationConnection -CollectionID ($destinationCollection.CollectionID) -query ($collectionRule.QueryExpression) -ruleName ($collectionRule.RuleName) -logFile $logFile -logEntries:$logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
                        }
                        elseif ($collectionRule.IncludeCollectionID -gt 0) {
                            #We have a include rule, time to create
                            New-CMNDeviceCollectionIncludeRule -SCCMConnectionInfo $destinationConnection -CollectionID ($destinationCollection.CollectionID) -includeCollectionID ($collectionRule.IncludeCollectionID) -ruleName ($collectionRule.RuleName) -logFile $logFile -logEntries $logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
                        }
                        elseif ($collectionRule.ExcludeCollectionID -gt 0) {
                            New-CMNDeviceCollectionExcludeRule -SCCMConnectionInfo $destinationConnection -CollectionID ($destinationCollection.CollectionID) -excludeCollectionID ($collectionRule.ExcludeCollectionID) -ruleName ($collectionRule.RuleName) -logFile $logFile -logEntries $logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
                        }
                        else {
                            New-CMNDeviceCollectionDirectMemberRule -SCCMConnectionInfo $destinationConnection -CollectionID $destinationCollection.CollectionID -NetbiosNames $collectionRule.RuleName -logFile $logFile -logEntries $logEntries -maxLogSize $maxLogSize -maxLogHistory $maxLogHistory
                        }
                    }
                }
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Finish Function' -type 1 @NewLogEntry}
    }
} #End Copy-CMNCollection
