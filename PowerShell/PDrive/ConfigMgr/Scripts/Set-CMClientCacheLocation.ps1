param(
$CacheLocation
)
Stop-Service CcmExec -Force
$ccmcfg = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class CacheConfig 
$ccmcfg.Location = $CacheLocation
$ccmcfg.Put()
Start-Service CcmExec