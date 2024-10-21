Function ConvertTo-CMNWMISingleQuotedString {
    <#
	.SYNOPSIS
		This will replace a ' with \'

	.DESCRIPTION
		This will replace a ' with \' to make the text compatable for WQL queries or any query that uses the ' as an escape/delimiter

	.PARAMETER Text
		Text to be fixed

	.EXAMPLE
		Get-CMNQuotedVersion -Text "Windows 7 Workstation's"

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	8/12/2016
		PSVer:	2.0/3.0
	#>

    [CmdletBinding(ConfirmImpact = 'Low')]
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$text
    )
    return ([regex]::Replace($text, '(?<SingleQuote>'')', '\${SingleQuote}'))
} #End ConvertTo-CMNWMISingleQuotedString
