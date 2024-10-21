$UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
$Cache = $UIResourceMgr.GetCacheInfo()
$CacheElements = $Cache.GetCacheElements() | select ContentID,ContentVersion,ContentSize,CacheElementID

$RefPkgIDs = Get-WmiObject -ComputerName LOUAPPWPS875 -namespace root\sms\site_cas -class sms_tasksequencepackagereference -Filter "PackageID = 'CAS00083'" -Property ObjectID | Select-Object -ExpandProperty ObjectID
$RefPkgIDs += Get-WmiObject -ComputerName LOUAPPWPS875 -namespace root\sms\site_cas -class sms_tasksequencepackagereference -Filter "PackageID = 'CAS0086D'" -Property ObjectID | Select-Object -ExpandProperty ObjectID

foreach ($Element in $CacheElements) {
    if ($Element.ContentID -notin $RefPkgIDs) {
        Write-Output "Removing $($Element.ContentId)"
        $Cache.DeleteCacheElement($Element.CacheElementId)
    }
}