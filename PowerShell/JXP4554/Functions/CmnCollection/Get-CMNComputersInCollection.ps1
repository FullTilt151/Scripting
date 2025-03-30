Function Get-CMNComputersInCollection {
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

	.PARAMETER maxLogHistory
			Specifies the number of history log files to keep, default is 5

 	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Get-CMNComputersInCollection.ps1
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2016-03-22
		Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'CollectionID to get list of computers from')]
        [String]$CollectionID,

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
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'Get-CMNComputersInCollection';
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        if ($PSBoundParameters['showProgress']) {
            $ProgressCount = 0
        }
        # Main code part goes here
        $Query = "select ResourceID from SMS_FullCollectionMembership where CollectionID = '$CollectionID'"
        $ResourceIDs = (Get-WmiObject -Query $Query @WMIQueryParameters).ResourceID
        if ($ResourceIDs.Count -gt 0) {
            $Query = "Select * from SMS_R_SYSTEM where ResourceID in ("
            foreach ($ResourceID in $ResourceIDs) {
                $Query = "$Query'$ResourceID',"
            }
            $Query = "$($Query.Substring(0,$Query.Length - 1)))"
            $Computers = (Get-WmiObject -Query $Query @WMIQueryParameters).Name
        }
        else {$Computers = $null}
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        Return $Computers
    }
} #End Get-CMNComputersInCollection
