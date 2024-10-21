Function ConvertTo-CMNUser {
    <#
	.SYNOPSIS
		Returns the Domain user for a SID

	.DESCRIPTION
		Returns the Domain user for a SID

	.PARAMETER sid
		SID you want to convert

	.EXAMPLE
		ConvertTo-CMNUser -sid S-1-5-21-1275210071-879983540-1801674531-220633

		Returns user for SID S-1-5-21-1275210071-879983540-1801674531-220633

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	4/14/2017
		PSVer:	2.0/3.0
		Updated:
	#>

    PARAM
    (
        [Parameter(Mandatory = $true, HelpMessage = 'LoginID to translate')]
        [String]$sid
    )

    $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
    $objUser = $objSID.Translate([System.Security.Principal.NTAccount])
    Return $objUser.Value
} # End ConvertTo-CMNUser

ConvertTo-CMNUser -sid 'S-1-5-21-1275210071-879983540-1801674531-220633'