Function Get-CMNBitFlagSet {
    <#
		.SYNOPSIS
			This will return the CI_ID of an application

		.DESCRIPTION
			This will return the CI_ID of an application that can be used for other functions

		.EXAMPLE
			Get-CMNApplicationCI_ID -ApplicaitonName 'Orca'

		.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER FlagsProp
			The value of the bitflag to decode

		.PARAMETER BitFlagHashTable
			This contains the list of the bitflags,

		.EXAMPLE
			Get-CMNBitFlagSet $($SMSAdvert.AdvertFlags) $SMS_Advertisment_AdvertFlags

		.NOTES
			Author:	Jim Parris
			Email:	Jim@ConfigMan-Notes
			Date:	2/25/2016
			PSVer:	2.0/3.0
			Updated:

		.LINK
			http://configman-notes.com
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true,
            HelpMessage = 'Hash table of bit flags')]
        [HashTable]$BitFlagHashTable,

        [Parameter(Mandatory = $True,
            HelpMessage = 'CurrentValue to Check')]
        [String]$CurrentValue,

        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries = $false,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs')]
        [Int32]$maxLogHistory = 5
    )

    begin {
        $NewLogEntry = @{
            LogFile = $logFile;
            Component = 'Add-CMNRoleOnObject';
            maxLogSize = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "BitFlagHashTable = $BitFlagHashTable" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "CurrentValue = $CurrentValue" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Starting process loop' -type 1 @NewLogEntry}
        $ReturnHashTable = @{}
        foreach ($keyName in $bitFlagHashTable.GetEnumerator()) {
            if ($PSCmdlet.ShouldProcess($keyName.Key)) {
                if ($CurrentValue -band $keyName.Value) {
                    $ReturnHashTable.Add($keyName.key, $true)
                }
                else {
                    $ReturnHashTable.Add($keyName.key, $false)
                }
            }
        }
    }

    end {
        $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.CMNBitFlagSet')
        Return $obj
    }
} #End Get-CMNBitFlagSet
