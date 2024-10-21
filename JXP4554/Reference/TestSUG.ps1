$SrcCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWTS1140
$DstCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWQS1150
$WMISrcParameters = $SrcCon.WMIQueryParameters
$WMIDstParameters = $DstCon.WMIQueryParameters
$AuthLists = Get-WmiObject -Class SMS_AuthorizationList @WMISrcParameters
foreach($AuthList in $AuthLists){
    $AuthList.get()
    Write-Output "Working $($AuthList.LocalizedDisplayName)"
    foreach($update in $AuthList.Updates){
        $query = "SELECT * FROM SMS_SoftwareUpdate WHERE CI_ID='$update'"
        $srcupdate = Get-WmiObject -Query $query @WMISrcParameters
        $query = "SELECT * FROM SMS_SoftwareUpdate WHERE CI_UniqueID = '$($srcupdate.CI_UniqueID)'"
        $dstupdate = Get-WmiObject -Query $query @WMIDstParameters
        If($dstupdate){
            Write-Output "Src = $($srcupdate.CI_ID) - $($srcupdate.LocalizedDisplayName)"
            Write-Output "Dst = $($dstupdate.CI_ID) - $($dstupdate.LocalizedDisplayName)"
        }
        else{
            Write-Host -ForegroundColor Red "Missing $($srcupdate.CI_UniqueID) - $($srcupdate.LocalizedDisplayName)"
        }
    }
}

# SMS_SoftwareUpdate is the link