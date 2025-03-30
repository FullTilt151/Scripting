# XDVM-StorageUpgrade.ps1
# Upgrade the Storage allocated to a set of VMs.
# Brent Griffith and Craig Wood - Client Innovation Tech.
#
# Reads from a CSV named MachinesToUpgrade.csv stored in the same directory as this script.
#    Column 1 contains the name of the VM to upgrade. 
#    Column 2 contains the Storage value in GB to be added to the VM.

#
#    Results are written to an Excel workbook opened by this script. 
#
# v 1.0  - 02/15/16 - Initial script. 
# v 1.1  - 02/26/16 - Enhanced Drive expansion logic. 
# v 1.5  - 04/06/16
#                     Added check to verify addition of storage from the Datastore was successful.
#                     Enhanced logic to verify the OS’s drive was successfully extended.
#                     Enhanced logic to speed script execution if the VM is found to have a logged on user. 
#                     Re-formatted console messages to specify VM name followed by status message. 
#      
#
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted

if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
	Add-PSSnapin VMware.VimAutomation.Core
}

Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter. 


#CSV file which lists the VMs to be upgraded.
#Format for CSV found at the head of this script.
$Machine_List = 'MachinesToUpgrade.csv'
$Machines = Import-Csv $Machine_List -Header @("VM","GBtoAdd")

$SleepTime = 120    #Time to wait for the VM to shutdown should the script have to shut it down. 
$ColdStartSleepTime = 60 #Time to wait if a VM cold start if necessary. 
$MaxDSPerc = 98   #Maximum percentage of allowed Datastore usage  
$MaxUpTime = 300  #Maximum uptime in minutes allowed when testing for a reboot. 
$VMCount = 0      #Init the VM Counter.

#Setup the Excel Workbook for results.
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

$range = $Worksheet.Columns.Item(1)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(2)
$range.ColumnWidth = 38
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(3)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(4)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(5)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(6)
$range.ColumnWidth = 35
$range.HorizontalAlignment = 3 
$range = $Worksheet.Columns.Item(7)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3  

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "VM Name"
$Worksheet.cells.Item(1,2) = "Action Taken"
$Worksheet.cells.Item(1,3) = "New Capacity"
$Worksheet.cells.Item(1,4) = "Capacity Added"
$Worksheet.cells.Item(1,5) = "Successfully Extended"
$Worksheet.cells.Item(1,6) = "DataStore"
$Worksheet.cells.Item(1,7) = "Percent Used"


foreach ($row in $Machines)   #Loop for each VM
    {
    Write-Host $row.VM "- Information being retrieved."
    $VM = Get-VM $row.VM       #Get object for the VM in process.
    $VMCount++                 #Keep a count of the VM in porcess.  Used to locate ouput row in Workbook.
    $LoggedOn = $False
    $Worksheet.cells.Item($VMCount + 1,1) = $VM.Name     #Write the VM's name to the Workbook.

        if ($VM.PowerState -eq "PoweredOn")   #Test if VM is powered on.
            {
            Write-Host $VM.Name "is Powered On."
            $vmWIMIinfo = Get-WmiObject -class Win32_ComputerSystem -ComputerName $VM.Guest.HostName  #Get some info on the VM via WIMI.
            if ($vmWIMIinfo.UserName -ne $null)    #Use the WIMI info to assure there is no logged on user.
                {
                Write-Host $VM.Name "has a logged on user:" $vmWIMIinfo.UserName
                $Worksheet.cells.Item($VMCount + 1,2) = "None. User Logged on: " + $vmWIMIinfo.UserName  #Store logged on user in workbook.
                $LoggedOn = $True
                }
            }
        else
            {
            Write-Host $VM.Name "is powered off.  Powering on!!!"
            start-VM -VM $VM.Name | Out-Null       #Start the VM.
            Write-Host $VM.Name "Waiting to cold start to complete."
            Start-Sleep $ColdStartSleepTime
            }

        $FreeSpace = $True
        
        If ($LoggedOn -eq $False)  #No logged on user, check datastore for space. 
            {
            Write-Host $VM.Name "Checking Datastore space."
            $DS = Get-Datastore -vm $VM.Name
            $DSUsed = $DS.CapacityMB - $DS.FreeSpaceMB
            $DSUsedPercent = [math]::round(($DSUsed * 100)/$DS.CapacityMB,2) 
            $Worksheet.cells.Item($VMCount + 1,6) = $DS.Name  #Store Datastore name
            $Worksheet.cells.Item($VMCount + 1,7) = [String]$DSUsedPercent + "%" #Store datastore percent used


            if($DSUsedPercent -ge $MaxDSPerc)  #Check to make sure datastore space is available.
                {
                $FreeSpace = $False
                $Worksheet.cells.Item($VMCount + 1,2) = "Datastore Full"
                } 
            }

        if ($LoggedOn -eq $False -and $FreeSpace -eq $True)  #Begin storage upgrade if no user is logged in and Storage is available.
            {
            $VMHD = Get-HardDisk -VM $VM.Name   #Retrieve VM Hard Disk info. 
            $HDLARGER = $VMHD.CapacityGB + $row.GBtoAdd
            Write-Host $VM.Name "is in process of Storage Upgrade to" $HDLARGER "GB."

            $VMHD | Set-HardDisk -CapacityGB $HDLARGER -Confirm:$false #-WhatIf   #Set new Hard Disk Size
            
            Write-Host $VM.Name "Verifying addition of storage."

            #pause

            $VMHD = Get-HardDisk -VM $VM.Name   #Refresh VM Hard Disk info variable to test for successful addition of storage. 
            $VMWIMI_DiskPart = Get-WmiObject Win32_diskpartition -ComputerName $VM.Name  #Retrieve partition information available to the OS.  
            $PartitionsTotal = 0
            foreach($partition in $VMWIMI_DiskPart)   #Sum the partitions as seen by the OS for later comparison to info obtained from VMWare. 
                {
                $PartitionsTotal += $partition.size
                }
            $PartitionsTotalGB = ($PartitionsTotal + 262144000)  / 1073741824  # Sum partitions in Bytes, add 250MB of Bytes, convert to GB.
            Write-Host $VM.Name "Size reported by Get-HardDisk =" $VMHD.CapacityGB 
            Write-Host $VM.Name "Size of OS drives reported by WMI - All Partitions + 250MB =" $PartitionsTotalGB 
            if ($VMHD.CapacityGB -gt "$PartitionsTotalGB")
                {
                Write-Host $VM.Name "Storage has been upgraded to" $HDLARGER "GB."
                $Worksheet.cells.Item($VMCount + 1,2) = "Storage added"
                $Worksheet.cells.Item($VMCount + 1,3) = $HDLARGER #Store total amount of storage after addition.
                $Worksheet.cells.Item($VMCount + 1,4) = $row.GBtoAdd 
                $StorageAdd = $True
                }
            else
                {
                Write-Host "All Partitions summed + 250MB Larger - Don't do it!!"
                Write-Host $VM.Name "The storage upgrade was unsuccessful."
                $Worksheet.cells.Item($VMCount + 1,2) = "NO Storage added"
                $StorageAdd = $False
                }
 
 
            if ($StorageAdd -eq $True)
                {
                Write-Host $VM.Name "is being Rebooted."
                Restart-VMGuest -VM $VM.Name
                }
          
            }     
    }



