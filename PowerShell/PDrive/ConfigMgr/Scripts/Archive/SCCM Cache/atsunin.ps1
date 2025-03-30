# CR#4536
# CR Name: Humana SCCM Cache Size 1.0  
# Doc Owner: Daniel Ratliff
# Description: This script will update Microsoft System Center Configuration Manager (2007) Client cache size to 5120MB free disk space maximum.
#
write-host "====================" -foregroundcolor cyan -backgroundcolor black
write-host "This script will update Microsoft System Center Configuration Manager (2007) Client cache size to 5120MB free disk space maximum." -foregroundcolor cyan
write-host "====================" -foregroundcolor cyan -backgroundcolor black
write-host ""

$cache = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Class CacheConfig

write-host "Current SCCM Cache Size: "$cache.size  -foregroundcolor cyan
write-host ""

if ($cache.size -ne 5120) {
  write-host "Changing SCCM Cache Size to 5120 MB..." -foregroundcolor cyan
  $cache.Size = "5120"
  $cache.Put() | out-null
  write-host "Restarting CCMEXEC service..." -foregroundcolor cyan
  restart-service ccmexec
  write-host "Current SCCM Cache Size: "$cache.size  -foregroundcolor cyan
} else {
    write-host "Current SCCM Cache Size does not need to be changed!" -foregroundcolor yellow
    write-host ""
}