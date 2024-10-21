# CR#4536
# CR Name: Humana SCCM Cache Size 1.0  
# Doc Owner: Daniel Ratliff
# Description: This script will update Microsoft System Center Configuration Manager (2007) Client cache size to 10240MB free disk space maximum.
#
write-host "====================" -foregroundcolor cyan -backgroundcolor black
write-host "This script will update Microsoft System Center Configuration Manager (2007) Client cache size to 10240MB free disk space maximum." -foregroundcolor cyan
write-host "====================" -foregroundcolor cyan -backgroundcolor black
write-host ""

$cache = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class CacheConfig

write-host "Current SCCM Cache Size: "$cache.size  -foregroundcolor cyan
write-host ""

if ($cache.size -lt 10240) {
  write-host "Changing SCCM Cache Size to 10240 MB..." -foregroundcolor cyan
  $cache.Size = "10240"
  $cache.Put() | out-null
  write-host "Restarting CCMEXEC service..." -foregroundcolor cyan
  restart-service ccmexec
  write-host "Current SCCM Cache Size: "$cache.size  -foregroundcolor cyan
} else {
    write-host "Current SCCM Cache Size does not need to be changed!" -foregroundcolor yellow
    write-host ""    
}