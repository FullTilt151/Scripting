import-module d:\scripts\sccm_2007.psm1

$server="LOUAPPWPS207"
$site="HUM"

$oldlocfilter="\\louappwps207\drivers$\x230-Win7-Updated 9-07-12*"
$oldloc="x230-Win7-Updated 9-07-12"
$newloc="lnvo-x230"

connect-sccmserver -server $server -site $site

$drivers = Get-WmiObject SMS_Driver -computername $server -Namespace root\SMS\site_$site
 
$drivers | where {$_.ContentSourcePath -like $oldlocfilter} | 
ForEach-Object {
      write-host $_.LocalizedCategoryInstanceNames
      write-host $_.localizeddisplayname
      $driversource = $_.contentsourcepath
      write-host "Old source: "$driversource
      $driversource = $driversource.replace($oldloc,$newloc)
      $_.ContentSourcePath = $driversource
      $_.Put() | out-null
      write-host "New source: "$_.contentsourcepath
      write-host ""
}