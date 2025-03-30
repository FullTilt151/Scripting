# XDVM-GetAssignedVMs.ps1
#
# Finds the VMs assigned to a user listed in CSV. 
#
# Brent Griffith and Craig Wood Client Innovation Tech.
#
# Reads from a CSV named Machinelist.csv stored in the same directory as this script.
#    Column 1 contains the User ID for which you want to find assigned VMs. 
#
# v 1.0  - 04/22/17 - Initial script.
#

$ver = 1.0  #Script Version to be written to the display.

if ((Get-PSSnapin | where { $_.Name -like "Citrix*"}) -eq $null)
{
	Add-PSSnapin Citrix*
}

#Set the XenDesktop Broker.

[int]$MenuChoice = 0
while ( $MenuChoice -lt 1 -or $MenuChoice -gt 3 ){
  Write-host "1. 7.6 Prod"
  Write-host "2. 7.6 QA"
  Write-host "3. Quit and exit"
  [Int]$MenuChoice = read-host "Please enter an option 1 to 3..." 
}

  if ($MenuChoice -eq 1)  
        {
        $XDBroker = 'LOUXDCWPGX1S001.TS.HUMAD.COM'
        }
    if ($MenuChoice -eq 2)
        {
        $XDBroker = 'LOUXDCWAGX1S001.TS.HUMAD.COM'
        }
    if ($MenuChoice -eq 3)
        {
        return
        }

#Set the AD Domain of the VM's.
$VMAD_Domain = "HUMAD\"

#CSV file which lists the VMs to be upgraded.
#Format for CSV found at the head of this script.
$Machine_List = 'UserList.csv'
$Machines = Import-Csv $Machine_List -Header @("UID")

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
$Worksheet.cells.Item(1,1) = "User ID"
$Worksheet.cells.Item(1,2) = "VM Name"
$Worksheet.cells.Item(1,3) = "User Name"


Write-Host "XDVM Get Associated Users PowerShell Script Version" $ver

foreach ($row in $Machines)   #Loop for each VM
    {
    $RowCount++
    Write-Host $row.UID "- Information being retrieved."
    $Worksheet.cells.Item($RowCount + 1,1) = $row.UID
    #$VMFullName = $VMAD_Domain+$row.UID
    $User = $VMAD_Domain + $row.UID
    $GBM = Get-BrokerMachine -adminaddress $XDBroker -AssociatedUserName $User
    #$GBM = Get-BrokerMachine -AdminAddress LOUXDCWPGX1S003.TS.HUMAD.COM -AssociatedUserName $User
    if ($GBM -eq $null) 
        {write-host $row.ID "- Does not exist" `n
        $Worksheet.cells.Item($RowCount + 1,2) = "VM does not exist"
        $Worksheet.cells.Item($RowCount + 1,3) = "VM does not exist"
        }
        else
        {
        $NameCount = 0
     foreach ($ID in $GBM.AssociatedUserNames)
        {
        #Write the found User Name(s)
        write-host "     "$GBM.MachineName
        $Worksheet.cells.Item($RowCount + 1,2) = $GBM.MachineName
        #Write the Found User Name(s)
        Write-host "     "$GBM.AssociatedUserFullNames `n
        $Worksheet.cells.Item($RowCount + 1,3) = $GBM.AssociatedUserFullNames
        $NameCount++
        if ($GBM.AssociatedUserNames.Length -gt 1 -and $NameCount -lt $GBM.AssociatedUserNames.Length){$RowCount++}
        }
        }
}
 <#   $NameCount = 0
    foreach ($ID in $GBM.AssociatedUserNames)
        {
        #Write the found User Name(s)
        write-host "     "$GBM.MachineName[$NameCount]
        $Worksheet.cells.Item($RowCount + 1,2) = $GBM.MachineName[$NameCount]
        #Write the Found User Name(s)
        Write-host "     "$GBM.AssociatedUserFullNames[$NameCount] `n
        $Worksheet.cells.Item($RowCount + 1,3) = $GBM.AssociatedUserFullNames[$NameCount]
        $NameCount++
        if ($GBM.AssociatedUserNames.Length -gt 1 -and $NameCount -lt $GBM.AssociatedUserNames.Length) {$RowCount++}
        }
    }
#>
