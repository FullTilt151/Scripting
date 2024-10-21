Function FunctionName {
    <#
    .SYNOPSIS

    .DESCRIPTION
        Description goes here

    .PARAMETER sccmConnectionInfo
        This is a variable containing the cim session to the site server, the site code, SCCM Database Server, and SCCM Database Name. It is a result of Get-CMNSccmConnectionInfo.
        
    .PARAMETER logFile
        File for writing logs to (default is c:\temp\eror.log).

    .PARAMETER logEntries
        Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).

    .PARAMETER maxLogSize
        Max size for the log (default is 5MB).

    .PARAMETER maxLogHistory
        Specifies the number of history log files to keep (default is 5).

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

    [CmdletBinding(ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'This is a variable containing the cim session to the site server and the site code. It is a result of Get-CMNSccmConnectionInfo.')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'File for writing logs to (default is c:\temp\eror.log).')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).')]
        [Boolean]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max size for the log (default is 5MB).')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Specifies the number of history log files to keep (default is 5).')]
        [Int]$maxLogHistory = 5
    )

    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'FunctionName';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Create a hashtable with your output info
        $returnHashTable = @{ }

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        #Main code here
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End FunctionName