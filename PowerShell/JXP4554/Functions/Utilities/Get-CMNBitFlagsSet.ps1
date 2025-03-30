Function Get-CMNBitFlagsSet {
    <#
	.SYNOPSIS
		This will take the BitFlagHastTable and return the state of the flags in FlagProp

	.DESCRIPTION
		This will take the BitFlag value you pass and using the BitFlagHashTable, tell you the value of each key
		We have defined the following BitFlagHashTables:
			$SMS_Advertisement_AdvertFlags
			$SMS_Advertisement_DeviceFlags
			$SMS_Advertisement_RemoteClientFlags
			$SMS_Advertisement_TimeFlags
			$SMS_Package_PkgFlags
			$SMS_Program_ProgramFlags

	.EXAMPLE

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
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$FlagsProp,

        [Parameter(Mandatory = $true)]
        [HashTable]$BitFlagHashTable
    )
    #New-LogEntry 'Starting Function' 1 Get-CMNBitFlagsSet
    $ReturnHashTable = @{}
    $BitFlagHashTable.Keys | ForEach-Object { if (($FlagsProp -band $BitFlagHashTable.Item($_)) -ne 0 ) {$ReturnHashTable.Add($($_), $true)}else {$ReturnHashTable.Add($($_), $false)}}
    #New-LogEntry "Returning $ReturnHashTable" 1 Get-CMNBitFlagsSet
    $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
    $obj.PSObject.TypeNames.Insert(0, 'CMN.BitFlagSet')
    Return $obj
}#End Get-CMNBitFlagsSet
