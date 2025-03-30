#Connect to Resource Manager COM Object
$resman = new-object -ComObject "UIResource.UIResourceMgr"
$cacheInfo=$resman.GetCacheInfo()

#Enum Cache elements, compare date, and delete older than 60 days
foreach($cahceObject in $cacheinfo.GetCacheElements()){
    if((New-TimeSpan -Start $cahceObject.LastReferenceTime -End (Get-Date)).Days -ge 60){$cahceObject.DeleteCacheElement($cahceObject.CacheElementId)}
}
<#
$cpAppletMgr = New-Object -ComObject CPApplet.CPAppletMgr
ForEach-Object($applet in $cpAppletMgr){
    Write-Output ''
}
#>