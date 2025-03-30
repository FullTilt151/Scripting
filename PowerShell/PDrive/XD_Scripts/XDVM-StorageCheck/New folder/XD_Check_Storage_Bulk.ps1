if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
	Add-PSSnapin VMware.VimAutomation.Core
}

Connect-VIServer louvcswps05.rsc.humad.com

#CSV file which lists the VMs to be upgraded.
#Format for CSV found at the head of this script.
$Machine_List = 'MachinesToCheck.csv'
$Machines = Import-Csv $Machine_List -Header @("VM")

$VMCount = 0       #Init the VM Counter.

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
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "Available Storage"


foreach ($row in $Machines)   #Loop for each VM
    {
    Write-Host $row.VM "- Information being retrieved."
    $VM = Get-VM $row.VM       #Get object for the VM in process.
    $VMCount++                 #Keep a count of the VM in process
    $Worksheet.cells.Item($VMCount + 1,1) = $VM.Name     #Write the VM's name to the Workbook.
    $VMFreeSpace = Get-WmiObject Win32_logicaldisk -ComputerName $VM -filter "DeviceID='C:'"       #Grab available storage for C:
    $VMFreeSpaceGB = [math]::Round($VMFreeSpace.freespace / 1GB,2)     #Convert to GB with 2 decimal places.
    $Worksheet.cells.Item($VMCount + 1,2) = $VMFreeSpaceGB #Store storage available in worksheet
    }