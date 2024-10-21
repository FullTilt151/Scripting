clear
$sw = [system.diagnostics.stopwatch]::startNew()
$mycredentials = Get-Credential
Write-Host "You must have VMware vSphere PowerCLI installed to run this script"
Add-PSSnapin vmware.vimautomation.core -ea SilentlyContinue
Import-Module active*
#you can comment out (#) the connect command below if you are already connected to vcenter
connect-viserver grbvcswps02 -Credential $mycredentials

#winbatch cluster name
$vmcluster = "HUM-DC-VDI-GDC-C02"
#Customization Spec Name
$CustSpec = Get-OSCustomizationSpec "WBW7"
#VM Folder to place new linked clones
#$TargetFolder  = "NewBuildsReady"
#CSV file with list of VM's  newname, vmname
$VMList_File = "C:\temp\missing.csv"
#File that will keep track of VM's that are Powered on
$PoweredOnClones_File = "C:\temp\poweredonclones.csv"
$missing = "c:\temp\missing.csv"
#Naming convention of DS Master
$DSMasterSearch = "W7_WBT_0416_DS" 
#Number of Clones to create before sleeping
[int]$clones = 15
#Seconds to sleep (10 minutes = 600)
[int]$sleeptime = 600
#Error Handling - comment out (#) if you are having issues and need to see errors
#$ErrorActionPreference = "SilentlyContinue"

#!!!!DO NOT EDIT BELOW THIS LINE!!!
$a = import-csv $VMList_File
$minutes = [int]$sleeptime / 60
[int]$totalvms = [int]$a.count - 1
[int]$timer = 0
[int]$timertotal = 0

write-host "There is a total of $totalvms vm's to be cloned" -ForegroundColor Yellow
write-host "We are cloning $clones per session" -ForegroundColor Yellow
write-host "There will be a $minutes minute wait time between sessions" -ForegroundColor Yellow
write-host "shutting down cluster HA during cloning" -ForegroundColor Magenta
get-cluster -Name $vmcluster | Set-Cluster -HAEnabled:$false -DrsEnabled:$true -Confirm:$false
import-csv $VMList_File | ForEach-Object {

$NewName = $_.NewName
$CloneName = $_.CloneName
$TargetFolder  = $_.folder

#shutdown the vm
try {shutdown-VMGuest -vm $NewName -Confirm:$false -ErrorAction stop
       write-host "Shutting down $NewName" -ForegroundColor Green}
       catch {write-host "$NewName is already shut down" -ForegroundColor Red}
      
        

#Find the DS master that is on the Datastore with most available Freespace
$a = get-vm -name $DSMasterSearch* | select datastoreidlist -ExpandProperty datastoreidlist
$b = get-datastore -id $a | sort FreeSpaceMB -Descending | select -First 1 -expandproperty name
$b = $b.substring(32,2)

$sourceVM = get-vm -name $DSMasterSearch$b

[int]$totalvms = $totalvms - 1
[int]$timer = $timer + 1
[int]$timertotal = $timertotal + 1
Remove-VM -DeletePermanently -VM $NewName -Confirm:$false 

$cloneFolder = Get-View ( Get-Folder -Name $targetFolder ).ID
$vm = Get-VM $SourceVM
$vmView = $vm | Get-View

$cloneSpec = new-object Vmware.Vim.VirtualMachineCloneSpec
$cloneSpec.Snapshot = $vmView.Snapshot.CurrentSnapshot
$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec
$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking
$vmView.CloneVM( $cloneFolder.MoRef, $cloneName, $cloneSpec )

Set-VM $cloneName -OSCustomizationSpec $CustSpec -Confirm:$false
Set-VM $cloneName -Name $NewName -Confirm:$false
Start-VM -VM $NewName -Confirm:$false
Write-host "$NewName complete"

#timer
Write-host "$timer Machines built this round" -ForegroundColor Yellow
Write-host "$timertotal Machines Total" -ForegroundColor Yellow

#turning Cluster HA back on
write-host "Turning Cluster HA back on while machines catch up" -ForegroundColor Magenta
get-cluster -Name $vmcluster | Set-Cluster -HAEnabled:$true -DrsEnabled:$true -Confirm:$false
if ($timer -eq $clones) { 

Write-host "Waiting $minutes minutes for Clones to catch up. $totalvms left to clone" -ForegroundColor Yellow

for ($a=$sleeptime; $a -gt 1; $a--) {
  Write-Progress -Activity "Working..." -SecondsRemaining $a "Please wait."
  Start-Sleep 1
}

[int]$timer = 0 }
else {}
}



#flush dns and wait 15 minutes before testing if vm's are available
ipconfig /flushdns
clear
write-host "Waiting 15 minutes for everything to finish up before testing list completion" -ForegroundColor green
for ($a=900; $a -gt 1; $a--) {
  Write-Progress -Activity "Working..." -SecondsRemaining $a "Please wait."
  Start-Sleep 1
}



