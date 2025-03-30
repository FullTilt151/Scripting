Function Get-CMNComputerNamesInCollection {
    <#
    .SYNOPSIS
        This will return all the machine names in a collection

    .DESCRIPTION
        This will return all the machine names in a collection

    .PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

    .PARAMETER collectionID
        This is the collectionID to pull the names from.
        
    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	
        Updated:    yyyy-mm-dd
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$SCCMConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'CollectionID to get machine names from')]
        [ValidateLength(8, 8)]
        [String]$collectionID,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxHistory = 5
    )

    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile    = $logFile;
            Component  = 'Get-CMNComputerNamesInCollection';
            maxLogSize = $maxLogSize;
            maxHistory = $maxHistory;
        }

        #Build splat for WMIQueries
        $WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters

        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}

        if ($PSCmdlet.ShouldProcess($SCCMConnectionInfo)) {
            $query = "SELECT * FROM SMS_CM_RES_COLL_$collectionID"
            $computers = (Get-CimInstance -Query $query @WMIQueryParameters).Name
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        Return $computers
    }
} #End Get-CMNComputerNamesInCollection