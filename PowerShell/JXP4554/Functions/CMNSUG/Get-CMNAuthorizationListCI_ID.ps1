Function Get-CMNAuthorizationListCI_ID {
    <#
		.SYNOPSIS
			This will return the CI_ID of an Authorization List (Software Update Group)

		.DESCRIPTION
			This will return the CI_ID of an Authorization List (Software Update Group) that can be used for other commands

		.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER AuthorizationList

		.EXAMPLE
			Get-CMNAuthorizationListCI_ID -AuthorizationList 'Windows 7 - 2015 Updates'

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
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $True, HelpMessage = 'Application Name')]
        [String[]]$AuthorizationList
    )
    begin {}
    process {
        Write-Verbose 'Starting Get-CMNAuthorizationListCI_ID'
        foreach ($AuthList in $AuthorizationList) {
            if ($PSCmdlet.ShouldProcess($AuthList)) {
                $App = Get-WmiObject -Class SMS_AuthorizationList  -Filter "LocalizedDisplayName = '$AuthList'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName
                Return ($App.CI_ID)
            }
        }
    }
    end {}
} #End Get-CMNAuthorizationListCI_ID
