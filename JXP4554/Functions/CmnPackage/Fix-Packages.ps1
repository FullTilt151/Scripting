$sccmConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS1825
$WMIQueryString = $sccmConnectionInfo.WMIQueryParameters
$objectID = get-cmnobjectcontainernodeidbyname -sccmConnectionInfo $sccmConnectionInfo -Name 'EST Packages' -ObjectType SMS_Package
$pacakgeIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $sccmConnectionInfo -ParentContainerNodeID $objectID -ObjectType SMS_Package
foreach ($packageID in $pacakgeIDs) {
    $deployments = get-wmiobject -Query "Select * from SMS_Advertisement where PackageID = '$packageID'" @WMIQueryString
    foreach ($deployment in $deployments) {
        $deployment.Get()
        Write-Output "Updating PackageID $($deployment.PackageID): Deployment $($deployment.AdvertisementID) - $($deployment.AdvertisementName)"
        $deployment.RemoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $false -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName 'DOWNLOAD_FROM_CD' -CurrentValue $deployment.RemoteClientFlags
        $deployment.RemoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName 'DOWNLOAD_FROM_LOCAL_DISPPOINT' -CurrentValue $deployment.RemoteClientFlags
        $deployment.RemoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $true -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName 'DOWNLOAD_FROM_REMOTE_DISPPOINT' -CurrentValue $deployment.RemoteClientFlags
        $deployment.RemoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $false -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName 'RUN_FROM_CD' -CurrentValue $deployment.RemoteClientFlags
        $deployment.RemoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $false -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName 'RUN_FROM_REMOTE_DISPPOINT' -CurrentValue $deployment.RemoteClientFlags
        $deployment.RemoteClientFlags = Set-CMNBitFlagForControl -ProposedValue $false -BitFlagHashTable $SMS_Advertisement_RemoteClientFlags -KeyName 'RUN_FROM_LOCAL_DISPPOINT' -CurrentValue $deployment.RemoteClientFlags
        #Check if required, if so create new schedule
        if($deployment.OfferType -eq 0){
            Write-Output "`tAdding schedule"
            $ScheduleTime = ([WMIClass] "\\$($SCCMConnectionInfo.ComputerName)\$($SCCMConnectionInfo.NameSpace):SMS_ST_NonRecurring").CreateInstance()
            $ScheduleTime.DayDuration = 0
            $ScheduleTime.HourDuration = 0
            $ScheduleTime.IsGMT = $false
            $ScheduleTime.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-date -Format G))
            $deployment.AssignedSchedule += $ScheduleTime
        }
        $deployment.Put() | Out-Null
    }
}