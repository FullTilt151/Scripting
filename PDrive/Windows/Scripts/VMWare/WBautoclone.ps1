clear
$mycredentials = Get-Credential
Write-Host "You must have VMware vSphere PowerCLI installed to run this script"
Add-PSSnapin vmware.vimautomation.core -ea SilentlyContinue
#you can comment out (#) the connect command below if you are already connected to vcenter
connect-viserver grbvcswps02 -Credential $mycredentials


#Customization Spec Name
$CustSpec = Get-OSCustomizationSpec "WBW7"
#VM Folder to place new linked clones
#$TargetFolder  = "NewBuildsReady"
#CSV file with list of VM's  newname, vmname
$VMList_File = "C:\temp\vmlistfix.csv"
#File that will keep track of VM's that are Powered on
$PoweredOnClones_File = "C:\temp\poweredonclones.csv"
#Naming convention of DS Master
$DSMasterSearch = "W7_WBT_0916_DS" 
#Number of Clones to create before sleeping
[int]$clones = 10
#Seconds to sleep (10 minutes = 600)
[int]$sleeptime = 600
#Error Handling - comment out (#) if you are having issues and need to see errors
#$ErrorActionPreference = "SilentlyContinue"

#!!!!DO NOT EDIT BELOW THIS LINE!!!

[int]$totalvms = 36
[int]$timer = 0
[int]$timertotal = 0

import-csv $VMList_File | ForEach-Object {

$NewName = $_.NewName
$CloneName = $_.CloneName
$TargetFolder  = $_.folder

#Find the DS master that is on the Datastore with most available Freespace
$a = get-vm -name $DSMasterSearch* | select datastoreidlist -ExpandProperty datastoreidlist
$b = get-datastore -id $a | sort FreeSpaceMB -Descending | select -First 1 -expandproperty name
$b = $b.substring(32,2)

$sourceVM = get-vm -name $DSMasterSearch$b

#Check if the VM is powered on and if so, skip it and write to csv file $PoweredOnClones_File
$Power = get-vm $NewName | Select -Property Powerstate -ExpandProperty Powerstate
If ( $Power -eq "PoweredOn")

{"{0},{1}" -f $NewName,$CloneName | add-content -path $PoweredOnClones_File
Write-host "$Newname is powered on, Skipping"} 

Else { 
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
Write-host "$timer Machines built this round"
Write-host "$timertotal Machines Total"
if ($timer -eq $clones) { Write-host "Waiting for Clones to catch up. $totalvms left to clone"
start-sleep -s $sleeptime 
[int]$timer = 0 }
else {}
}
}