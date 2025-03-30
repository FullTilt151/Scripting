# XDHost-Check.ps1
# Check the status of each host supporting XenDestops
# Brent Griffith - Client Innovation Tech.
#
# v 1.0  - 11/23/15 - Initial script to derive Clusters with support XD VMs then walk the hosts within those clusters to check for status.  
# v 1.5  -  1/20/16 - Updated to return CPU and Memory In Use and Installed numbers per host.  Percentage in use calculated.
#                     CPU and Memory In Use value, percentage, and Installed are added, per host, to the resulting Excel Workbook. 


Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 

#Setup the Excel Workbook
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

$range = $Worksheet.Columns.Item(1)     #Set the width and centering of columns appropriate to the output.  
$range.ColumnWidth = 32
$range = $Worksheet.Columns.Item(2)
$range.ColumnWidth = 14
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(3)
$range.ColumnWidth = 14
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(4)
$range.ColumnWidth = 16
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(5)
$range.ColumnWidth = 16
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(6)
$range.ColumnWidth = 16
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(7)
$range.ColumnWidth = 16
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(8)
$range.ColumnWidth = 16
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(9)
$range.ColumnWidth = 16
$range.HorizontalAlignment = 3

#Get the list of clusters used to support XenDesktops
$XDClusters = get-cluster -Name "*xendesktop-[ls]*" | Sort

#Add a count of the clusters to the Workbook
$Worksheet.cells.Item(1,1) = "Number of Clusters"
$Worksheet.cells.Item(1,2) = $XDClusters.count

$row = 3 #Set the workbook row on which to start writing data

for ($c=0; $c -lt $XDClusters.count; $c++)  #Loop through the Clusters
{
    $Worksheet.cells.Item($row,1) = $XDClusters[$c].name                         #Write the name of the current cluster. 
   
    $Hosts = $XDClusters[$c] | Get-VMHost | sort         #Determine the list of Hosts within the current cluster.
    $row++
    $Worksheet.cells.Item($row,1) = "Number of Hosts : " + $hosts.count     #Write the numbers of hosts in the current cluster.
    $Worksheet.cells.Item($row,4) = "Mem Total - GB"

    $Worksheet.cells.Item($row,4) =
    
    $Worksheet.cells.Item($row,5) = "Mem Used - GB"
    $Worksheet.cells.Item($row,6) = "Mem Used %"
    $Worksheet.cells.Item($row,7) = "CPU Total Mhz"
    $Worksheet.cells.Item($row,8) = "CPU Used Mhz"
    $Worksheet.cells.Item($row,9) = "CPU Used %"
    $row++

    for ($h=0; $h -lt $hosts.count; $h++)  #Loop throguh the hosts for the given cluster.
    { 
        $Worksheet.cells.Item($row,1) = $Hosts[$h].name
        #Write the name and status of each host.  If that status is favorable set font to Green.  If it is not favorable set it to Red)
        if ($Hosts[$h].PowerState.ToString() -eq "PoweredOn") {$Worksheet.cells.Item($row,2).Font.ColorIndex = 4}   #4 is Green
            Else {$Worksheet.cells.Item($row,2).Font.ColorIndex = 3}    #3 is Red
        $Worksheet.cells.Item($row,2) = $Hosts[$h].PowerState.ToString()        
        if ($Hosts[$h].ConnectionState.ToString() -eq "Connected") {$Worksheet.cells.Item($row,3).Font.ColorIndex = 4}  #4 is Green
            Else {$Worksheet.cells.Item($row,3).Font.ColorIndex = 3}     #3 is Red
        $Worksheet.cells.Item($row,3) = $Hosts[$h].ConnectionState.ToString()
        $Worksheet.cells.Item($row,4) = [math]::round($Hosts[$h].MemoryTotalGB,2)
        $Worksheet.cells.Item($row,5) = [math]::round($Hosts[$h].MemoryUsageGB,2)
        $MemPercent = [math]::round(($Hosts[$h].MemoryUsageGB * 100)/$Hosts[$h].MemoryTotalGB,2)
        if ($MemPercent -ge 75 -And $MemPercent -le 89) {$Worksheet.cells.Item($row,6).Interior.ColorIndex = 45}  #45 is Orange
            Else {if ($MemPercent -ge 90) {$Worksheet.cells.Item($row,6).Interior.ColorIndex = 3}  } #3 is Red 
        $Worksheet.cells.Item($row,6) = $MemPercent
        $Worksheet.cells.Item($row,7) = $Hosts[$h].CpuTotalMhz
        $Worksheet.cells.Item($row,8) = $Hosts[$h].CpuUsageMhz
        $CpuPercent = [math]::round(($Hosts[$h].CpuUsageMhz * 100)/$Hosts[$h].CpuTotalMhz,2)
        if ($CpuPercent -ge 75 -And $CpuPercent -le 89) {$Worksheet.cells.Item($row,9).Interior.ColorIndex = 45}  #45 is Orange
            Else {if ($CpuPercent -ge 90) {$Worksheet.cells.Item($row,9).Interior.ColorIndex = 3}  } #3 is Red 
        $Worksheet.cells.Item($row,9) = $CpuPercent
        # $Worksheet.cells.Item($row,10) = $h     #Array Index.  Uncomment to write to the Workbook 
        $row++
    }
    $row++
}


