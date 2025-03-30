$UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
$Cache = $UIResourceMgr.GetCacheInfo()
$CacheElements = $Cache.GetCacheElements() | select ContentID,ContentVersion,ContentSize,CacheElementID
$ItemToRemove = $CacheElements | Out-GridView -PassThru
$Cache.DeleteCacheElement($ItemToRemove.CacheElementId)