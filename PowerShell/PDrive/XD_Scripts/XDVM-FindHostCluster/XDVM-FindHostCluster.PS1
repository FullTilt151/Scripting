# XDVM-FindHostCluster.ps1
# Find the name of the host, and the name of that host's cluster, on which a VM is running.  Inputs VM names from a file. 
#
# Brent Griffith - Client Innovation Tech.
#
# v 1.0  - 11/17/17 - Initial script.  
# 


Set-ExecutionPolicy -ExecutionPolicy Unrestricted
if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
    {
	    Add-PSSnapin VMware.VimAutomation.Core
    }
Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 


# Init some Variables
$RowCount = 2   # Track the row number in the output spreadsheet. Row 1 contains the headers.

#CSV file which lists the VMs to be found.
#Format for CSV found at the head of this script.
$Machine_List = 'MachineList.csv'
$Machines = Import-Csv $Machine_List -Header @("VM")

#Setup the Excel Workbook
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True
#Set the width and centering of columns appropriate to the output.
$range = $Worksheet.Columns.Item(1)       
$range.ColumnWidth = 20
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(2)
$range.ColumnWidth = 35
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(3)
$range.ColumnWidth = 35
$range.HorizontalAlignment = 3


#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "Host"
$Worksheet.cells.Item(1,3) = "Cluster"

foreach ($VMToFind in $Machines)   #Loop for each VM
    {
    Write-Host $VMToFind.VM "- Information being retrieved."
    $vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = $VMToFind.VM}
    $vmhostView = Get-View -ID $vm.Runtime.Host
    $Cluster =  get-view -ID $vmhostView.parent
    $Worksheet.cells.Item($RowCount,1) = $VMToFind.VM
    $Worksheet.cells.Item($RowCount,2) = $vmhostView.Name
    $Worksheet.cells.Item($RowCount,3) = $cluster.Name
    $RowCount++
    }