#test that vm's are available and create new list for missing vm's

$missing = "c:\temp\missing.csv"
$header = "CloneName,NewName,folder"
$present = Test-Path -Path $missing
if ($present -like "True"){
Remove-Item $missing -Force
}

add-content -Path C:\temp\missing.csv "$header" 


import-csv -Path $serverlist | ForEach-Object {

$Server = $_.CloneName
$vmName = $_.NewName
$folder = $_.folder

  $rtn = Test-Connection -CN $server -Count 1 -BufferSize 16 -Quiet

  IF($rtn -match 'False') {write-host -ForegroundColor Red $server
  $serverinfo = "$server,$vmname,$folder"
  add-content -Path C:\temp\missing.csv "$serverinfo" }

  ELSE { Write-host -ForegroundColor green $server }
  
}

#count the vm's that can't connect
$a = import-csv $missing
[int]$totalvms = [int]$a.count - 1
[int]$timer = 0
[int]$timertotal = 0

#rerun the cloning for the vm's that are missing
while ($totalvms -gt 0) {

write-host "There is a total of $totalvms vm's to be cloned" -ForegroundColor Yellow
write-host "We are cloning $clones per session" -ForegroundColor Yellow
write-host "There will be a $minutes minute wait time between sessions" -ForegroundColor Yellow
write-host "shutting down cluster HA during cloning" -ForegroundColor Magenta
get-cluster -Name $vmcluster | Set-Cluster -HAEnabled:$false -DrsEnabled:$true -Confirm:$false
import-csv $VMList_File | ForEach-Object {

$NewName = $_.NewName
$CloneName = $_.CloneName
$TargetFolder  = $_.folder

#shutdown the vm
try {shutdown-VMGuest -vm $NewName -Confirm:$false -ErrorAction stop
       write-host "Shutting down $NewName" -ForegroundColor Green}
       catch {write-host "$NewName is already shut down" -ForegroundColor Red}
      
        

#Find the DS master that is on the Datastore with most available Freespace
$a = get-vm -name $DSMasterSearch* | select datastoreidlist -ExpandProperty datastoreidlist
$b = get-datastore -id $a | sort FreeSpaceMB -Descending | select -First 1 -expandproperty name
$b = $b.substring(32,2)

$sourceVM = get-vm -name $DSMasterSearch$b

[int]$totalvms = $totalvms - 1
[int]$timer = $timer + 1
[int]$timertotal = $timertotal + 1
Remove-VM -DeletePermanently -VM $NewName -Confirm:$false 

$cloneFolder = Get-View ( Get-Folder -Name $targetFolder ).ID
$vm = Get-VM $SourceVM
$vmView = $vm | Get-View

$cloneSpec = new-object Vmware.Vim.VirtualMachineCloneSpec
$cloneSpec.Snapshot = $vmView.Snapshot.CurrentSnapshot
$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec
$cloneSpec.Location.DiskMoveType = [Vmware.Vim.VirtualMachineRelocateDiskMoveOptions]::createNewChildDiskBacking
$vmView.CloneVM( $cloneFolder.MoRef, $cloneName, $cloneSpec )

Set-VM $cloneName -OSCustomizationSpec $CustSpec -Confirm:$false
Set-VM $cloneName -Name $NewName -Confirm:$false
Start-VM -VM $NewName -Confirm:$false
Write-host "$NewName complete"

#timer
Write-host "$timer Machines built this round" -ForegroundColor Yellow
Write-host "$timertotal Machines Total" -ForegroundColor Yellow

#turning Cluster HA back on
write-host "Turning Cluster HA back on while machines catch up" -ForegroundColor Magenta
get-cluster -Name $vmcluster | Set-Cluster -HAEnabled:$true -DrsEnabled:$true -Confirm:$false
if ($timer -eq $clones) { 

Write-host "Waiting $minutes minutes for Clones to catch up. $totalvms left to clone" -ForegroundColor Yellow

for ($a=$sleeptime; $a -gt 1; $a--) {
  Write-Progress -Activity "Working..." -SecondsRemaining $a "Please wait."
  Start-Sleep 1
}

[int]$timer = 0 }
else {}
}
  

$a = import-csv $missing
[int]$totalvms = [int]$a.count - 1
[int]$timer = 0
[int]$timertotal = 0

}

clear
$elapsedmin = $sw.Elapsed.Minutes
$elapsedhour = $sw.Elapsed.Hours
write-host "Cloning is complete" -ForegroundColor Green
$a = import-csv $VMList_File
[int]$totalvms = [int]$a.count - 1
write-host "$totalvms have been cloned" -ForegroundColor Green
write-host "Script took $elapsedmin minutes to complete" -ForegroundColor Green
write-host "Script took $elapsedhour hours to complete" -ForegroundColor Green
$sw | Format-list -Property *