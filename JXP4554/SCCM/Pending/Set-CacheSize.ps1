$cache = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class CacheConfig
$cache.Size = 51200
$cache.Location = 'D:\ccmcache'
$cache.Put()
Restart-Service CcmExec