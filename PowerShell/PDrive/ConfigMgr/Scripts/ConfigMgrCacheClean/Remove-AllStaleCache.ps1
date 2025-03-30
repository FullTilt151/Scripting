param(
$WhatIf = $true
)

$UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
$Cache = $UIResourceMgr.GetCacheInfo()
$CacheElements = $Cache.GetCacheElements()
$ElementGroup = $CacheElements | Group-Object ContentID

foreach ($ElementID in $ElementGroup) {
    if ($ElementID.Count -gt 1) {
        write-host "Found"$ElementID.Name"with"$ElementID.Count"versions. " -ForegroundColor Yellow -NoNewline
        $max = ($ElementID.Group.ContentVersion | Measure-Object -Maximum).Maximum
        write-host "Max version is"$max -ForegroundColor Yellow
        
        $ElementsToRemove = $CacheElements | where {$_.contentid -eq $ElementID.Name -and $_.ContentVersion -ne $Max}
        foreach ($Element in $ElementsToRemove) {
            write-host "Deleting"$Element.ContentID"with version"$Element.ContentVersion -ForegroundColor Red
            if ($WhatIf -eq $false) {
                $Cache.DeleteCacheElement($Element.CacheElementId)
            }
        }
    } elseif ($ElementID.Count -eq 1) {
        write-host "Found"$ElementID.Name"with"$ElementID.Count"version. " -ForegroundColor Green
    }
}