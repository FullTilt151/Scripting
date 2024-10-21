clear
$mycredentials = Get-Credential 
connect-viserver grbvcswps02 -Credential $mycredentials

$PoweredOnClones_File = "c:\temp\vmDisk.csv"
$VMList_File = "C:\temp\Production Machines_201609.csv"


get-vm| ForEach-Object {

$NewName = $_.NewName
$disk = get-vm $NewName | get-harddisk
$basedisk = $disk.ExtensionData.Backing.Parent.FileName
"{0},{1},{2}" -f $NewName,$CloneName,$basedisk | add-content -path $PoweredOnClones_File} 

