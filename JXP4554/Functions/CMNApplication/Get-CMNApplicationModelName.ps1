Function Get-CMNApplicationModelName {
    <#
		.SYNOPSIS
			Returns the ModelName for an application name. If the application doesn't exist, it will return $null

		.DESCRIPTION
			Returns the ModelName for an application name. If the application doesn't exist, it will return $null

		.PARAMETER SCCMConnectionInfo
				This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
				Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER ApplicationName
			Name of application to get the ModelName for

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.PARAMETER ShowProgress
			Show a progressbar displaying the current operation.

		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES
			FileName:    Get-CMNApplicationModelName.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2017-03-01
			Updated:     2017-03-01
			Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info',
            Position = 1)]
        [Alias('computerName')]
        [Alias('hostName')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(
            Mandatory = $True,
            HelpMessage = 'Application Name',
            ValueFromPipeLine = $true,
            Position = 2)]
        [String]$applicationName,

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

        [parameter(Mandatory = $false,
            HelpMessage = "Show a progressbar displaying the current operation.",
            Position = 6)]
        [Switch]$showProgress
    )
    begin {
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'Get-CMNApplicationModelName'
        }
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace = $sccmConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['clearLog']) {if (Test-Path -Path $logFile) {Remove-Item -Path $logFile}}
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        if ($PSBoundParameters['showProgress']) {
            $ProgressCount = 0
        }
        if ($PSCmdlet.ShouldProcess($applicationName)) {
            $ReturnHashTable = @{}
            $App = Get-WmiObject -Class SMS_ApplicationLatest -Filter "LocalizedDisplayName = '$applicationName'" @WMIQueryParameters
            $ReturnHashTable.Add($applicationName, $App.ModelName)
            Return $ReturnHashTable
        }
    }

    end {
        if ($PSBoundParameters['ShowProgress']) {Write-Progress -Activity 'Get-CMNApplicationModelName' -Completed}
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Get-CMNApplicationModelName
