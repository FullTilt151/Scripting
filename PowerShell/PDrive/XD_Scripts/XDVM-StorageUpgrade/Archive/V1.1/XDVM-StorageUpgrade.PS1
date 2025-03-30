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
$MaxDSPerc = 98
$VMCount = 0       #Init the VM Counter.

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

        $FreeSpace = $True
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

        if ($LoggedOn -eq $False -and $FreeSpace -eq $True)  #Begin storage upgrade if no user is logged in and Storage is available.
            {
            $HDSIZE = Get-HardDisk -VM $VM.Name
            $HDLARGER = $HDSIZE.CapacityGB + $row.GBtoAdd
            Write-Host $VM.Name "is in process of Storage Upgrade to" $HDLARGER "GB."
            Get-HardDisk -VM $VM.Name | Set-HardDisk -CapacityGB $HDLARGER -Confirm:$false
            Write-Host $VM.Name "Storage has been upgraded to" $HDLARGER "GB from " $HDSIZE.CapacityGB "GB."
            $Worksheet.cells.Item($VMCount + 1,2) = "Storage added"
            $Worksheet.cells.Item($VMCount + 1,3) = $HDLARGER #Store total amount of storage after addition.
            $Worksheet.cells.Item($VMCount + 1,4) = $row.GBtoAdd 
 
            if ($VM.PowerState -ne "PoweredOn")
                {
                Write-Host $VM.Name " is starting."
                Start-VM -VM $VM.Name | Out-Null       #Start the VM.
                }
            else
                {
                Write-Host $VM.Name " is being Rebooted."
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
        Write-Host $Worksheet.cells.Item($c + 1,1).text " is in process of extending disk."
        Get-HardDisk -VM $Worksheet.cells.Item($c + 1,1).text | Set-HardDisk -ResizeGuestPartition -CapacityGB $Worksheet.cells.Item($c + 1,3).text -Confirm:$false 3> $null | out-null
        $VMFreeSpace = Get-WmiObject Win32_logicaldisk -ComputerName $Worksheet.cells.Item($c + 1,1).text -filter "DeviceID='C:'"
        $VMFreeSpaceGB = $VMFreeSpace.FreeSpace / 1073741824
        Write-Host $VMFreeSpaceGB " Free Space on VM"
        if($VMFreeSpaceGB -ge $Worksheet.cells.Item($c + 1,4).text * .75)
            {
            $Worksheet.cells.Item($c + 1,5) = "Yes" #Store upgrade status to workbook.
            }
        else
            {
            $Worksheet.cells.Item($c + 1,5) = "No" #Store upgrade status to workbook.
            }
        }
    }