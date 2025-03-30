Function ConvertTo-CMNLocalUserSID {
    <#
	.SYNOPSIS
		Returns the SID for a Local user

	.DESCRIPTION
		Returns the SID for a Local user

	.PARAMETER userID
		Login you want the SID for

	.EXAMPLE
		ConvertTo-CMNLocalUserSID -user jparris

		Returns sid for user jparris

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
        [String]$userID
    )

    $objUser = New-Object System.Security.Principal.NTAccount($userID)
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    Return $strSID.Value
} # End ConvertTo-CMNLocalUserSID
