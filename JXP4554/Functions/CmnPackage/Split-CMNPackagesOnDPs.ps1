Function Split-CMNPackagesOnDPs
{
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
		FileName:    Split-CMNPackagesOnDPs.ps1
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
		[PSObject]$SCCMConnectionInfo,

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
        [Int32]$maxHistory = 5
	)

	Begin 
	{
		# Disable Fast parameter usage check for Lazy properties
		$CMPSSuppressFastNotUsedCheck = $true
		#Build splat for log entries 
		$NewLogEntry = @{
			LogFile = $logFile;
			Component = 'Split-CMNPackagesOnDPs';
			maxLogSize = $maxLogSize;
			maxHistory = $maxHistory;
		}
		#Build splats for WMIQueries
        $WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters
		if($PSBoundParameters['logEntries'])
		{
			New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
			New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
		}
	}
	
	Process 
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
		# Main code part goes here
		#Get packages
		#Is Package bigger then 500MB?
		#Remove from All DP's
		#Sleep for 2 minutes
		#Get if even or odd
		#Put on DP Group
	}

	End
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
	}
} #End Split-CMNPackagesOnDPs