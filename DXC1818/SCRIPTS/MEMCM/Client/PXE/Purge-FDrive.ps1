[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

$wkids = Get-Content -Path $InputPath
$wkids | ForEach-Object {
    Invoke-Command -ComputerName $_ { & cmd /c "C:\Program Files\1E\Client\Extensibility\NomadBranch\CacheCleaner.exe" -DeleteAll -Force=9 }
    function GetCacheElements {
        $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
        $global:Cache = $UIResourceMgr.GetCacheInfo()
        $global:CacheElements = $Cache.GetCacheElements()
        $global:CacheElements | Sort-Object ContentID, ContentVersion #| Format-Table -AutoSize
    }
    GetCacheElements
    foreach ($element in $global:CacheElements) {
        $elementid = $element.cacheelementid
        write-host "Deleting: $elementid"
        $cache.DeleteCacheElement($elementid)
    }
}
