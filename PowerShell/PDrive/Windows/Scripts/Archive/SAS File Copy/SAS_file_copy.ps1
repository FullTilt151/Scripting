$pclist = get-content computers.txt
$logpath = "\c$\program files\sas\InstallMisc\InstallLogs\DeploymentSummary.html"

foreach ($pcname in $pclist) {
  new-item -name $pcname -type directory
  $copyfrom = "\\" + $pcname + $logpath
  move-item -path $copyfrom -dest $pcname
}