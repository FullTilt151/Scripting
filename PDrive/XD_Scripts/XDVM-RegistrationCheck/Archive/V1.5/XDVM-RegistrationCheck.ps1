# XDVM-RegistrationCheck.ps1
# Check VMs to verify their Registration to XenDesktop
#
# Brent Griffith - Client Innovation Solutions.
#
# Reads a list of VMs to check from a CSV named MachinesToCheck.csv stored in the same directory as this script.
#    Column 1 contains the name of the VM to check. 
#    
#    Results are written to an Excel workbook opened by this script. 
#
# v 1.0  - 07/15/2016 - Initial script. 
# v 1.5  - 08/01/2016 - Added logic, and expanded logging, to reset VDA registration ports on unregistered VMs.  User selectable option. 
#
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted


#Add Citrix Snap In and connect to the controller. 
#Necessary for connection to XenDesktop to test registration status. 
if ((Get-PSSnapin | where { $_.Name -like "Citrix*"}) -eq $null)
    {
	    Add-PSSnapin Citrix*
    }

$controller="louxddwps01.ts.humad.com"   #Controller managing the VMs to be checked.


#CSV file which lists the VMs to be moved.
#Format for CSV found at the head of this script.
$Machine_List = 'MachinesToCheck.csv'
$Machines = Import-Csv $Machine_List -Header @("VM")

$VMCount = 0       #Init the VM Counter.
$Error.Clear()     #Clear the Error array.
$VMaddr=$null      #Clear the VM IP Address variable. 
$RegPath= $null    #Clear the Registry Path variable. 
$RestartVM = $false        #Init the VM restart control variables to false.
$ResetRegPort = $false     #Init the VM port reset control variables to false.

#User input to determine of unregistered VMs will be rebooted or will have their registratino ports reset. 

#Determine if unregistered VMs are to be rebooted/started.
$RestartAns = Read-Host -Prompt 'Would you like to reboot/start unregistered VMs?  (Y/N - No Default)  '
if ($RestartAns -eq 'y' -or $RestartAns -eq 'Y')  {$RestartVM = $true}

#Determine if unregistered VMs are to have their Registration Port Reset.
#Yes will force a reboot. 

Write-Host "Would you like to reset the VDA Registration port of unregistered VMs?  (Y/N - No Default)"
$ResetRegPortAns = Read-Host -Prompt 'Answering (Y)es will force a reboot of unregistered VMs.  '
if ($ResetRegPortAns -eq 'y' -or $ResetRegPortAns -eq 'Y')  
    {
    $ResetRegPort = $true
    $RestartVM = $true
    }

#If unregistered VMs are to be rebooted load the VMWare snap-in so the script can reboot them.
if ($RestartVM -eq $true) 
    {
    if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)   {Add-PSSnapin VMware.VimAutomation.Core}
    Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter.
    }



#Setup the Excel Workbook for results.
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

#Set the width of the columns appropriate to the output.  
$range = $Worksheet.Columns.Item(1)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(2)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "Registration Status"

#Setup a status column for the registration port operation.
if ($ResetRegPort -eq $true) 
    {
    $range = $Worksheet.Columns.Item(3)
    $range.ColumnWidth = 32
    $range.HorizontalAlignment = 3
    $Worksheet.cells.Item(1,3) = "Port Reset Status"
    }

#Setup a status column for the VM restart operation.
if ($RestartVM -eq $true) 
    {
    $range = $Worksheet.Columns.Item(4)
    $range.ColumnWidth = 32
    $range.HorizontalAlignment = 3
    $Worksheet.cells.Item(1,4) = "Reboot Status"
    if ($ResetRegPort -eq $false)   #Narrow the column used to report port reset status if the script is not going to reset ports.
        {
        $range = $Worksheet.Columns.Item(3)
        $range.ColumnWidth = 2
        }
    }

#Set the name for the Workbook name and save it.
$DateTime = Get-Date -Format yyyy-MM-dd--hh-mm-sstt
$workbook.SaveAs("RegCheck" + $DateTime)

foreach ($row in $Machines)   #Loop for each VM
    {
    Write-Host $row.VM "- Information being retrieved."
    $VMCount++                 #Keep a count of the VM in process.  Used to locate ouput row in Workbook.
    $Worksheet.cells.Item($VMCount + 1,1) = $row.VM     #Write the VM's name to the Workbook.

    $BM = Get-BrokerMachine -AdminAddress $controller -HostedMachineName $row.VM
    Write-host $row.VM "is"$BM.RegistrationState `n
    $Worksheet.cells.Item($VMCount + 1,2) = $BM.RegistrationState.ToString()

    if ($BM.RegistrationState.ToString() -eq "Registered") 
        {$Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 4}  #4 is Green
    Else 
        {$Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 3  #3 is Red
        if ($ResetRegPort -eq $true)
            {
            Write-Host $row.VM ": Registration port is being reset."
            $VMaddr=$null      #Clear the VM IP Address variable. 
            $RegPath= $null    #Clear the Registry Path variable. 
           # $VMaddr=(Get-vm $row.VM).guest.IPAddress
 #           $RegPath= "\\"+$VMaddr+"\HKLM\SOFTWARE\Citrix\VirtualDesktopAgent"
 #           &REG "Add" $RegPath "/v" "ControllerRegistrarPort" "/t" "REG_DWORD" "/d" "50004" "/f"
            if ($error.count -gt 0)   #Test if the above Registratio Port reset errored in any way.  Report the results. 
                {
                Write-Host $row.VM "Registration Port reset failed"
                $Worksheet.cells.Item($VMCount + 1,3).Font.ColorIndex = 3  #3 is Red
                $Worksheet.cells.Item($VMCount + 1,3) = "Registration Port reset failed."
                $Error.Clear()     #Clear the Error array.
                }
            else
                {
                $Worksheet.cells.Item($VMCount + 1,3).Font.ColorIndex = 4  #4 is Green
                $Worksheet.cells.Item($VMCount + 1,3) = "Registration Port reset"
                }
            }
        if ($RestartVM -eq $true)
            {
            Write-Host $row.VM "is being Rebooted"
            Restart-VMGuest -VM $row.VM
            if ($error.count -gt 0)   #Test if the above Restart errored in any way.  Report the results.
                {
                Write-Host $row.VM "Reboot Failed.  Attempting a cold boot."  #Attempt a cold boot if restart failed. 
                start-vm -VM $row.VM
                $Worksheet.cells.Item($VMCount + 1,4).Font.ColorIndex = 3  #3 is Red
                $Worksheet.cells.Item($VMCount + 1,4) = "Reboot Failed, cold boot initiated."
                $Error.Clear()     #Clear the Error array.
                if ($error.count -gt 0)
                    {
                    $Worksheet.cells.Item($VMCount + 1,4) = "Reboot and cold boot failed."
                    $Error.Clear()     #Clear the Error array.
                    }
                }
            else
                {
                $Worksheet.cells.Item($VMCount + 1,4).Font.ColorIndex = 4  #4 is Green
                $Worksheet.cells.Item($VMCount + 1,4) = "VM rebooted."

                }
            }
        }
    $workbook.save()     
    }

#$DateTime = Get-Date -Format yyyy-MM-dd--hh-mm-hh-sstt
#$workbook.SaveAs("RegCheck" + $DateTime)  
