$ccmcfg = Get-WmiObject -Namespace rootccmSoftMgmtAgent -Class CacheConfig
Write-Host "Current cache location is " $ccmcfg.Location
$ccmcfg.Location = "B:"
$ccmcfg.Put()

Get-Service ccmexec | Stop-Service
Start-Sleep 10
Get-Service ccmexec | Start-Service