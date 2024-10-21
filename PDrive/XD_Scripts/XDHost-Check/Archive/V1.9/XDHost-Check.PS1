# XDHost-Check.ps1
# Check the status of each host supporting XenDesktops
# Brent Griffith - Client Innovation Tech.
#
# v 1.0  - 11/23/15 - Initial script to derive Clusters with support XD VMs then walk the hosts within those clusters to check for status.  
# v 1.5  -  1/20/16 - Updated to return CPU and Memory In Use and Installed numbers per host.  Percentage in use calculated.
#                     CPU and Memory In Use value, percentage, and Installed are added, per host, to the resulting Excel Workbook. 
# v 1.7  - 10/04/17 - Corrected mislabeled column heading. Mem Total - GB
#                   - Calculates Average CPU and RAM user per cluster. 
#                   - Determines if cluster growth is limited by CPU or RAM.
#                   - Calculates the number of VMs which could be added to drive the most constrained resource to 100%. 
# v 1.9  - 11/08/17 - Corrected issues with cell coloring when CPU or Memory is at 89%
#                   - Updated avg. CPU and Memory used calculation to account for disabled hosts.
#                   - Added accumulators to track total VMs in the environment and the total potential VMs that can be built.
#                   - Changed the formula which calculates potential VMs to build to use a variable set at the head of the script. 


Set-ExecutionPolicy -ExecutionPolicy Unrestricted
if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
    {
	    Add-PSSnapin VMware.VimAutomation.Core
    }
Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 

#Constants
$MaxPercent = 80    #The maximum percent to load resources when calculating potential VMs to build. 

# Init some Variables
$VMHostCount = 0       #Catch the numbers of VMs per Host.
$VMClusterCount = 0    #Track the VMs per Cluster
$ClusterRAMAccum = 0   #Accumulator to hold total of % RAM.  Used to compute RAM use average across a cluster. 
$ClusterCPUAccum = 0   #Accumulator to hold total of % CPU.  Used to compute CPU use average across a cluster.
$DisabledHost = $False #Flag to track if a host is not in service.
$DisabledHostCount = 0 #Track the number of disabled hosts.  
$TotalVMCount = 0      #Accumulator to hold total VM count across the environment. 
$PossibleVMs = 0       #Accumulator to hold total possible number of VMs that can be added across the environment.

#Setup the Excel Workbook
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

$range = $Worksheet.Columns.Item(1)     #Set the width and centering of columns appropriate to the output.  
$range.ColumnWidth = 34
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
$Worksheet.cells.Item(1,1) = "XDHost-Check"
$Worksheet.cells.Item(2,1) = Get-Date
$Worksheet.cells.Item(4,1) = "Number of Clusters"
$Worksheet.cells.Item(4,2) = $XDClusters.count
$Worksheet.cells.Item(5,1) = "Calc possible VMs to "+$MaxPercent.ToString() + "% load."

$row = 7 #Set the workbook row on which to start writing data

