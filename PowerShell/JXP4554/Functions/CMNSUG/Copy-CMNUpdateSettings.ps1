Function Copy-CMNUpdateSettings {
    <#
	.SYNOPSIS
 
	.DESCRIPTION
 
	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of 
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.
		
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
        Date:	    2018-05-09
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
	
    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Source Connection Info')]
        [PSObject]$SourceConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Destination Connection Info')]
        [PSObject]$DestinationConnectionInfo,

        [Parameter(Mandatory = $false, HelpMessage = 'Set anything selected in the source site in the destination site')]
        [Switch]$doSet,

        [Parameter(Mandatory = $false, HelpMessage = 'Clear anything not selected in the source site from the destination site')]
        [Switch]$doClear,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    Begin {
        if ($PSBoundParameters['logEntries']) {$logEntries = $true}
        else {$logEntries = $false}
			
        #Build splat for log entries 
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Copy-CMNUpdateSettings';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMISourceQueryParameters = $SourceConnectionInfo.WMIQueryParameters
        $WMIDestinationQueryParameters = $DestinationConnectionInfo.WMIQueryParameters
        if ($logEntries) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SourceConnectionInfo = $SourceConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "DestinationConnectionInfo = $DestinationConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "doSet = $doSet" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "doClear = $doClear" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
		
        #Make sure we have at least one "do" parameter set
        if (!$doClear -and !$doSet) {
            $message = 'You must select doClear and/or doSet'
            if ($logEntries) {New-CMNLogEntry -entry $message -type 3 @NewLogEntry}
            throw $message
        }
    }
	
    Process {
        if ($logEntries) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        # Main code part goes here
        $sourceSettings = Get-WmiObject -Class SMS_UpdateCategoryInstance @WMISourceQueryParameters
        $destinationSettings = Get-WmiObject -Class SMS_UpdateCategoryInstance @WMIDestinationQueryParameters
        foreach ($sourceSetting in $sourceSettings) {
            $foundMatch = $false
            if ($logEntries) {New-CMNLogEntry -entry "Checking $($sourceSetting.LocalizedCategoryInstanceName)" -type 1 @NewLogEntry}
            #Loop through destination settings
            foreach ($destinationSetting in $destinationSettings) {
                if ($sourceSetting.LocalizedCategoryInstanceName -eq $destinationSetting.LocalizedCategoryInstanceName) {
                    $foundMatch = $true
                    if ($sourceSetting.IsSubscribed -ne $destinationSetting.IsSubscribed) {
                        if ($sourceSetting.IsSubscribed -and $doSet) {
                            if ($logEntries) {New-CMNLogEntry -entry "  Setting $($sourceSetting.LocalizedCategoryInstanceName) is being set to $($sourceSetting.IsSubscribed)" -type 1 @NewLogEntry}
                            $destinationSetting.IsSubscribed = $sourceSetting.IsSubscribed
                            $destinationSetting.Put() | Out-Null
                        }
                        else {
                            if (!$sourceSetting.IsSubscribed -and $doClear) {
                                if ($logEntries) {New-CMNLogEntry -entry "  Setting $($sourceSetting.LocalizedCategoryInstanceName) is being set to $($sourceSetting.IsSubscribed)" -type 1 @NewLogEntry}
                                $destinationSetting.IsSubscribed = $sourceSetting.IsSubscribed
                                $destinationSetting.Put() | Out-Null
                            }
                        }
                    }
                }
            }
            if (-not($foundMatch)) {
                if ($logEntries) {New-CMNLogEntry -entry "  Setting $($sourceSetting.LocalizedCategoryInstanceName) does not appear to be on the destination site." -type 1 @NewLogEntry}
                if ($sourceSetting.IsSubscribed -and $logEntries) {New-CMNLogEntry -entry "  It needs to be subscribed to" -type 2 @NewLogEntry}
                elseif ($logEntries) {New-CMNLogEntry -entry "  It was not subscribed to." -type 1 @NewLogEntry}
            }
        }	
    }

    End {
        if ($logEntries) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Copy-CMNUpdateSettings
