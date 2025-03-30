# XDVM-71MaintMode.ps1
# Place VMs in Maintenance Mode in 7.1 Environment.
# Craig Wood - Client Innovation Solutions
#
# Reads from a CSV named MaintMode.csv stored in the same directory as this script.
#    Column 1 contains the name of the VM to Remove. 
#
#    Results are written to an Excel workbook opened by this script. 
#
# v 1.0  - 12/29/16 - Initial script. 
#
#
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted

 
if ((Get-PSSnapin | where { $_.Name -like "Citrix*"}) -eq $null)
    {
	    Add-PSSnapin Citrix*
    }

$controller="LOUXDCWPGX1S003.ts.humad.com"   # 7.6 Controller managing the VMs to be checked.
$Machine_List = 'MachinestoCheck.csv'
$Machines = Import-Csv $Machine_List -Header @("VM")
$VMCount = 0       #Init the VM Counter.
$Error.Clear()     #Clear the Error array.

#Setup the Excel Workbook for results.
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

#Set the width of the columns appropriate to the output.  
$excel.Range("A1").ColumnWidth = 32  
$excel.Range("B1").ColumnWidth = 32

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "Action Taken"


foreach ($row in $Machines)   #Loop for each VM
    {
    Write-Host $row.VM "- Information being retrieved."
    #$VM = Get-VM $row.VM       #Get object for the VM in process.
    $XDVM = Get-BrokerPrivateDesktop -AdminAddress $controller -HostedMachineName $row.VM
    $VMCount++                 #Keep a count of the VM in process.  Used to locate ouput row in Workbook.
    $Worksheet.cells.Item($VMCount + 1,1) = $row.VM     #Write the VM's name to the Workbook. 
    Write-Host $VM.Name "is being placed in Maintenance Mode "
    $XDVM | Set-BrokerPrivateDesktop -AdminAddress $controller -InMaintenanceMode $true #Place VM in Maintenance Mode
        if ($error.count -gt 0)   #Test if placing VM in Maint Mode was successful or not. Report the results. 
            {
            Write-Host $row.VM "Maintenance Mode Failed"
            $Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 3  #3 is Red
            $Worksheet.cells.Item($VMCount + 1,2) = "Failed"
            $Error.Clear()     #Clear the Error array.
            }
        else
            {
            $Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 4  #4 is Green
            $Worksheet.cells.Item($VMCount + 1,2) = "Maintenance Mode ON"
            } 
    }  