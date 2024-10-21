# XDVM-NetworkMove.ps1
# Move VMs to a new network.
# Brent Griffith and Craig Wood - Client Innovation Solutions.
#
# Reads from a CSV named MachinesToMove.csv stored in the same directory as this script.
#    Column 1 contains the name of the VM to upgrade. 
#    Column 2 contains the Network the VM will be moved to.  Please choose from the networks below depending on whether the VM is in LDC or SDC and add to column 2 in MachinesToMove.csv
<#
LDC_Xen_Net1-10.224.0.0  
LDC_Xen_Net2-10.224.2.0  
LDC_Xen_Net3-10.224.4.0  
LDC_Xen_Net4-10.224.6.0  
LDC_Xen_Net5-10.224.8.0  
LDC_Xen_Net6-10.224.10.0 
LDC_Xen_Net7-10.224.12.0 
LDC_Xen_Net8-10.224.14.0 
LDC_Xen_Net9-10.224.16.0 
LDC_Xen_Net10-10.224.18.0
LDC_Xen_Net11-10.224.20.0
LDC_Xen_Net12-10.224.22.0
LDC_Xen_Net13-10.224.24.0
LDC_Xen_Net14-10.224.26.0
LDC_Xen_Net15-10.224.28.0
LDC_Xen_Net16-10.224.30.0
LDC_Xen_Net17-10.224.32.0
LDC_Xen_Net18-10.224.34.0

SDC_Xen_Net1-10.232.0.0  
SDC_Xen_Net2-10.232.2.0  
SDC_Xen_Net3-10.232.4.0  
SDC_Xen_Net4-10.232.6.0  
SDC_Xen_Net5-10.232.8.0  
SDC_Xen_Net6-10.232.10.0 
SDC_Xen_Net7-10.232.12.0 
SDC_Xen_Net8-10.232.14.0 
SDC_Xen_Net9-10.232.16.0 
SDC_Xen_Net10-10.232.18.0
SDC_Xen_Net11-10.232.20.0
SDC_Xen_Net12-10.232.22.0
SDC_Xen_Net13-10.232.24.0
SDC_Xen_Net14-10.232.26.0
SDC_Xen_Net15-10.232.28.0
SDC_Xen_Net16-10.232.30.0
SDC_Xen_Net17-10.232.32.0
SDC_Xen_Net18-10.232.34.0
#>
#
#    Results are written to an Excel workbook opened by this script. 
#
# v 1.0  - 07/14/2016 - Initial script. 
# V 1.1  - 08/02/2016 - Resulting Excel log file saves with "NetMove" + Date and Time in the file name. 
#
#
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted

if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
	Add-PSSnapin VMware.VimAutomation.Core
}

Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 


#CSV file which lists the VMs to be moved.
#Format for CSV found at the head of this script.
$Machine_List = 'MachinesToMove.csv'
$Machines = Import-Csv $Machine_List -Header @("VM","NewNetwork")

$VMCount = 0       #Init the VM Counter.
$Error.Clear()     #Clear the Error array.

#Setup the Excel Workbook for results.
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

#Set the width of the columns appropriate to the output.  
#$excel.Range("A1").ColumnWidth = 30  
#$excel.Range("B1").ColumnWidth = 1100
$range = $Worksheet.Columns.Item(1)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(2)
$range.ColumnWidth = 120
$range.HorizontalAlignment = 3

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "New Network or Error"

$DateTime = Get-Date -Format yyyy-MM-dd--hh-mm-sstt
$workbook.SaveAs("NetMove" + $DateTime)  

foreach ($row in $Machines)   #Loop for each VM
    {
    Write-Host $row.VM "- Information being retrieved."
    $VMCount++                 #Keep a count of the VM in process.  Used to locate ouput row in Workbook.
    $Worksheet.cells.Item($VMCount + 1,1) = $row.VM     #Write the VM's name to the Workbook.
    
    $vmWIMIinfo = Get-WmiObject -class Win32_ComputerSystem -ComputerName $row.VM  #Get some info on the VM via WIMI.
        if ($error.count -eq 0)   #Test if the above WMI query errored in any way.
            {
            if ($vmWIMIinfo.UserName -eq $null)    #Use the WIMI info to assure there is no logged on user.
                {
                $nics = Get-NetworkAdapter -vm $row.VM   #Get VM's NIC Info
                Set-NetworkAdapter -NetworkAdapter $nics[0] -NetworkName $row.NewNetwork -Confirm:$false
                    if ($error.count -eq 0)   #Test if the above Set-NetworkAdapter errored in any way.
                        {
                        #No error reported
                        Restart-VMGuest -VM $row.VM
                        Write-Host $row.VM "is being Rebooted"
                        $Worksheet.cells.Item($VMCount + 1,2) = "New Net: " + $row.NewNetwork  #Store logged on user in workbook.
                        }
                    else
                        {
                        #Error reported
                        Write-Host $row.VM "Set Adapter Error: " $Error[0].tostring()
                        $Worksheet.cells.Item($VMCount + 1,2) = "Set Adapter Error: " + $Error[0].tostring()  #Store Set error in workbook.
                        $Error.Clear()
                        }
                }
            else   #Execute the following if the VM has a user logged on. 
                {
                Write-Host $row.VM "has a logged on user:" $vmWIMIinfo.UserName
                $Worksheet.cells.Item($VMCount + 1,2) = "User Logged on: " + $vmWIMIinfo.UserName  #Store logged on user in workbook.
                }  
            } 
        else
            {
            Write-Host $row.VM "had a WMI Error: " $Error[0].tostring()
            $Worksheet.cells.Item($VMCount + 1,2) = "WMI Error: " + $Error[0].tostring()  #Store WMI error in workbook.
            $Error.Clear()
            }
        $workbook.Save()
    }
#$DateTime = Get-Date -Format yyyy-MM-dd--hh-mm-hh-sstt
#$workbook.SaveAs("NetMove" + $DateTime)  