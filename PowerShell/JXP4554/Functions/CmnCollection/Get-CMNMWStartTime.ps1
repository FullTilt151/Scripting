Function Get-CMNMWStartTime {
    <#
	.SYNOPSIS
		This function will calculate the Maintenance Window Start Time

	.DESCRIPTION
		Using the collection name, it will start the Maintenance

	.PARAMETER Collection
		Collection name to figure out the maintenance window for.

	.PARAMETER MaintenanceWindowDuration
		This is how long, in hours, your maintenance window is. This can be from 1 to 6 hours, default is 4. The validation check is done in the initial set of parameters,
		I did not do it here also.
	.PARAMETER PatchTuesday
		The date for Patch Tuesday

	.EXAMPLE
		$StartDateTime = Get-CMNMWStartTime 'Patch Day 03 - Reboot 03:00' 4 $PatchTuesday

		This will get the startdate for a collection Named Patch Day 03 - Reboot 03:00. It will have a four hour duration and end at 3:00AM

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>

    PARAM
    (
        [Parameter(Mandatory = $True)]
        [String]$Collection,
        [Parameter(Mandatory = $True)]
        [Int32]$MaintenanceWindowDuration,
        [Parameter(Mandatory = $True)]
        [DateTime]$PatchTuesday
    )

    $Collection -match '\d{1,2}:\d{1,2}.?([AP]M)' | Out-Null
    $Meridian = $Matches[1]

    $Collection -match 'Patch Day ([0-9]*).*' | Out-Null
    [int32]$Day = $Matches[1]

    $Collection -match '(\d{1,2}):(\d{1,2})' | Out-Null
    [Single]$Mn = $Matches[2]
    [Single]$Hr = $Matches[1]
    if (($Hr -lt 12) -and ($Meridian -eq 'PM')) {
        $Hr += 12
        if ($Hr -ge 24) {$Hr -= 24}
    }
    $DecTime = $Hr + ($Mn / 60)
    $StartDateTIme = $PatchTuesday.AddDays($Day)
    $StartDateTIme = $StartDateTIme.AddHours($Hr - $MaintenanceWindowDuration)
    $StartDateTIme = $StartDateTIme.AddMinutes($Mn)
    if ($DecTime -gt $MaintenanceWindowDuration) {$StartDateTIme = $StartDateTIme.AddDays(-1)}
    Return $StartDateTIme
} #End Get-CMNMWStartTime
