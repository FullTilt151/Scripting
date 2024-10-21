# XDVM-RAMUpgrade.ps1
# Upgrade the RAM allocated to a set of VMs.
# Brent Griffith - Client Innovation Tech.
#
# Reads from a CSV named MachinesToUpgrade.csv stored in the same directory as this script.
#    Column 1 contains the name of the VM to upgrade. 
#    Column 2 contains the RAM value, in GB, at or less than the VM should be upgraded.
#    	IE: “2” instructs the script to upgrade the VM if its RAM is 2GB or less.
#    Column 3 contains the RAM value to which the VM will be upgraded.
#       IE: “4” instructs the script to upgrade the VM to 4GB of RAM.
#
#    Results are written to an Excel workbook opened by this script. 
#
# v 1.0  - 12/02/15 - Initial script. 
#
# v 1.5  - 04/14/17 
#          - Added CMD to load VMWare Snapin 
#          - Replaced Write-Host with Write-Output where applicable.
#          - Updated logging to Excel - Set errors and no action results to red, cleanup formatting. 
#          - Error checking added to Set-VM (RAM Addition)
#          - Autosave logfile (Excel Workbook)
#          - Updated the loop waiting for the VM to shutdown so that if the VM completes shutdown before the timer exires the loop exits. 
#
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted

$ScriptVersion = 1.5    #Set the verion of the script.

if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)   {Add-PSSnapin VMware.VimAutomation.Core}

Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 


#CSV file which lists the VMs to be upgraded.
#Format for CSV found at the head of this script.
$Machine_List = 'MachinesToUpgrade.csv'
$Machines = Import-Csv $Machine_List -Header @("VM","UpgradeTo")

$SleepTime = 90    # Maximum time to wait for the VM to shutdown should the script have to shut it down.
$VMCount = 0       #Init the VM Counter.
$Error.Clear()     #Clear the Error array.

#Setup the Excel Workbook for results.
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

#Set the name for the Workbook name and save it.
$DateTime = Get-Date -Format yyyy-MM-dd--hh-mm-sstt
$workbook.SaveAs("RAM-Upgrade" + $DateTime)

#Set the width of the columns appropriate to the output and write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "Action Taken"
$range = $Worksheet.Columns.Item(1)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(2)
$range.ColumnWidth = 50
$range.HorizontalAlignment = 3

Write-Output "XDVM-RAMUpgrade Version: $ScriptVersion."

foreach ($row in $Machines)   #Loop for each VM
    {
    $VMname = $row.VM
    $RAMUpgradeVal = $row.UpgradeTo
    Write-Output "$VMname - Information being retrieved."
    $VM = (get-view -ViewType VirtualMachine -filter @{"Name" = $row.vm})  #Get object for the VM in process.
    $powerOff = $False         #Init variable used to track if the script powered off the VM.
    $VMCount++                 #Keep a count of the VM in porcess.  Used to locate ouput row in Workbook.
    $Worksheet.cells.Item($VMCount + 1,1) = $VMname     #Write the VM's name to the Workbook.
    if (($VM.summary.config.MemorySizeMB / 1024) -lt $row.UpgradeTo)   #Validate the VM is eligible for upgrade. Current RAM is less than upgrade RAM value from input file.  
        {
        Write-Output "$VMname is eligible for RAM upgrade."
        if ($VM.Runtime.PowerState -eq "poweredOn")   #Test if VM is powered on.  If so, fall in loop to power it off. 
            {
            Write-Output "$VMname is Powered On."           
            $vmWIMIinfo = Get-WmiObject -class Win32_ComputerSystem -ComputerName ($VMname + ".humad.com")  #Get some info on the VM via WIMI.
            if ($vmWIMIinfo.UserName -eq $null)    #Use the WIMI info to assure there is no logged on user.
                {
                Shutdown-VMGuest -VM $VMname -Confirm:$False | Out-Null   #Shutdown the VM.
                Write-Output "$VMName has been asked to Shutdown"
                $powerOff = $true   #Track that the script shutdown the VM.
                for ($a = $SleepTime; $a -gt 0; $a--)   #Present a progress bar waiting for the shutdown to complete.
                    {
                    Write-Progress -Activity "Shutting down VM...." -Status $VMName -SecondsRemaining $a
                    Start-Sleep 1
                    if ($a % 3 -eq 0)
                        {
                        $VMCurrentPowerState = (get-view -ViewType VirtualMachine -filter @{"Name" = $row.vm}).Runtime.PowerState
                        if ($VMCurrentPowerState -eq "poweredOff") {$a = 0}
                        $a--
                        }
                    }
                Write-Progress -Activity "Shutting down VM...." -Status "Ready" -Completed
                }
            else   #Execute the following if the VM has a user logged on. 
                {
                Write-Host $VMName "has a logged on user:" $vmWIMIinfo.UserName
                $Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 3  #3 is Red
                $Worksheet.cells.Item($VMCount + 1,2) = "None: User Logged on: " + $vmWIMIinfo.UserName  #Store logged on user in workbook.
                }
            }
        if (($VM.Runtime.PowerState -eq "poweredOff") -or ($powerOff))  #Test that the VM is powered off or the script powered it off. 
            {
            Write-Output "$VMName is in process a RAM upgrade to $RAMUpgradeVal GB."
            Start-Sleep 2 # Add a couple seconds sleep time to assure VMware catches up and can report the VM as powered off. 
            Set-VM -VM $VMname -Confirm:$False -MemoryGB $row.UpgradeTo | Out-Null   #Upgrade the RAM setting. 

            if ($error.count -gt 0)   #Test if the above commandlet errored in any way.  Report the results. 
                {
                Write-Output "$VMname - Error expanding RAM."
                $Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 3  #3 is Red
                $Worksheet.cells.Item($VMCount + 1,2) = "Error expanding RAM."
                $Error.Clear()     #Clear the Error array.
                }
            else
                {
                Start-VM -VM $VM.Name | Out-Null       #Start the VM.
                Write-Output "$VMName RAM has been upgraded to $RAMUpgradeVal GB."
                $Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 4  #4 is Green
                $Worksheet.cells.Item($VMCount + 1,2) = "RAM upgraded to " + $row.UpgradeTo +" GB" #Store upgrade status to workbook.
                }          
            }  
        }   
    else
        {
        Write-Host $VM.Name "has at least" $row.UpgradeTo "GB RAM already.  No upgrade performed"
        $Worksheet.cells.Item($VMCount + 1,2).Font.ColorIndex = 3  #3 is Red
        $Worksheet.cells.Item($VMCount + 1,2) = "None: Desired upgrade: " + $row.UpgradeTo +" GB.   Current RAM: " + ($VM.summary.config.MemorySizeMB / 1024) + " GB."
        } 
    $workbook.save()
    }