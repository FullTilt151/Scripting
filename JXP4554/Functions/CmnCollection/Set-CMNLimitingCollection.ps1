Function Set-CMNLimitingCollection {
    <#
	.SYNOPSIS
		This will change the limiting collection for a collection

	.DESCRIPTION
		This changes the limiting collection on the CollectionID(s) passed to the New ID in teh LimitingToCollectionIDNew parameter

		We have defined the following BitFlagHashTables:
			$SMS_Advertisement_AdvertFlags
			$SMS_Advertisement_DeviceFlags
			$SMS_Advertisement_RemoteClientFlags
			$SMS_Advertisement_TimeFlags
			$SMS_Package_PkgFlags
			$SMS_Program_ProgramFlags

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER CollectionID
		The CollectionID(s) of the collection to be updated

	.PARAMETER logFile
		File for writing logs to

    .PARAMETER logEntries
        Switch to say whether or not to create a log file

	.PARAMETER LimitingToCollectionIDNew
		The CollectionID for the new limiting collection

	.EXAMPLE
		Set-CMNLimitingCollection 'CAS00416' 'CAS00585'

	.EXAMPLE
		'CAS00416' | Set-CMNLimitingCollection -LimitingToCollectionIDNew 'CAS00586'

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info',
            Position = 1)]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'CollectionID for collection to change',
            Position = 2,
            ValueFromPipeLine = $true)]
        [string[]]$CollectionID,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Change the limiting collection to this CollectionID',
            Position = 3)]
        [string]$LimitingToCollectionIDNew,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name',
            Position = 4)]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries',
            Position = 5)]
        [Switch]$logEntries = $false,

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
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'Set-CMNLimitingCollection'
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        $WMIQueryParameters = @{
            ComputerName = $sccmConnectionInfo.ComputerName;
            NameSpace = $sccmConnectionInfo.NameSpace;
        }
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry}
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting Set-CMNLimitingCollection' -type 1 @NewLogEntry}
        foreach ($CollID in $CollectionID) {
            $Collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$CollID'" @WMIQueryParameters
            $Collection.Get()
            $LimitingCollection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$LimitingToCollectionIDNew'" @WMIQueryParameters
            if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry "Changing $($Collection.Name) limiting collection from $($Collection.LimitToCollectionName) to $($LimitingCollection.Name)" -type 1 @NewLogEntry}
            $Collection.LimitToCollectionID = $(($LimitingCollection.CollectionID).ToString())
            $Collection.LimitToCollectionName = $(($LimitingCollection.Name).ToString())
            $Collection.Put() | Out-Null
        }
    }

    end {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing function' -type 1 @NewLogEntry}
    }
} #End Set-CMNLimitingCollection
