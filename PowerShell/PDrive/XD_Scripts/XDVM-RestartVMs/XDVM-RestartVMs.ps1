# XDVM-RegistrationCheck.ps1
# Restart VMs in CSV file
#
# Brent Griffith and Craig - Client Innovation Solutions.
#
# Reads a list of VMs to check from a CSV named MachinesToCheck.csv stored in the same directory as this script.

#
# v 1.0  - 10/13/2017 - Initial script. 
#
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted


#CSV file which lists the VMs to be moved.
#Format for CSV found at the head of this script.
$Machine_List = 'MachinesToCheck.csv'
$Machines = Import-Csv $Machine_List -Header @("VM")

$VMCount = 0       #Init the VM Counter.
$Error.Clear()     #Clear the Error array.


if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)   {Add-PSSnapin VMware.VimAutomation.Core}

Connect-VIServer louvcswps05.rsc.humad.com     #Create the connection to the VCenter.

foreach ($row in $Machines)   #Loop for each VM
    {
  
            Write-Output $row.VM "is being Rebooted"
            #start-vm -VM $row.VM
            #Restart-VMGuest -VM $row.VM
            Restart-Computer -ComputerName $row.VM
    }

