Function Check-CMNSUGDeployments
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
		FileName:    Check-CMNSUGDeployments.ps1
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2016-03-22
		Version:     1.0.0

Hey, I’m working on a script to check the SUG deployments. Can you add anything to my logic below?
None should ignore windows
Deployments targeting a NoReboot collection should suppress reboots
All others should not.

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
			Component = 'Check-CMNSUGDeployments';
			maxLogSize = $maxLogSize;
			maxHistory = $maxHistory;
		}
		#Build splats for WMIQueries
        $WMIQueryParameters = $($SCCMConnectionInfo.WMIQueryParameters)
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
		$query = 'SELECT * FROM SMS_UpdateGroupAssignment'
		$Updates = Get-WmiObject -Query $query @WMIQueryParameters
		foreach($Update in $Updates)
		{
			$query = "Select * from SMS_Collection where CollectionID = '$($Update.TargetCollectionID)'"
			$Collection = Get-WmiObject -Query $query @WMIQueryParameters
			$query = "SELECT * FROM SMS_AuthorizationList WHERE CI_ID = '$($Update.AssignedUpdateGroup)'"
			$SUG = Get-WmiObject -Query $query @WMIQueryParameters
            $SUG.Get()
            if($Update.SuppressReboot -eq 0){$SupressReboot = $false}
            Else{$SupressReboot = $true}
            $Enabled = -not($Update.Enabled)
            $IgnoreSWReboot = $Update.RebootOutsideOfServiceWindows
            $IgnoreSW = $Update.OverrideServiceWindows
			$IsChanged = $false
			if(-not ($Update.RequirePostRebootFullScan))
			{
				$Update.RequirePostRebootFullScan = $true
				$IsChanged = $true
			}
			if($Collection.Name -match 'NoReboot')
			{
                $SupressReboot = -not $SupressReboot
			}
			$Message = "Deployment - $($Update.AssignmentID), SUG - $($SUG.LocalizedDisplayName),  Target Collection $($Collection.Name) "
            if($SupressReboot)
			{
				$Message += "- Toggled Supress Reboot "
				$IsChanged = $true
				if($Update.SuppressReboot -eq 0){$Update.SuppressReboot = 2}
				else{$Update.SuppressReboot = 0}
			}
            if($IgnoreSWReboot)
			{
				$Message += "- Toggle Reboot Outside of Maintenance Window "
				$IsChanged = $true
				$Update.RebootOutsideOfServiceWindows = -not ($Update.RebootOutsideOfServiceWindows)
			}
			if($IgnoreSW)
			{
				$Message += "- Toggle Ignore Maintenance Window "
				$IsChanged = $true
				$Update.OverrideServiceWindows = -not ($Update.OverrideServiceWindows)
			}
            if($Enabled){$Message += "- Enable Deployment"}
			if($IsChanged){$Update.Put()}
            if($SupressReboot -or $IgnoreSWReboot -or $IgnoreSW -or $Enabled)
            {
                $Message
                if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry $Message -type 1 @NewLogEntry}
            }
		}
	}

	End
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
	}
} #End Check-CMNSUGDeployments
Check-CMNSUGDeployments -SCCMConnectionInfo (Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1825) -logFile 'C:\Temp\Check-CMNSUGDeployments.log' -logEntries