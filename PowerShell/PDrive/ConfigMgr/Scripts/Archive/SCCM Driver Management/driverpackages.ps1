$server="LOUAPPWPS207"
$site="HUM"

$oldlocfilter="\\louappwps207\drivers$*"
$oldloc="drivers$"
$newloc="driverpackages$"

$driverpackagess = Get-WmiObject SMS_DriverPackage -computername $server -Namespace root\SMS\site_$site
 
$driverpackages | where {$_.PkgSourcePath -like $oldlocfilter} | 
ForEach-Object {
      write-host $_.Name
      write-host $_.PackageID
      $pkgsource = $_.PkgSourcePath
      write-host "Old source: "$pkgsource
      $pkgsource = $pkgsource.replace($oldloc,$newloc)
      $_.PkgSourcePath = $pkgsource
      $_.Put() | out-null
      write-host "New source: "$_.PkgSourcePath
      write-host ""
}