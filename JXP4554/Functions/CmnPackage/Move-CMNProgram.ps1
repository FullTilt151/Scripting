Function Move-CMNProgram {
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
        [PSObject]$MoveDeployment,

        [Parameter(Mandatory = $false)]
        [Switch]$CopyDeployment = $false
    )
    $Error.Clear()
    $objAdvertisment = Get-WmiObject @WMIQueryParameters -class SMS_Advertisement -Filter "AdvertisementID = '$($MoveDeployment.DeploymentID)'"
    $objAdvertisment.Get()
    if ($CopyDeployment) {
        try {
            $NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_Advertisement").CreateInstance()
            $NewDeployment.ActionInProgress = $objAdvertisment.ActionInProgress
            $NewDeployment.AdvertFlags = $objAdvertisment.AdvertFlags;
            $NewDeployment.AdvertisementName = $objAdvertisment.AdvertisementName;
            $NewDeployment.AssignedSchedule = $objAdvertisment.AssignedSchedule;
            $NewDeployment.AssignedScheduleEnabled = $objAdvertisment.AssignedScheduleEnabled;
            $NewDeployment.AssignedScheduleIsGMT = $objAdvertisment.AssignedScheduleIsGMT;
            $NewDeployment.CollectionID = $ToCollectionID;
            $NewDeployment.Comment = $objAdvertisment.Comment;
            $NewDeployment.DeviceFlags = $objAdvertisment.DeviceFlags;
            $NewDeployment.ExpirationTime = $objAdvertisment.ExpirationTime;
            $NewDeployment.ExpirationTimeEnabled = $objAdvertisment.ExpirationTimeEnabled;
            $NewDeployment.HierarchyPath = $objAdvertisment.HierarchyPath
            $NewDeployment.IncludeSubCollection = $objAdvertisment.IncludeSubCollection;
            $NewDeployment.ISVData = $objAdvertisment.ISVData;
            $NewDeployment.ISVDataSize = $objAdvertisment.ISVDataSize;
            $NewDeployment.IsVersionCompatible = $objAdvertisment.IsVersionCompatible;
            $NewDeployment.MandatoryCountdown = $objAdvertisment.MandatoryCountdown;
            $NewDeployment.OfferType = $objAdvertisment.OfferType;
            $NewDeployment.PackageID = $objAdvertisment.PackageID;
            $NewDeployment.PresentTime = $objAdvertisment.PresentTime;
            $NewDeployment.PresentTimeEnabled = $objAdvertisment.PresentTimeEnabled;
            $NewDeployment.PresentTimeIsGMT = $objAdvertisment.PresentTimeIsGMT;
            $NewDeployment.Priority = $objAdvertisment.Priority;
            $NewDeployment.ProgramName = $objAdvertisment.ProgramName;
            $NewDeployment.RemoteClientFlags = $objAdvertisment.RemoteClientFlags;
            $NewDeployment.SourceSite = $objAdvertisment.SourceSite;
            $NewDeployment.TimeFlags = $objAdvertisment.TimeFlags
            $NewDeployment.Put() | Out-Null
        }
        catch [system.exception] {
            Throw "Had an error - Not copying deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID). Error $Error"
        }
    }
    else {
        try {
            $objAdvertisment.CollectionID = $ToCollectionID
            $objAdvertisment.put() | Out-Null
        }
        catch [system.exception] {
            Throw "Had an error - Not moving deployment $($objAdvertisment.PackageID) - $($objAdvertisment.AdvertisementID). Error $Error"
        }
    }
} # End Move-CMNProgram
