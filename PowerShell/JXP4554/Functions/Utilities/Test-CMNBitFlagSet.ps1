Function Test-CMNBitFlagSet {
    <#
	.SYNOPSIS
		Tests to see if the Keyname in the BitFlagHashTable matches the CurrentValue

	.DESCRIPTION
		Used to test of a bitflag is set from a hashtable

	.PARAMETER BitFlagHashTable
		This contains the list of the bitflags, for example the WMI Class SMS_Advertisement has a bitflag called AdvertFlags

		We have defined the following BitFlagHashTables:
			$SMS_Advertisement_AdvertFlags
			$SMS_Advertisement_DeviceFlags
			$SMS_Advertisement_RemoteClientFlags
			$SMS_Advertisement_TimeFlags
			$SMS_Package_PkgFlags
			$SMS_Program_ProgramFlags
	.PARAMETER KeyName
		Using the above example, you may be looking for the IMMEDIATE Key name

	.PARAMETER CurrentValue
		This is the BitFlag current value, what you are trying to see if the KeyName from the BitFlagHashTable is set.

	.EXAMPLE
		Test-CMNBitFlagSet $SMS_Advertisement_AdvertFlags 'IMMEDIATE' $($SMSAdvert.AdvertFlags)

		This will return ture if the IMMEDIATE key is set in the $SMSAdvert.AdvertFlags object, false if it is not

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [HashTable]$BitFlagHashTable,

        [Parameter(Mandatory = $true)]
        [String]$KeyName,

        [Parameter(Mandatory = $true)]
        [String]$CurrentValue
    )
    if ($CurrentValue -band $BitFlagHashTable.Item($KeyName)) {
        return $True
    }
    else {
        return $False
    }
} #End Test-CMNBitFlagSet
