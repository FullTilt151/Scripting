Function Get-CMNSiteSystems {
    <#
	.SYNOPSIS
		This will return all the site systems of the role you request
 
	.DESCRIPTION
		This will return all the site systems of the role you request
 
	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of 
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER role
		Specifies the role you are searching for, valid values are:
		'SMS Application Web Service','SMS Component Server','SMS Distribution Point',
		'SMS Dmp Connector','SMS Fallback Status Point','SMS Management Point',
		'SMS Portal Web Site','SMS Site Server','SMS Software Update Point',
		'SMS SQL Server','SMS SRS Reporting Point'
		
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
		Date:     	2018-04-25
		Updated:     
        PSVer:	    3.0
		Version:    1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
	
    PARAM	(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Role you are looking for')]
        [ValidateSet('SMS Application Web Service', 'SMS Component Server', 'SMS Distribution Point', 'SMS Dmp Connector', 'SMS Fallback Status Point', 'SMS Management Point', 'SMS Portal Web Site', 'SMS Site Server', 'SMS Software Update Point', 'SMS SQL Server', 'SMS SRS Reporting Point')]
        [String]$role,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int32]$maxHistory = 5
    )

    begin {
        #Build splat for log entries 
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'Get-CMNSiteSystems';
            maxLogSize = $maxLogSize;
            maxHistory = $maxHistory;
        }
        #Build splat for WMIQueries
        $WMIQueryParameters = $sccmConnectionInfo.WMIQueryParameters
		
        # Create a hashtable with your output info
        $returnHashTable = @{}
		
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
        }
    }
	
    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        if ($PSCmdlet.shouldprocess($role)) {
            $query = "Select * from SMS_SiteSystemSummarizer where Role = '$role'"
            $SiteSystems = (Get-WmiObject -Query $query @WMIQueryParameters).SiteSystem -replace '.*\\(.*)\\.*', '$1' | Sort-Object -Unique
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry "Returning:" -type 1 @NewLogEntry
            New-CMNLogEntry -entry $SiteSystems -type 1 @NewLogEntry
            New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        }
        Return $SiteSystems
    }
} #End Get-CMNSiteSystems