if ($VMCount -le 3)  #Pause added to account for short list of VMs.
    {
    Write-Host "Pausing to account for VM Reboots."
    Start-Sleep $SleepTime
    Write-Host "Sleeping"
    }


for ($c=1; $c -le $VMCount; $c++)  #Cycle through VMs with storage already added and extend drive.
    {
    if($Worksheet.cells.Item($c + 1,2).text -eq "Storage added" )
        {
        
        #verify the VM rebooted prior to extending the disk.
        Write-Host $Worksheet.cells.Item($c + 1,1).text "Verifying Reboot"
        $wmi = Get-WmiObject -Class Win32_OperatingSystem -computername $Worksheet.cells.Item($c + 1,1).text
        $uptime = $wmi.ConvertToDateTime($wmi.LocalDateTime) – $wmi.ConvertToDateTime($wmi.LastBootUpTime)
        Write-Host $Worksheet.cells.Item($c + 1,1).text "Uptime in Minutes" $uptime
        if ($uptime.TotalMinutes -le $MaxUpTime) 
            {
            Write-Host $Worksheet.cells.Item($c + 1,1).text "rebooted less than" $MaxUpTime "minutes ago."
            Write-Host $Worksheet.cells.Item($c + 1,1).text "is in process of extending disk."
            Get-HardDisk -VM $Worksheet.cells.Item($c + 1,1).text | Set-HardDisk -ResizeGuestPartition -CapacityGB $Worksheet.cells.Item($c + 1,3).text -Confirm:$false 3> $null | out-null
            $VMFreeSpace = Get-WmiObject Win32_logicaldisk -ComputerName $Worksheet.cells.Item($c + 1,1).text -filter "DeviceID='C:'"
            $VMFreeSpaceGB = $VMFreeSpace.FreeSpace / 1073741824
            Write-Host $Worksheet.cells.Item($c + 1,1).text "Free Space in GB on VM = "$VMFreeSpaceGB

            #Test to assure partition resize was successful.
            Write-Host $Worksheet.cells.Item($c + 1,1).text "Testing for successful hard drive extension."  
            $VMHDInfo = Get-HardDisk -VM $Worksheet.cells.Item($c + 1,1).text   #Retrieve Hard Disk info from VMWare 
            $VMWIMI_DiskPartInfo = Get-WmiObject Win32_diskpartition -ComputerName $Worksheet.cells.Item($c + 1,1).text  #Retrieve partition information available to the OS.  
            $PartTotal = 0

            foreach($partition in $VMWIMI_DiskPartInfo)   #Sum the partitions as seen by the OS for later comparison to info obtained from VMWare. 
                {
                $PartTotal += $partition.size
                }
            $PartTotalGB = ($PartTotal + 262144000)  / 1073741824  # Sum partitions in Bytes, add 250MB of Bytes, convert to GB.
            #Write-Host $Worksheet.cells.Item($c + 1,1).text "Size reported by Get-HardDisk =" $VMHDInfo.CapacityGB 
            #Write-Host $Worksheet.cells.Item($c + 1,1).text "Size of OS drives reported by WMI - All Partitions + 250MB =" $PartTotalGB 


            if ($VMHDInfo.CapacityGB -lt "$PartTotalGB")
                {
                Write-Host $Worksheet.cells.Item($c + 1,1).text "Storage extension verified successful."
                $Worksheet.cells.Item($c + 1,5) = "Yes" #Store upgrade status to workbook.
                }
            else
                {
                Write-Host $Worksheet.cells.Item($c + 1,1).text "Storage extension was unsuccessful."
                $Worksheet.cells.Item($c + 1,5) = "No" #Store upgrade status to workbook.
                }
            }
        else
            {
            Write-Host $Worksheet.cells.Item($c + 1,1).text "Did not reboot"
            $Worksheet.cells.Item($c + 1,5) = "No Reboot" #Store upgrade status to workbook.
            }
        }

    }  