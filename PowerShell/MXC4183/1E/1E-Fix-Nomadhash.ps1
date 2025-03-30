#Nomad hash error fix from 1E. This disables IIS from caching .lsz files on the DPs
Start-Process -FilePath "c:\windows\system32\inetsrv\appcmd.exe" -ArgumentList 'set config -section:system.webServer/caching /+"profiles.[extension='.lsz',policy='DisableCache',kernelCachePolicy='DisableCache']" /commit:apphost'
