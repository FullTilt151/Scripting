if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
	Add-PSSnapin VMware.VimAutomation.Core
}

Connect-VIServer simvcswps05.rsc.humad.com     #Create the connection to the VCenter.

Import-Csv VMNames.csv -UseCulture | %{

    $vm = Get-VM -Name $_.VmName
    $folder = Get-Folder -Name $_.FolderName
    Start-VM -VM $vm.Name | Out-Null
    Move-VM -VM $vm -Destination $folder

} 
