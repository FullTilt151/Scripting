Function Get-CMNPackageForSoftwareUpdate {
    <#
	.SYNOPSIS

	.DESCRIPTION

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.EXAMPLE

	.PARAMETER RoleName

	.NOTES

	.LINK
		http://configman-notes.com
	#>

    PARAM
    (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $True)]
        [String]$ModelNumber
    )

    $Query = "Select SMS_PackageToContent.PackageID`
	from SMS_SoftwareUpdate`
    JOIN SMS_CIToContent on SMS_SoftwareUpdate.CI_ID = SMS_CIToContent.CI_ID JOIN
	SMS_PackageToContent on SMS_PackageToContent.ContentID = SMS_CIToContent.ContentID`
	WHERE SMS_SoftwareUpdate.ModelName = '$ModelNumber'"

    return (Get-WmiObject -Query $Query @WMIQueryParameters).PackageID
} #End Get-CMNPackageForSoftwareUpdate
