# XDHost-HWSummary.ps1
# Obtain a hardware summary of each host supporting XenDestops.
# Brent Griffith - Client Innovation Tech.
#
# v 1.0  - 11/23/15 - Initial script to write Name, Manufacturer, Model, Number of CPUs, CPU Type, CPU Family, and total memory. 


Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 

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
    }
    $row++
}


