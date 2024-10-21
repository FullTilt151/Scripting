param (
    [Parameter(Mandatory=$True)]
    $PackageID,
    $RevisionToKeep
)

$UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
$Cache = $UIResourceMgr.GetCacheInfo()
$CacheElements = $Cache.GetCacheElements() | select ContentID,ContentVersion, CacheElementID
$CacheFiltered = $CacheElements | where {$_.contentid -eq "$packageid" -and $_.ContentVersion -ne $RevisionToKeep} | Sort-Object ContentID

foreach ($elementid in $CacheFiltered) {
    write-host "Deleting "$elementid.contentid" - "$elementid.ContentVersion" - "$elementid.cacheelementid
    $Cache.DeleteCacheElement($elementid.cacheelementid)
}