for ($c=0; $c -lt $XDClusters.count; $c++)  #Loop through the Clusters
{
    #Init counters for the next cluster. 
    $VMClusterCount = 0    #Reset the VM counter per cluster to 0.
    $ClusterRAMAccum = 0   #Reset accumulator to hold total of % RAM to 0.  Used to compute RAM use average across a cluster. 
    $ClusterCPUAccum = 0   #Reset accumulator to hold total of % CPU to 0.  Used to compute CPU use average across a cluster.
    $DisabledHostCount = 0 #Reset the accumulator whcih tracks the number of disabled hosts.  
    $DisabledHost = $False #Reset the disabled host flag.

    $Worksheet.cells.Item($row,1) = $XDClusters[$c].name                         #Write the name of the current cluster. 
   
    $Hosts = $XDClusters[$c] | Get-VMHost | sort         #Determine the list of Hosts within the current cluster.
    $row++
    $Worksheet.cells.Item($row,1) = "Number of Hosts : " + $hosts.count     #Write the numbers of hosts in the current cluster.
    $Worksheet.cells.Item($row,4) = "Mem Total - GB"
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
            Else {
                  $Worksheet.cells.Item($row,3).Font.ColorIndex = 3     #3 is Red
                  $DisabledHost = $true
                  $DisabledHostCount++
                  }
        $Worksheet.cells.Item($row,3) = $Hosts[$h].ConnectionState.ToString()
        $Worksheet.cells.Item($row,4) = [math]::round($Hosts[$h].MemoryTotalGB,2)
        $Worksheet.cells.Item($row,5) = [math]::round($Hosts[$h].MemoryUsageGB,2)
        $MemPercent = [math]::round(($Hosts[$h].MemoryUsageGB * 100)/$Hosts[$h].MemoryTotalGB,2)
        if ($MemPercent -ge 75 -And $MemPercent -lt 90) {$Worksheet.cells.Item($row,6).Interior.ColorIndex = 45}  #45 is Orange
            Else {if ($MemPercent -ge 90) {$Worksheet.cells.Item($row,6).Interior.ColorIndex = 3}  } #3 is Red 
        $Worksheet.cells.Item($row,6) = $MemPercent
        $Worksheet.cells.Item($row,7) = $Hosts[$h].CpuTotalMhz
        $Worksheet.cells.Item($row,8) = $Hosts[$h].CpuUsageMhz
        $CpuPercent = [math]::round(($Hosts[$h].CpuUsageMhz * 100)/$Hosts[$h].CpuTotalMhz,2)
        if ($CpuPercent -ge 75 -And $CpuPercent -lt 90) {$Worksheet.cells.Item($row,9).Interior.ColorIndex = 45}  #45 is Orange
            Else {if ($CpuPercent -ge 90) {$Worksheet.cells.Item($row,9).Interior.ColorIndex = 3}  } #3 is Red 
        $Worksheet.cells.Item($row,9) = $CpuPercent
        # $Worksheet.cells.Item($row,10) = $h     #Array Index.  Uncomment to write to the Workbook 
        $row++
        $VMHostCount = $hosts[$h] | Get-View
        $VMClusterCount = $VMClusterCount + $VMHostCount.vm.count  #Add to the VM count tracking this cluster.
        $ClusterRAMAccum = $ClusterRAMAccum + $MEMPercent 
        $ClusterCPUAccum = $ClusterCPUAccum + $CPUPercent
    }
    $row++
    # Write out cluster wide VM Count, RAM used average and CPU used average.
    $Worksheet.cells.Item($row,1) = "VM Count"
    $Worksheet.cells.Item($row,2) = $VMClusterCount
    $TotalVMCount = $TotalVMCount + $VMClusterCount
    $row++       
    $ClusterRAMAvg = $ClusterRAMAccum / ($hosts.count - $DisabledHostCount)
    $Worksheet.cells.Item($row,1) = "RAM Use Avg. %"
    $Worksheet.cells.Item($row,2) = [math]::round($ClusterRAMAvg,2)
    $Worksheet.cells.Item($row,4) = "Adl VMs - RAM"
    $Worksheet.cells.Item($row,5) = [math]::round((($VMClusterCount * $MaxPercent) / $ClusterRAMAvg) - $VMClusterCount,2)
    $row++
    $ClusterCPUAvg = $ClusterCPUAccum / ($hosts.count - $DisabledHostCount)
    $Worksheet.cells.Item($row,1) = "CPU Use Avg. %"
    $Worksheet.cells.Item($row,2) = [math]::round($ClusterCPUAvg,2)
    $Worksheet.cells.Item($row,4) = "Adl VMs - CPU"
    $Worksheet.cells.Item($row,5) = [math]::round((($VMClusterCount * $MaxPercent) / $ClusterCPUAvg) - $VMClusterCount,2)

    if ($Worksheet.cells.Item($row-1,5).value2 -lt $Worksheet.cells.Item($row,5).value2 ) 
        {
        $Worksheet.cells.Item($row-1,5).Interior.ColorIndex = 4 #4 is Green
        $Worksheet.cells.Item($row-1,6) = "RAM Limited" 
        $PossibleVMs = $PossibleVMs + $Worksheet.cells.Item($row-1,5).value2
        }
    Else
        {
        $Worksheet.cells.Item($row,5).Interior.ColorIndex = 4 #4 is Green
        $Worksheet.cells.Item($row,6) = "CPU Limited" 
        $PossibleVMs = $PossibleVMs + $Worksheet.cells.Item($row,5).value2
        }
    if ($DisabledHost -eq $true)
        {
        $Worksheet.cells.Item($row-1,7).Font.ColorIndex = 3     #3 is Red
        $Worksheet.cells.Item($row-1,8).Font.ColorIndex = 3     #3 is Red
        $Worksheet.cells.Item($row-1,7)="Disabled Host(s)"
        $Worksheet.cells.Item($row-1,8)=$DisabledHostCount
        }
    $row+=2
}

$Worksheet.cells.Item($row,1) = "Total VM Count" 
$Worksheet.cells.Item(4,4) = "Total VM Count"
$Worksheet.cells.Item($row,2) = $TotalVMCount
$Worksheet.cells.Item(4,5) = $TotalVMCount
$Worksheet.cells.Item($row+1,1) = "Possible VM Builds" 
$Worksheet.cells.Item(5,4) = "Possible VM Builds" 
$Worksheet.cells.Item($row+1,2) = $PossibleVMs
$Worksheet.cells.Item(5,5) = $PossibleVMs
$Worksheet.cells.Item($row+1,3) = "at "+$MaxPercent.ToString() + "% load."
