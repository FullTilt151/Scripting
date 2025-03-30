Function Test-CMNPackageExists {
    <#
	.SYNOPSIS
		Tests to see if a package exists or not

	.DESCRIPTION
		Tests to see if a package exists or not

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

	.PARAMETER PackageID
		PackageID to test for

	.EXAMPLE

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageID to test for')]
        [String]$packageID
    )
    $package = Get-WmiObject -Class SMS_Package -Filter "PackageID = '$packageID'" -ComputerName $sccmConnectionInfo.ComputerName -Namespace $sccmConnectionInfo.NameSpace
    if ($package) {Write-Output $true}
    else {Write-Output $false}
} #End Test-CMNPackageExists
