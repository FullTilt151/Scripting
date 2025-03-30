Function Get-CMNRoleOnApplication {
    <#
	.SYNOPSIS
		This Function will get all the roles on an Application

	.DESCRIPTION
		You provide the applicaoitn CI_ID and it will return the scopes.

	.PARAMETER CI_ID
		The CI_ID of the application you are retreiving the scopes for

	.EXAMPLE
		Get-CMNRoleOnApplicaiton -CI_ID 15342

	.LINK
		http://configman-notes.com

	.NOTES
		Author:	Jim Parris
		Email:	Jim@ConfigMan-Notes
		Date:	2/25/2016
		PSVer:	2.0/3.0
		Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Application CI_ID',
            ValueFromPipeLine = $true)]
        [String[]]$CI_ID
    )

    begin {}

    process {
        Write-Verbose 'Starting Get-CMNRoleOnApplication'
        foreach ($CIID in $CI_ID) {
            if ($PSCmdlet.ShouldProcess($CIID)) {
                Return (Get-WmiObject -Class SMS_ApplicationLatest -Filter "CI_ID = '$CIID'" @WMIQueryParameters).SecuredScopeNames
            }
        }
    }

    end {}
} #End Get-CMNRoleOnApplication
