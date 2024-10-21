param (
    [Parameter(Mandatory=$True)]
    $PackageID,
    $Revision
)

if ($Revision -eq $null) {
    $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
    $Cache = $UIResourceMgr.GetCacheInfo()
    $CacheElements = $Cache.GetCacheElements() | select ContentID,ContentVersion, CacheElementID
    $CacheFiltered = $CacheElements | where {$_.contentid -eq "$packageid"} | Sort-Object ContentID
    $CacheFiltered

    foreach ($elementid in $CacheFiltered) {
        write-host "Deleting "$elementid.contentid" - "$elementid.ContentVersion" - "$elementid.cacheelementid
        $Cache.DeleteCacheElement($elementid.cacheelementid)
    }
} elseif ($Revision -ne $null) {
    $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
    $Cache = $UIResourceMgr.GetCacheInfo()
    $CacheElements = $Cache.GetCacheElements() | select ContentID,ContentVersion, CacheElementID
    $CacheFiltered = $CacheElements | where {$_.contentid -eq "$packageid" -and $_.contentversion -eq "$revision"} | Sort-Object ContentID
    $CacheFiltered

    foreach ($elementid in $CacheFiltered) {
        write-host "Deleting "$elementid.contentid" - "$elementid.ContentVersion" - "$elementid.cacheelementid
        $Cache.DeleteCacheElement($elementid.cacheelementid)
    }
}