On Error Resume Next  
Dim nValueToSet   
Dim oUIResource   
Set oUIResource = CreateObject("UIResource.UIResourceMgr")   
Set CacheSize = oUIResource.GetCacheInfo   
newCacheSize = 10240 '5120
wscript.echo "current cache size: " & CacheSize.TotalSize
'if CacheSize.TotalSize <= newCacheSize then   
  CacheSize.TotalSize = newCacheSize   
  wscript.echo "Setting new cache size to " & newCacheSize
  wscript.echo "new cache size: " & CacheSize.TotalSize
'end if 
