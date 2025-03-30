# XDHost-HWSummary.ps1
# Obtain a hardware summary of each host supporting XenDestops.
# Brent Griffith - Client Innovation Tech.
#
# v 1.0  - 11/23/15 - Initial script to write Name, Manufacturer, Model, Number of CPUs, CPU Type, CPU Family, and total memory. 
# v 1.1  - 10/17/17 - Added tracking of VMs, RAM, and CPUs per cluster as well as VM tracking for the environment. 

Set-ExecutionPolicy -ExecutionPolicy Unrestricted
if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
    {
	    Add-PSSnapin VMware.VimAutomation.Core
    }
Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 

# Init some Variables
$VMHostCount = 0       #Catch the numbers of VMs per Host.
$VMClusterCount = 0    #Track the VMs per Cluster
$VMEnvCount = 0        #Track the total count of VMs in the environment. 

$CPUClusterCount = 0   #Track the number of CPUs in the cluser
$RAMCLusterCount = 0   #Track the RAM across all hosts in the cluster

#Setup the Excel Workbook
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

#Set the width of the columns appropriate to the output.  
$excel.Range("A1").ColumnWidth = 32
$excel.Range("B1").ColumnWidth = 7
$excel.Range("C1").ColumnWidth =24
$excel.Range("D1").ColumnWidth = 9
$excel.Range("E1").ColumnWidth = 46
$excel.Range("F1").ColumnWidth = 23
$excel.Range("G1").ColumnWidth = 15

#Get the list of clusters used to support XenDesktops
$XDClusters = get-cluster -Name "*xendesktop-[ls]*" | Sort

#Add a count of the clusters to the Workbook
$Worksheet.cells.Item(1,1) = "Number of Clusters"
$Worksheet.cells.Item(1,2) = $XDClusters.count

$row = 3 #Set the workbook row on which to start writing data

for ($c=0; $c -lt $XDClusters.count; $c++)  #Loop through the Clusters
{
    $Worksheet.cells.Item($row,1) = $XDClusters[$c].name   #Write the name of the current cluster. 
    $Worksheet.cells.Item($row,1).Font.ColorIndex = 4
   
    $Hosts = $XDClusters[$c] | Get-VMHost | sort         #Determine the list of Hosts within the current cluster.
    $row++

    $Worksheet.cells.Item($row,1) = "Number of Hosts : " + $hosts.count     #Write the numbers of hosts in the current cluster.
    $row++
    
    #Write the column headings for the cluster’s WH data. 
    for ($col=1; $col -le 7;$col++) {$Worksheet.cells.Item($row,$col).Font.ColorIndex = 3}
    $Worksheet.cells.Item($row,1) = "Host Name"
    $Worksheet.cells.Item($row,2) = "Make"
    $Worksheet.cells.Item($row,3) = "Model"
    $Worksheet.cells.Item($row,4) = "Num CPU"
    $Worksheet.cells.Item($row,5) = "CPU Type"
    $Worksheet.cells.Item($row,6) = "CPU Family"
    $Worksheet.cells.Item($row,7) = "Memory"
    $row++

    #Init counters for the next cluster. 
    $VMClusterCount = 0    #Reset the VM counter per cluster to 0.
    $CPUClusterCount = 0   #Reset the CPUs in the cluser counter to 0.
    $RAMCLusterCount = 0   #Reset the RAM across all hosts in the cluster counter to 0.

    for ($h=0; $h -lt $hosts.count; $h++)  #Loop throguh the hosts for the given cluster.
    { 
        #Write HW infor for each host.
        $Worksheet.cells.Item($row,1) = $Hosts[$h].name
        $Worksheet.cells.Item($row,2) = $hosts[$h].Manufacturer
        $Worksheet.cells.Item($row,3) = $hosts[$h].Model
        $Worksheet.cells.Item($row,4) = $hosts[$h].NumCpu
        $Worksheet.cells.Item($row,5) = $hosts[$h].ProcessorType
        $Worksheet.cells.Item($row,6) = ($hosts[$h] | get-view).summary.CurrentEVCModeKey
        $Worksheet.cells.Item($row,7) = $hosts[$h].MemoryTotalGB
        $row++
        $VMHostCount = $hosts[$h] | Get-View
        $VMClusterCount = $VMClusterCount + $VMHostCount.vm.count  #Add to the VM count tracking this cluster. 
        $CPUClusterCount = $CPUClusterCount + $hosts[$h].NumCpu
        $RAMCLusterCount = $RAMCLusterCount + $hosts[$h].MemoryTotalGB
    }
    $row++
    $Worksheet.cells.Item($row,1) = "VM Count"
    $Worksheet.cells.Item($row,2) = $VMClusterCount
    $VMEnvCount = $VMEnvCount + $VMClusterCount   #Add to the Environment wide VM count.
    $row++
    $Worksheet.cells.Item($row,1) = "Total CPUs"
    $Worksheet.cells.Item($row,2) = $CPUClusterCount
    $row++ 
    $Worksheet.cells.Item($row,1) = "Total RAM"
    $Worksheet.cells.Item($row,2) = $RAMCLusterCount
    $row+=2
}

$Worksheet.cells.Item($row,1) = "Total VM Count"
$Worksheet.cells.Item($row,2) = $VMEnvCount
