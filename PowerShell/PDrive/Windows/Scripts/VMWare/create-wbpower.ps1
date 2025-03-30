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
$VMList_File = "C:\temp\newpower.csv"
$cluster = Get-Cluster HUM-DC-VDI-GDC-C02
$template = Get-Template -Location pwr_tmplt
$TargetFolder  = Get-View ( Get-Folder -Name pwr_tmplt ).ID
$sleeptime = 600



import-csv $VMList_File | ForEach-Object {

$CloneName = $_.CloneName

#Find the DS master that is on the Datastore with most available Freespace
$datastore = Get-Datastore -name GRB_HUM_PROD_C02_IBM_BTX30_*_01* | sort FreeSpaceMB -Descending | select -First 1 -expandproperty name


new-vm -name $clonename -template $template -datastore $datastore -Location $vmfolder –ResourcePool $cluster
Get-VM $CloneName | Set-VM -OSCustomizationSpec $CustSpec -Confirm:$false
}

import-csv $VMList_File | ForEach-Object {

$CloneName = $_.CloneName
get-vm -Name $clonename | move-vm -destination New_Power | Start-VM
start-sleep -s $sleeptime
}