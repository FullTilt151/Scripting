Function Function-Name {
    <#
    .SYNOPSIS 

    .DESCRIPTION
        
    .PARAMETER computerName
        Name of computer to run function-name against

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
        Email:	    Jim@ConfigMan-Notes
        Date:	
        PSVer:	    2.0/3.0
        Updated: 
        Version:    1.0.0		
	#>
 
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    Param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'Computername to target')]
        [Alias('host')]
        [ValidateLength(3, 30)]
        [string]$computerName,

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
        # Build splat for log entries
        $NewLogEntry = @{
            LogFile    = $logFile;
            Component  = 'Function-Name';
            maxLogSize = $maxLogSize;
            maxHistory = $maxHistory;
        }
		
        # Create a hashtable with your output info
        $returnHashTable = @{}

        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "computerName = $computerName" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry}
        
        if ($PSCmdlet.ShouldProcess($computerName)) {
            # Main code here
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} # End Function-Name