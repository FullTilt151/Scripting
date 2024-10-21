Function Set-CMNBitFlagForControl {
    <#
	.SYNOPSIS

	.DESCRIPTION
		We have defined the following BitFlagHashTables:
			$SMS_Advertisement_AdvertFlags
			$SMS_Advertisement_DeviceFlags
			$SMS_Advertisement_RemoteClientFlags
			$SMS_Advertisement_TimeFlags
			$SMS_Package_PkgFlags
			$SMS_Program_ProgramFlags

	.EXAMPLE

	.PARAMETER Text

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [Bool]$ProposedValue,

        [Parameter(Mandatory = $true)]
        [HashTable]$BitFlagHashTable,

        [Parameter(Mandatory = $true)]
        [String]$KeyName,

        [Parameter(Mandatory = $true)]
        [Int32]$CurrentValue
    )
    if ($ProposedValue) {
        $CurrentValue = $CurrentValue -bor $BitFlagHashTable.Item($KeyName)
    }
    elseif ($CurrentValue -band $BitFlagHashTable.Item($KeyName)) {
        $CurrentValue = ($CurrentValue -bxor $BitFlagHashTable.Item($KeyName))
    }
    return $CurrentValue
} #End Set-CMNBitFlagForControl
