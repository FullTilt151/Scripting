Function Get-CMNPatchTuesday {
    <#
	.SYNOPSIS
		Calculates Patch Tuesday for the current month

	.DESCRIPTION
		See Synopsis

	.EXAMPLE
		$PatchTuesday = Get-CMNPatchTuesday
	#>
    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Date for the month you want to deterimine patch Tuesday')]
        [DateTime]$date = $(Get-Date)
    )
    #Calculate Patch Tuesday Date
    [DateTime]$StrtDate = Get-date("$((Get-Date $date).Month)/1/$((Get-Date $date).Year)")
    While ($StrtDate.DayOfWeek -ne 'Tuesday') {$StrtDate = $StrtDate.AddDays(1)}
    #Now that we know when the first Tuesday is, let's get the second.
    $StrtDate = $StrtDate.AddDays(7)
    Return Get-Date $StrtDate -Format g
} #End Get-CMNPatchTuesday
