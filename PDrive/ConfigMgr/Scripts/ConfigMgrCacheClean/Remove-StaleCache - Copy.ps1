$UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
$Cache = $UIResourceMgr.GetCacheInfo()
$CacheElements = $Cache.GetCacheElements() | select ContentID,ContentVersion, CacheElementID | Sort-Object ContentID, ContentVersion -Descending

foreach ($elementid in $CacheElements) 
{
    #Find out if element in SCCM

    #Remove if it isn't

    #Make sure there is no older versions

    #Remove if there is
    #$Cache.DeleteCacheElement($elementid.cacheelementid)
}