$VMList_File = "c:\temp\vmlist_new.csv"
[int]$counter = 0  

$vms = get-content $VMList_File 
$vmcount = $vms.count

import-csv $VMList_File | ForEach-Object {

$vm = $_.CloneName
$counter = $counter + 1


$service1 = get-Service -computername $vm -name sftlist
$service1 | Stop-Service | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue


$service2 = get-Service -computername $vm -name sftvsa
$service2 | Stop-Service | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue

$servicestatus1 = $service1.Status
$servicestatus2 = $service2.Status


write-host "$vm sftlist service $servicestatus1"
write-host "$vm sftlist service $servicestatus2"


}
