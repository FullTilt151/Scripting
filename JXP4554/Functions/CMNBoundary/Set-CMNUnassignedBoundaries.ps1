Function Set-CMNUnassignedBoundaries{
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
		FileName:    Set-CMNUnassignedBoundaries.ps1
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

	Begin{
		# Disable Fast parameter usage check for Lazy properties
		#Build splat for log entries
		$NewLogEntry = @{
			LogFile = $logFile;
			Component = 'Set-CMNUnassignedBoundaries';
			maxLogSize = $maxLogSize;
			maxHistory = $maxHistory;
		}
		#Build splats for WMIQueries
        $WMIQueryParameters = $SCCMConnectionInfo.WMIQueryParameters
		if($PSBoundParameters['logEntries']){
			New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
			New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
            New-CMNLogEntry -entry 'Getting unassigned boundaries' -type 1 @NewLogEntry
        }
        $unassignedBoundaries = Get-CimInstance -Query 'SELECT * FROM SMS_Boundary WHERE GroupCount = 0' @WMIQueryParameters
        if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Getting boundary groups' -type 1 @NewLogEntry}
        $boundaryGroups = Get-CimInstance -Query 'SELECT * FROM SMS_BoundaryGroup' @WMIQueryParameters
	}

	Process{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
		# Main code part goes here
		if ($PSCmdlet.ShouldProcess($variable)) {
            $boundariesToAssign = $unassignedBoundaries | Select-Object -Property BoundaryType, DisplayName, Value, BoundaryID | Out-GridView -OutputMode Multiple -Title 'Please select boundaries to assign'
			$boundaryID = $boundaryGroups | Select-Object -Property Name, GroupID | Out-GridView -OutputMode Single -Title 'Please select the boundary group to assign boundary(ies) to'
			#$boundaryGroup = Get-CimInstance -Query "SELECT * FROM SMS_BoundaryGroup WHERE GroupID=$($boundaryID.GroupID)" @WMIQueryParameters
			$boundaryGroup = Get-WmiObject -Query "SELECT * FROM SMS_BoundaryGroup WHERE GroupID=$($boundaryID.GroupID)" @WMIQueryParameters
            ForEach($boundaryToAssign in $boundariesToAssign){
				if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Assigning $($boundaryToAssign.DisplayName) to $($boundaryGroup.Name)" -type 1 @NewLogEntry}
				#$arguments = @{BoundaryID = $($boundaryToAssign.BoundaryID)}
				#Invoke-CimMethod -InputObject $boundaryGroup -MethodName "AddBoundary" -Arguments $arguments
				$boundaryGroup.AddBoundary($boundaryToAssign.BoundaryID) | Out-Null
            }
		}
	}

	End{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
	}
} #End Set-CMNUnassignedBoundaries
Write-Output 'Starting'
$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer 'LOUAPPWQS1150'
Set-CMNUnassignedBoundaries -SCCMConnectionInfo $SCCMConnectionInfo -logFile 'C:\Temp\Set-CMNUnassignedBoundaries.log' -logEntries