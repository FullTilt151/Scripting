Function Set-CMNProgramMomAlert
 {
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
         Switch to say if we write to the log file. Otherwise, it will just be write-verbose

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

        [Parameter(Mandatory = $true, HelpMessage = 'PackageID to set on')]
        [String]$packageID,

        [Parameter(Mandatory = $false, HelpMessage = 'Program Name to set alerts on, default is * (all programs)')]
        [String]$programName = *,

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
        if ($PSBoundParameters['logEntries']) {$logEntries = $true}
        else {$logEntries = $false}

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile    = $logFile;
            Component  = 'Set-CMNProgramMomAlert
            ';
            logEntries = $logEntries;
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Build splat for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters

        # Create a hashtable with your output info
        $returnHashTable = @{}

            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry

        if ($PSCmdlet.ShouldProcess($sccmConnectionInfo)) {
            #Main code here
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End Set-CMNProgramMomAlert
