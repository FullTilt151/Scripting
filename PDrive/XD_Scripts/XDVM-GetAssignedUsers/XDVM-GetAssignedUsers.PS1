# XDVM-GetAssignedUsers.ps1
#
# Finds the Users, by ID and Name, assigned to a list of XenDesktop VMs. 
#
# Brent Griffith Client Innovation Tech.
#
# Reads from a CSV named Machinelist.csv stored in the same directory as this script.
#    Column 1 contains the names of the VMs for which assigned users are to be found. 
#
# v 1.0  - 04/22/16 - Initial script.
#

$ver = 1.0  #Script Version to be written to the display.

if ((Get-PSSnapin | where { $_.Name -like "Citrix*"}) -eq $null)
{
	Add-PSSnapin Citrix*
}

#Set the XenDesktop Broker.
$XDBroker = "LOUXDCWPGX1S003.TS.HUMAD.COM"

#Set the AD Domain of the VM's.
$VMAD_Domain = "HUMAD\"

#CSV file which lists the VMs to be upgraded.
#Format for CSV found at the head of this script.
$Machine_List = 'MachineList.csv'
$Machines = Import-Csv $Machine_List -Header @("VM")

#Init the Row Counter.
$RowCount = 0       

#Setup the Excel Workbook for results.
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

#Set the width and alignment of the columns appropriate to the output.  
$range = $Worksheet.Columns.Item(1)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(2)
$range.ColumnWidth = 48
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(3)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "User ID(s)"
$Worksheet.cells.Item(1,3) = "User Name(s)"


Write-Host "XDVM Get Associated Users PowerShell Script Version" $ver

foreach ($row in $Machines)   #Loop for each VM
    {
    $RowCount++
    Write-Host $row.VM "- Information being retrieved."
    $Worksheet.cells.Item($RowCount + 1,1) = $row.VM
    $VMFullName = $VMAD_Domain+$row.VM
    $GBM = Get-BrokerMachine -adminaddress $XDBroker -MachineName $VMFullName
    if ($GBM -eq $null) 
        {write-host $row.VM "- Does not exist" `n
        $Worksheet.cells.Item($RowCount + 1,2) = "VM does not exist"
        $Worksheet.cells.Item($RowCount + 1,3) = "VM does not exist"
        }

    $NameCount = 0
    foreach ($ID in $GBM.AssociatedUserNames)
        {
        #Write the found user ID(s)
        write-host "     "$GBM.AssociatedUserNames[$NameCount]
        $Worksheet.cells.Item($RowCount + 1,2) = $GBM.AssociatedUserNames[$NameCount]
        #Write the Found User Name(s)
        Write-host "     "$GBM.AssociatedUserFullNames[$NameCount] `n
        $Worksheet.cells.Item($RowCount + 1,3) = $GBM.AssociatedUserFullNames[$NameCount]
        $NameCount++
        if ($GBM.AssociatedUserNames.Length -gt 1 -and $NameCount -lt $GBM.AssociatedUserNames.Length) {$RowCount++}
        }
    }

