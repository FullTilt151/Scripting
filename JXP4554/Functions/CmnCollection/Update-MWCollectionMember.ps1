Function Update-MWCollectionMember {
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
		FileName:    Update-MWCollectionMember.ps1
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2016-03-22
		Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, 
        ConfirmImpact = 'Low')]
	
    PARAM(
        [Parameter(Mandatory = $true,
            HelpMessage = 'Collection Name',
            Position = 1)]
        [String]$collectionName,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Machine Name',
            Position = 2)]
        [String]$machineName,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 3)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 4)]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size',
            Position = 5)]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs',
            Position = 6)]
        [Int32]$maxHistory = 5
    )

    Begin {
        # Disable Fast parameter usage check for Lazy properties
        #Build splat for log entries 
        $NewLogEntry = @{
            LogFile    = $logFile;
            Component  = 'Update-MWCollectionMember';
            maxLogSize = $maxLogSize;
            maxHistory = $maxHistory;
        }
        #$sites = ('LOUAPPWPS875','LOUAPPWPS1825')
        $sites = ('LOUAPPWQS1150')
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "collectionName = $collectionName" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "machineName = $machineName" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
        }
    }
	
    Process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        # Main code part goes here
        # Cycle through sites
        foreach ($site in $sites) {
            # Prep for site
            $SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer $site
            # Build splats for WMIQueries
            $WMIQueryParameters = @{
                ComputerName = $SCCMConnectionInfo.ComputerName;
                NameSpace    = $SCCMConnectionInfo.NameSpace;
            }
            if ($PSBoundParameters['logEntries']) {$destinationContainerID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name 'Maintenance Windows' -ObjectType SMS_Collection_Device -logFile $logFile -logEntries}
            else {$destinationContainerID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMConnectionInfo -Name 'Maintenance Windows' -ObjectType SMS_Collection_Device}

            if ($destinationContainerID -eq 0) {
                if ($PSBoundParameters['logEntries']) {
                    New-CMNLogEntry -entry "The Maintenance Window folder is missing in $($SCCMConnectionInfo.SiteCode)" -type 3 @NewLogEntry
                }
                Throw "The Maintenance Window folder is missing in $($SCCMConnectionInfo.SiteCode)"
            }
            # $query = "Select * from SMS_R_System"
            switch ($SCCMConnectionInfo.SiteCode) {
                'CAS' {
                    $query = "Select * from SMS_Collection where CollectionID = 'CAS0191C'"
                    $LimitingCollection = Get-WmiObject -Query $query @WMIQueryParameters
                }
                'SP1' {
                    $query = "Select * from SMS_Collection where CollectionID = 'SP100020'"
                    $LimitingCollection = Get-WmiObject -Query $query @WMIQueryParameters
                }
                'SQ1' {
                    $query = "Select * from SMS_Collection where CollectionID = 'SQ100022'"
                    $LimitingCollection = Get-WmiObject -Query $query @WMIQueryParameters
                }
            }

            # Verify destination collection exists
            $query = "SELECT * from SMS_Collection where Name = '$collectionName'"
            $destinationCollection = Get-WmiObject -Query $query @WMIQueryParameters
            if (-not($destinationCollection)) {
                # Doesn't exist, need to create and move to Maintenance window folder
                if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Creating collection $collectionName." -type 1 @NewLogEntry}
                $SCCMCollection = ([WMIClass]"\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_Collection").CreateInstance()
                $SCCMCollection.CollectionType = 2
                $SCCMCollection.Name = $collectionName
                $SCCMCollection.LimitToCollectionID = ($LimitingCollection.CollectionID)
                $SCCMCollection.LimitToCollectionName = ($LimitingCollection.Name)
                $SCCMCollection.Put() | Out-Null
                $SCCMCollection.Get()
                #[Array]$DeviceCollectionID = ($SCCMCollection.CollectionID)
                $TargetFolderID = ($destinationContainerID)
                Invoke-WmiMethod -Class SMS_ObjectContainerItem -Name MoveMembers -ArgumentList 0, $($SCCMCollection.CollectionID), 5000, ($destinationContainerID) @WMIQueryParameters
            }
            # Find all collections server is in under the Maintenance window folder and remove
            if ($PSBoundParameters['logEntries']) {$mwCollectionIDS = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $destinationContainerID -ObjectType SMS_Collection_Device -Recurse -logFile $logFile -logEntries}
            else {$mwCollectionIDS = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMConnectionInfo -parentContainerNodeID $destinationContainerID -ObjectType SMS_Collection_Device -Recurse}

			
            # Add server to collection provided
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Update-MWCollectionMember

Update-MWCollectionMember -collectionName  -machineName 'LTLATSWTX40' -logFile 'C:\Temp\Update-MWCollectionMember.log' -logEntries