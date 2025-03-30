Function Start-CMNPackageContentDistribution {
    <#
	.SYNOPSIS
		Distributes a package to a specified DPGroup

	.DESCRIPTION
		Distributes a package to a specified DPGroup

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.PARAMETER PackageID
		ID of Package to be Distributed

	.PARAMETER DPGroup
		The DP Group to receive the content

	.EXAMPLE
		Start-CMNPackageContentDistribution 'SMS00001' 'All DP''s'

	.NOTES
		Use ConvertTo-CMNWMISingleQuotedString to translate the DPGroup name if it has single quotes

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [PSObject]$sccmConnectionInfo,
        [Parameter(Mandatory = $true)]
        [String]$PackageID,
        [Parameter(Mandatory = $true)]
        [String]$DPGroup
    )

    $DPGroup = ConvertTo-CMNWMISingleQuotedString -Text $DPGroup

    $ExitCode = ((Get-WmiObject -Class SMS_DistributionPointGroup -Filter "Name = '$DPGroup'"  -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName).AddPackages($PackageID)).ReturnValue
    return $ExitCode
} #End Start-CMNPackageContentDistribution
