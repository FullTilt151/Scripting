Function Start-CMNApplicationDeployment {
    <#
	.SYNOPSIS
		Deploys an application to a specified collection.

	.DESCRIPTION

		This function expects the variable $WMIQueryParameters to be used, if you have your site server, you can use the info below
		to get your necessary information:

		$SiteServer = '<InsertServerName>'
		$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

		$WMIQueryParameters = @{
			ComputerName = $SiteServer
			Namespace = "root\sms\site_$SiteCode"

	.PARAMETER CollectionID
		CollectionID of the target collection

	.PARAMETER ApplicationName
		Application to be deployed

	.PARAMETER Purpose
		Is this an Install or Uninstall

	.PARAMTER OfferType
		Available or Required

	.PARAMTER EnforcementDeadline
		For Required deployments, the Scheduled Start Time.

	.EXAMPLE
		Start-CMNApplicationDeployment 'SMS00001' 'Adobe Reader' 'Install' 'Available'

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$CollectionID,
        [Parameter(Mandatory = $true)]
        [String]$ApplicationName,
        [Parameter(Mandatory = $true, HelpMessage = 'Install or Uninstall')]
        [String]$Purpose,
        [Parameter(Mandatory = $true, HelpMessage = 'Available/Required')]
        [String]$OfferType,
        [Parameter(Mandatory = $false)]
        [String]$EnforcementDeadline
    )

    $Query = "SELECT * FROM SMS_Application WHERE LocalizedDisplayName = '$ApplicationName'"
    $Application = Get-WmiObject -Query $Query @WMIQueryParameters

    $Query = "Select * from SMS_ApplicationAssignment where TargetCollectionID = '$CollectionID' and AssignedCIs = '$($Application[$Application.count - 1].CI_ID)'"
    $Deployments = Get-WmiObject -Query $Query @WMIQueryParameters
    if ($Deployments) {
        Throw "Already a deployment to that collection"
    }
    else {
        $Query = "select * from SMS_Collection where CollectionID = '$CollectionID'"
        $Collection = Get-WmiObject -Query $Query @WMIQueryParameters

        $ApplicationAssignmentClass = [wmiclass] "\\$SiteServer\root\SMS\SITE_$($SiteCode):SMS_ApplicationAssignment"
        $newApplicationAssingment = $ApplicationAssignmentClass.CreateInstance()
        $newApplicationAssingment.ApplicationName = $Application[$Application.count - 1].localizedDisplayName
        $newApplicationAssingment.AssignmentName = "$($Application[$Application.count - 1].LocalizedDisplayName) to $($Collection.Name)"
        $newApplicationAssingment.AssignedCIs = $Application[$Application.count - 1].CI_ID
        $newApplicationAssingment.AssignmentType = 2
        $newApplicationAssingment.AssignmentDescription = 'Created by Orcestrator'
        $newApplicationAssingment.CollectionName = $Collection.Name
        $newApplicationAssingment.CreationTime = $newApplicationAssingment.ConvertFromDateTime($(Get-Date))
        $newApplicationAssingment.LocaleID = 1033
        $newApplicationAssingment.SourceSite = $SiteCode
        $newApplicationAssingment.StartTime = $newApplicationAssingment.ConvertFromDateTime($(Get-Date))
        $newApplicationAssingment.SuppressReboot = $true
        $newApplicationAssingment.NotifyUser = $true
        $newApplicationAssingment.TargetCollectionID = $($Collection.CollectionID)
        $newApplicationAssingment.WoLEnabled = $false
        $newApplicationAssingment.RebootOutsideOfServiceWindows = $false
        $newApplicationAssingment.OverrideServiceWindows = $false
        $newApplicationAssingment.UseGMTTimes = $false
        if ($OfferType -match 'Available') {
            $newApplicationAssingment.OfferTypeID = 2
        }
        else {
            $newApplicationAssingment.OfferTypeID = 0
            $newApplicationAssingment.EnforcementDeadline = $newApplicationAssingment.ConvertFromDateTime($EnforcementDeadline)
        }

        [void] $newApplicationAssingment.Put()
        Return $newApplicationAssingment.AssignmentID
    }
} #End Start-CMNApplicationDeployment
