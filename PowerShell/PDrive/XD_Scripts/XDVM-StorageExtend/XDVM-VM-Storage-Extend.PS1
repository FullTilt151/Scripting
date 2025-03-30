# XDVM-VM-Storage-Extend.ps1
# Extend storage on  VMs which have already had unallocated space assigned in VMWare.
# Brent Griffith and Craig Wood - Client Innovation Tech.
#
# Reads from a CSV named MachinesToExtend.csv stored in the same directory as this script.
#    Column 1 contains the name of the VM to upgrade. 
#    Column 2 contains the Storage value in GB of the partition.
#        This number represents the current size in GB + the already assigned, unallocated space, in GB.
#
#
# Results are written to an Excel workbook opened by this script. 
#
# v 1.0  - 02/15/16 - Initial script. 
#
#
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted

$ver = 1.0  #Script Version to be written to the display.

if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
	Add-PSSnapin VMware.VimAutomation.Core
}

Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 

Write-Host "XDVM-VM-Storage-Extend PowerShell Script Version" $ver

#CSV file which lists the VMs to be upgraded.
#Format for CSV found at the head of this script.
$Machine_List = 'MachinesToExtend.csv'
$Machines = Import-Csv $Machine_List -Header @("VM","GB")

$VMCount = 0      #Init the VM Counter.

#Setup the Excel Workbook for results.
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

$range = $Worksheet.Columns.Item(1)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(2)
$range.ColumnWidth = 38
$range.HorizontalAlignment = 3

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "Storage Extended"


foreach ($row in $Machines)   #Loop for each VM and extend the drive.
    {
    Write-Host $row.VM "- Information being retrieved."
    $VM = Get-VM $row.VM       #Get object for the VM in process.
    $VMCount++                 #Keep a count of the VM in porcess.  Used to locate ouput row in Workbook.
    $Worksheet.cells.Item($VMCount + 1,1) = $VM.Name     #Write the VM's name to the Workbook.
    
    #Resize the partition. 
    Get-HardDisk -VM $VM.Name | Set-HardDisk -ResizeGuestPartition -CapacityGB $row.GB -Confirm:$false 3> $null | out-null

    #Retrieve the VMWare storage information and Windows partition information.  
    $VMFreeSpace = Get-WmiObject Win32_logicaldisk -ComputerName $VM.Name -filter "DeviceID='C:'"
    $VMFreeSpaceGB = $VMFreeSpace.FreeSpace / 1073741824

    #Test to assure partition resize was successful.
    Write-Host $row.VM "Testing for successful hard drive extension."  

    #Retrieve Hard Disk info from VMWare
    $VMHDInfo = Get-HardDisk -VM $VM.Name 
    
    #Retrieve partition information available to the OS.
    $VMWIMI_DiskPartInfo = Get-WmiObject Win32_diskpartition -ComputerName $VM.Name  
    $PartTotal = 0
    foreach($partition in $VMWIMI_DiskPartInfo)   #Sum the partitions as seen by the OS for later comparison to info obtained from VMWare. 
        {
        $PartTotal += $partition.size
        }
    $PartTotalGB = ($PartTotal + 262144000)  / 1073741824  # Sum partitions in Bytes, add 250MB of Bytes, convert to GB.
    #Write-Host $Worksheet.cells.Item($c + 1,1).text "Size reported by Get-HardDisk =" $VMHDInfo.CapacityGB 
    #Write-Host $Worksheet.cells.Item($c + 1,1).text "Size of OS drives reported by WMI - All Partitions + 250MB =" $PartTotalGB 


    if ($VMHDInfo.CapacityGB -lt "$PartTotalGB")   #Test if the disk was extended then act/log accordingly.  
        {
        Write-Host $VM.Name "Storage extension verified successful."
        $Worksheet.cells.Item($VMCount + 1,2) = "Yes" #Store upgrade status to workbook.
        }
    else
        {
        Write-Host $VM.Name "Storage extension was unsuccessful."
        $Worksheet.cells.Item($VMCount + 1,2) = "No" #Store upgrade status to workbook.
        }


    }