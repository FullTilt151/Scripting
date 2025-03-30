Function Copy-CMNClientSettings {
    <#
	.SYNOPSIS
		Copies Client Settings from one SCCM site to another

	.DESCRIPTION
		Copies Client Settings from one SCCM site to another

	.PARAMETER sourceConnection
		This is a connection object for the source site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER destinationConnection
		This is a connection object to the destination site.

	.PARAMETER logFile
		File for writing logs to

	.PARAMETER logEntries
		Switch to say whether or not to create a log file

	.PARAMETER clearLog
		If this is set, we will clear (delete) any existing log file.

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.EXAMPLE
		$SrcCon = Get-CMNSCCMConnectionInfo -SiteServer Server01
		$DstCon = Get-CMNSCCMConnectionInfo -SiteServer Server02
		Copy-CMNClientSettings -sourceConnection $SrcCon -destinationConnection $DstCon -logFile $logfile -logEntries

	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Copy-CMNClientSettings.ps1
		Author:      James Parris
		Contact:     jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2017-03-2
		Version:     1.0.1
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info',
            Position = 1)]
        [PSObject]$sourceConnection,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Destination SCCM Connection',
            Position = 2)]
        [PSObject]$destinationConnection,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 3)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 4)]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Clear Log File',
            Position = 5)]
        [Switch]$clearLog,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size',
            Position = 6)]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs',
            Position = 7)]
        [Int32]$maxLogHistory = 5
    )
    begin {
        #Build splat for log entries
        $NewLogEntry = @{
            logFile = $logFile;
            component = 'Copy-CMNClientSettings';
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        #Build splats for WMIQueries
        $WMISourceQueryParameters = @{
            ComputerName = $sourceConnection.ComputerName;
            NameSpace = $sourceConnection.NameSpace;
        }
        $WMIDestinationQueryParameters = @{
            ComputerName = $destinationConnection.ComputerName;
            NameSpace = $destinationConnection.NameSpace;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "sourceConnection = $sourceConnection" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "destinationConnection = $destinationConnection" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        if ($PSCmdlet.ShouldProcess($sourceConnection)) {
            #Let's get the settings from the source site.
            $query = 'SELECT * FROM SMS_ClientSettings order by priority'
            $clientSettings = Get-WmiObject -Query $query @WMISourceQueryParameters
            #Now to cycle through them and copy!
            foreach ($clientSetting in $clientSettings) {
                #Get the individual setting
                $query = "select * from SMS_ClientSettings where Name = '$($clientSetting.Name)'"
                #Let's see if it already exists
                $testDestSettings = Get-WmiObject -Query $query @WMIDestinationQueryParameters
                if ($testDestSettings) {
                    Write-Output 'Already Exists'
                }
                else {
                    #Eureka! Let's create it! First, get those lazy parameters....
                    $clientSetting.Get()
                    #And we start anew!
                    $destClientSettings = ([WMIClass]"//$($destinationConnection.ComputerName)/$($destinationConnection.NameSpace):SMS_ClientSettings").CreateInstance()
                    #Now for those pesky details...
                    $destClientSettings.AgentConfigurations = $clientSetting.AgentConfigurations
                    $destClientSettings.Description = $clientSetting.Description
                    $destClientSettings.Enabled = $clientSetting.Enabled
                    $destClientSettings.FeatureType = $clientSetting.FeatureType
                    $destClientSettings.Flags = $clientSetting.Flags
                    $destClientSettings.Name = $clientSetting.Name
                    $destClientSettings.Priority = $clientSetting.Priority
                    $destClientSettings.Type = $clientSetting.Type
                    #And save it!
                    $destClientSettings.Put()
                }
            }
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Copy-CMNClientSettings
