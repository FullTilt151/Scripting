param(
[switch]$Nomad
)

function GetCacheElements {
    $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
    $global:Cache = $UIResourceMgr.GetCacheInfo()
    $global:CacheElements = $Cache.GetCacheElements()
    $global:CacheElements | Sort-Object ContentID,ContentVersion | ft -AutoSize
}

GetCacheElements

foreach ($element in $global:CacheElements) {
    $elementid = $element.cacheelementid
    write-host "Deleting: $elementid"
    $cache.DeleteCacheElement($elementid)
}

if ($Nomad) {
    Restart-Service NomadBranch
    & 'C:\Program Files\1E\NomadBranch\NomadBranch.exe' -ActivateAll
}