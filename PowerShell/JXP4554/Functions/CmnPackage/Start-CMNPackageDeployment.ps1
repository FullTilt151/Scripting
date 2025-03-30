Function Start-CMNPackageDeployment {
    <#
	.SYNOPSIS
		Deploys a package to a specified collection

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

	.PARAMETER PackageID
		ID of Package to be deployed

	.PARAMETER Purpose
		Is this Available or Required

	.PARAMTER ProgramName
		Program from package to run

	.PARAMTER RequiredTime
		For Required deployments, the Scheduled Start Time.

	.PARAMETER Comment
		Comment for deployment

	.EXAMPLE
		Start-CMNPackageDeployment 'SMS00001' 'SMS00032' 'Available' 'Install'

	.NOTES

	.LINK
		http://configman-notes.com
	#>
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [PSObject]$sccmConnectionInfo,
        [Parameter(Mandatory = $true)]
        [String]$CollectionID,
        [Parameter(Mandatory = $true)]
        [String]$PackageID,
        [Parameter(Mandatory = $true, HelpMessage = 'Available/Required')]
        [String]$Purpose,
        [Parameter(Mandatory = $true, HelpMessage = 'Program to run')]
        [String]$ProgramName,
        [Parameter(Mandatory = $false, HelpMessage = 'Program Available Time')]
        [DateTime]$AvailableTime = (Get-Date),
        [Parameter(Mandatory = $false, HelpMessage = 'Program required time (only required if purpose is "Required")')]
        [String]$RequiredTime,
        [Parameter(Mandatory = $false, HelpMessage = 'Comment for deployment')]
        [String]$Comment,
        [Parameter(Mandatory = $false, HelpMessage = 'Set this deployment for Download and Run')]
        [switch]$IsDNR
    )

    #Check to see if the package already has a deployment to that collection.
    if (-not(Get-WmiObject -Class SMS_Advertisement -Filter "CollectionID = '$CollectionID' and PackageID = '$PackageID'" -Namespace $sccmConnectionInfo.NameSpace -ComputerName $sccmConnectionInfo.ComputerName)) {
        $Collection = Get-WmiObject -Class SMS_Collection -Filter "CollectionID = '$CollectionID'" @WMIQueryParameters
        $AdvertisementName = "$($Collection.Name) - $ProgramName"
        if ($Purpose -match 'Available') {
            $Purpose = 2
            $CMSchedule = $null
            $AssignScheduelEnabled = $false
        }
        else {
            $Purpose = 0
            $AssignScheduelEnabled = $true
            #Create Schedule Object
            $CMSchedule = ([WMIClass]"\\$($SiteServer)\Root\sms\site_$($SiteCode):SMS_ST_NonRecurring").CreateInstance()
            $CMSchedule.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-date $RequiredTime -Format "MM/dd/yyy hh:mm:ss"))
        }
        $NewDeployment = ([WMICLASS]"\\$($SiteServer)\root\sms\site_$($SiteCode):SMS_Advertisement").CreateInstance()
        $NewDeployment.ActionInProgress = 2;
        $NewDeployment.AdvertisementName = $AdvertisementName;
        $NewDeployment.AssignedScheduleEnabled = $AssignScheduelEnabled;
        $NewDeployment.AssignedScheduleIsGMT = $false;
        $NewDeployment.CollectionID = $CollectionID;
        $NewDeployment.Comment = $Comment;
        $NewDeployment.DeviceFlags = 0;
        $NewDeployment.OfferType = $Purpose;
        $NewDeployment.PackageID = $PackageID;
        $NewDeployment.PresentTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($AvailableTime);
        if ($AssignScheduelEnabled) {
            $NewDeployment.PresentTime = ConvertTo-CMNNDMTFDateTime $AvailableTime;
            $NewDeployment.AssignedSchedule = $CMSchedule;
            $NewDeployment.TimeFlags = Set-BitFlagForControl -IsControlEnabled $true -BitFlagHashTable $TimeFlags -CurrentValue $NewDeployment.TimeFlags -KeyName 'ENABLE_MANDATORY'
        }
        $NewDeployment.PresentTimeEnabled = $true;
        $NewDeployment.PresentTimeIsGMT = $false;
        $NewDeployment.Priority = 2;
        $NewDeployment.ProgramName = $ProgramName;
        if ($isDNR) {
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_REMOTE_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_LOCAL_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_REMOTE_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_LOCAL_DISPPOINT'
        }
        else {
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_REMOTE_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $false -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'DOWNLOAD_FROM_LOCAL_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_REMOTE_DISPPOINT'
            $NewDeployment.RemoteClientFlags = Set-BitFlagForControl -IsControlEnabled $true -CurrentValue $NewDeployment.RemoteClientFlags -BitFlagHashTable $RemoteClientFlags -KeyName 'RUN_FROM_LOCAL_DISPPOINT'
        }

        $NewDeployment.SourceSite = $SiteCode
        $NewDeployment.TimeFlags = Set-BitFlagForControl -IsControlEnabled $true -BitFlagHashTable $TimeFlags -CurrentValue $NewDeployment.TimeFlags -KeyName 'ENABLE_PRESENT'
        $NewDeployment.Put() | Out-Null
    }
} #End Start-CMNPackageDeployment
