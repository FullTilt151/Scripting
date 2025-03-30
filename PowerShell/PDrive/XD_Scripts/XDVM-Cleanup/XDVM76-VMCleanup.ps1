# XDVM-VMCleanup.ps1
# Remove VMs from vSphere and Citrix Studio
# Craig Wood - Client Innovation Solutions
#
# Reads from a CSV named MachinesToRemove.csv stored in the same directory as this script.
#    Column 1 contains the name of the VM to Remove. 
#
#    Results are written to an Excel workbook opened by this script. 
#
# v 1.0  - 05/02/17 - Inception 
# v 1.1  - 08/07/17 - Added Menu for Delivery Group selection, sped up processing time and cleaned output.
#
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#### Set Delivery Group Name where VMs reside below. ####

 
if ((Get-PSSnapin | where { $_.Name -like "Citrix*"}) -eq $null)
    {
	    Add-PSSnapin Citrix*
    }

if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
	Add-PSSnapin VMware.VimAutomation.Core
}
Import-module ActiveDirectory

Connect-VIServer louvcswps05.rsc.humad.com | Out-Null     #Create the connection to the VCenter.

#Set the Delivery Group.

[int]$MenuChoice = 0
while ( $MenuChoice -lt 1 -or $MenuChoice -gt 10 ){
  Write-Output ""
  Write-Output "Please choose the VM Type that will be removed (1-10)" 
  Write-Output ""
  Write-Output "1. DEVA"
  Write-Output "2. DEVB"
  Write-Output "3. DEVC"
  Write-Output "4. HEDA"
  Write-Output "5. STDB"
  Write-Output "6. STDC"
  Write-Output "7. TSSA"
  Write-Output "8. VIPA"
  Write-Output "9. SICA"
  Write-Output "10. TSTA"
  Write-Output "To Quit hit Ctrl-C"
[Int]$MenuChoice = read-host
}

    if ($MenuChoice -eq 1)  
        {
        $DG = 'W7_DEV_A'
        }
    if ($MenuChoice -eq 2)
        {
        $DG = 'W7_DEV_B'
        }
    if ($MenuChoice -eq 3)
        {
        $DG = 'W7_DEV_C'
        }
    if ($MenuChoice -eq 4)  
        {
        $DG = 'W7_HED_A'
        }
    if ($MenuChoice -eq 5)
        {
        $DG = 'W7_STD_B'
        }
    if ($MenuChoice -eq 6)
        {
        $DG = 'W7_STD_C'
        }
    if ($MenuChoice -eq 7)
        {
        $DG = 'W7_TSS_A'
        }
    if ($MenuChoice -eq 8)
        {
        $DG = 'W7_VIP_A'
        }
    if ($MenuChoice -eq 9)
        {
        $DG = 'W10_SIC_A'
        }
    if ($MenuChoice -eq 10)
        {
        $DG = 'W10_TST_A'
        }
    if ($MenuChoice -eq 11)
        {
        return
        }

$controller="louxdcwpgx1s003.ts.humad.com"   #Controller managing the VMs to be checked.
$Machine_List = 'MachinesToRemove.csv'
$Machines = Import-Csv $Machine_List -Header @("VM")
$SleepTime = 40    #Time to wait for the VM to shutdown should the script have to shut it down. 
$VMCount = 0       #Init the VM Counter.

#Setup the Excel Workbook for results.
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

#Set the width of the columns appropriate to the output.  
$excel.Range("A1").ColumnWidth = 32  
$excel.Range("B1").ColumnWidth = 32
$excel.Range("C1").ColumnWidth = 32
$excel.Range("D1").ColumnWidth = 32

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "Citrix Removal"
$Worksheet.cells.Item(1,3) = "vSphere Removal"
$Worksheet.cells.Item(1,4) = "AD Removal"


foreach ($row in $Machines)   #Loop for each VM
    {
    Write-Output $row.VM "-=Information being retrieved=-"
    $VM = Get-VM $row.VM       #Get object for the VM in process.
    $XDVM = Get-BrokerPrivateDesktop -AdminAddress $controller -HostedMachineName $row.VM
    $powerOff = $False         #INit variable used to track if the script powered off the VM.
    $VMCount++                 #Keep a count of the VM in porcess.  Used to locate ouput row in Workbook.
    $Worksheet.cells.Item($VMCount + 1,1) = $row.VM     #Write the VM's name to the Workbook. 
    Set-BrokerPrivateDesktop -AdminAddress $controller -InputObject $XDVM -InMaintenanceMode $true #Place VM in Maintenance Mode
    Write-Output $VM.Name "Placed in Maintenance Mode"
        if ($VM.PowerState -eq "PoweredOn")   #Test if VM is powered on.  If so, fall in loop to power it off. 
            {
            Write-Output $VM.Name " is Powered On."
            Stop-VM $VM -Kill -Confirm:$False | Out-Null   #Shutdown the VM.
            Write-Output $VM.Name " is being Shutdown"
            $powerOff = $true   #Track that the script shutdown the VM.
            Start-Sleep .5
                }
            
        if (($VM.PowerState -eq "PoweredOff") -or ($powerOff))  #Test that the VM is powered off or the script powered it off. 
            {
            $XDVM | Remove-BrokerMachine -DesktopGroup $DG -Force  #Remove VM from Delivery Group
            $XDVM | Remove-BrokerMachine -Force  #Remove VM from Catalog 
                if ($error.count -gt 0)   #Test if the above commands ran successfully 
                    {
                    Write-Output $row.VM " Removal from Delivery Group/Machine Catalog Failed"
                    $Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 3  #3 is Red
                    $Worksheet.cells.Item($VMCount + 1,2) = "Failed"
                    $Error.Clear()     #Clear the Error array.
                    }
                else
                    {
                    $Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 10  #4 is Green
                    $Worksheet.cells.Item($VMCount + 1,2) = "Successful"
                    }               
            Remove-VM -VM $VM -DeleteFromDisk -Confirm:$false -RunAsync | Out-Null    #Delete VM from vCenter
                 if ($error.count -gt 0)   #Test if the above command ran successfully
                    {
                    Write-Output $row.VM " Removal from vCenter Failed"
                    $Worksheet.cells.Item($VMCount + 1,3).Font.ColorIndex = 3  #3 is Red
                    $Worksheet.cells.Item($VMCount + 1,3) = "Failed"
                    $Error.Clear()     #Clear the Error array.
                    }
                else
                    {
                    $Worksheet.cells.Item($VMCount + 1,3).Font.ColorIndex = 10  #4 is Green
                    $Worksheet.cells.Item($VMCount + 1,3) = "Successful"
                    }  
            Remove-ADComputer -Identity $row.vm -confirm:$false    #Delete Computer Object from AD
                 if ($error.count -gt 0)   #Test if the above command ran successfully
                    {
                    Write-Output $row.VM " Removal from AD Failed"
                    $Worksheet.cells.Item($VMCount + 1,4).Font.ColorIndex = 3  #3 is Red
                    $Worksheet.cells.Item($VMCount + 1,4) = "Failed"
                    $Error.Clear()     #Clear the Error array.
                    }
                else
                    {
                    $Worksheet.cells.Item($VMCount + 1,4).Font.ColorIndex = 10  #4 is Green
                    $Worksheet.cells.Item($VMCount + 1,4) = "Successful"
                    }  
            
            }     
  }  