Function Move-CMNApplication {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.EXAMPLE

	.PARAMETER Text

	.NOTES
		Not currently working
	.LINK
		http://configman-notes.com
	#>
    Param
    (
        [Parameter(Mandatory = $true)]
        [PSObject]$MoveDeployment
    )
    #New-LogEntry 'Starting Function' 1 'Move-CMNApplication'
    #DeploymentType 1 = install, 2=uninstall
    $objApplication = Get-CMApplication -Id $MoveDeployment.CI_ID
    $objDeployment = Get-WmiObject @WMIQueryParameters -class SMS_DeploymentInfo -Filter "DeploymentID = '$($MoveDeployment.DeploymentID)'"
    $objDeployment.Get()
    if ($MoveApplications -and ($objDeployment.DeploymentIntent -eq 2 -or ($objDeployment.DeploymentIntent -eq 3 -and $MoveRequired))) {
        if ($CopyDeployment) {
            try {
                $NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_DeploymentInfo").CreateInstance()
                $NewDeployment.CollectionID = $ToCollectionID;
                $NewDeployment.CollectionName = $MoveDeployment.CollectionName;
                $NewDeployment.DeploymentIntent = $objDeployment.DeploymentIntent;
                $NewDeployment.DeploymentType = $objDeployment.DeploymentType;
                $NewDeployment.TargetID = $objDeployment.TargetID;
                $NewDeployment.TargetName = $objDeployment.TargetName
                $NewDeployment.TargetSecurityTypeID = $objDeployment.TargetSecurityTypeID;
                $NewDeployment.TargetSubName = $objDeployment.TargetSubName;
                $NewDeployment.Put() | Out-Null
            }
            catch [system.exception] {
                Write-Error "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID)."
            }
        }
        else {
            try {
                $objDeployment.CollectionID = $ToCollectionID
                $objDeployment.put() | Out-Null
            }
            catch [system.exception] {
                Write-Error "Had an error - Not moving deployment $($objDeployment.DeploymentID) - $($objAdvertisment.AdvertisementID)."
            }
        }
    }
} # End Move-CMNApplication
