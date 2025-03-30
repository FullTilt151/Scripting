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
#
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted
Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 


#CSV file which lists the VMs to be upgraded.
#Format for CSV found at the head of this script.
$Machine_List = 'MachinesToUpgrade.csv'
$Machines = Import-Csv $Machine_List -Header @("VM","UpgradeFrom","UpgradeTo")

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

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "Action Taken"


foreach ($row in $Machines)   #Loop for each VM
    {
    Write-Host $row.VM "- Information being retrieved."
    $VM = Get-VM $row.VM       #Get object for the VM in process.
    $powerOff = $False         #INit variable used to track if the script powered off the VM.
    $VMCount++                 #Keep a count of the VM in porcess.  Used to locate ouput row in Workbook.
    $Worksheet.cells.Item($VMCount + 1,1) = $VM.Name     #Write the VM's name to the Workbook.
    if ($VM.MemoryGB -le $row.UpgradeFrom)               #Validate the VM is eligible for upgrade.  
        {
        if ($VM.PowerState -eq "PoweredOn")   #Test if VM is powered on.  If so, fall in loop to power it off. 
            {
            Write-Host $VM.Name "is Powered On."
            $vmWIMIinfo = Get-WmiObject -class Win32_ComputerSystem -ComputerName $VM.Guest.HostName  #Get some info on the VM via WIMI.
            if ($vmWIMIinfo.UserName -eq $null)    #Use the WIMI info to assure there is no logged on user.
                {
                Shutdown-VMGuest $VM -Confirm:$False | Out-Null   #Shutdown the VM.
                Write-Host $VM.Name "has been asked to Shutdown"
                $powerOff = $true   #Track that the script shutdown the VM.
                for ($a = $SleepTime; $a -gt 0; $a--)   #Present a progress bar waiting for the shutdown to complete.
                    {
                    Write-Progress -Activity "Shutting down VM...." -Status $VM.Name -SecondsRemaining $a
                    Start-Sleep 1
                    }
                Write-Progress -Activity "Shutting down VM...." -Status "Ready" -Completed
                }
            else   #Execute the following if the VM has a user logged on. 
                {
                Write-Host $VM.Name "has a logged on user:" $vmWIMIinfo.UserName
                $Worksheet.cells.Item($VMCount + 1,2) = "None. User Logged on: " + $vmWIMIinfo.UserName  #Store logged on user in workbook.
                }
            }
        if (($VM.PowerState -eq "PoweredOff") -or ($powerOff))  #Test that the VM is powered off or the script powered it off. 
            {
            Write-Host $VM.Name "is in process a RAM upgrad to" $row.UpgradeTo "GB."
            Set-VM $VM -Confirm:$False -MemoryGB $row.UpgradeTo | Out-Null   #Upgrade the RAM setting. 
            Start-VM -VM $VM.Name | Out-Null       #Start the VM.
            Write-Host $VM.Name "RAM has been upgraded to" $row.UpgradeTo "GB."
            $Worksheet.cells.Item($VMCount + 1,2) = "RAM upgraded to " + $row.UpgradeTo +" GB" #Store upgrade status to workbook.
            
            }  
        }    
    }