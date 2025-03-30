# XDVM-Count.ps1
#
# Walk the Production vCenters and count the VMs in the Hum and HGB environment. 
#
# Brent Griffith - Client Innovation Tech.
#
# v 1.0  - 11/29/17 - Initial scripy.  Walks the defined environments (Below) and takes a count of the VMs.

Set-ExecutionPolicy -ExecutionPolicy Unrestricted
if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
    {
	    Add-PSSnapin VMware.VimAutomation.Core
    }

#Define the Environments to query.

$VDIEnv1 = New-Object System.Object
$VDIEnv1 | Add-Member -type NoteProperty -name VMEnv "Prod User"
$VDIEnv1 | Add-Member -type NoteProperty -name Name -Value "louvcswps05.rsc.humad.com"
$VDIEnv1 | Add-Member -type NoteProperty -name ClusterID -Value "*xendesktop-[ls]*"
$VDIEnv1 | Add-Member -type NoteProperty -name VMCount -Value 0

$VDIEnv2 = New-Object System.Object
$VDIEnv2 | Add-Member -type NoteProperty -name VMEnv "AEC & W10 Pilot"
$VDIEnv2 | Add-Member -type NoteProperty -name Name -Value "simvcswps05.rsc.humad.com"
$VDIEnv2 | Add-Member -type NoteProperty -name ClusterID -Value "*xendesktop-[ls]*"
$VDIEnv2 | Add-Member -type NoteProperty -name VMCount -Value 0

$VDIEnv3 = New-Object System.Object
$VDIEnv3 | Add-Member -type NoteProperty -name VMEnv "DIG/RPA Bots"
$VDIEnv3 | Add-Member -type NoteProperty -name Name -Value "simvcswps05.rsc.humad.com"
$VDIEnv3 | Add-Member -type NoteProperty -name ClusterID -Value "*PROD-DIG*"
$VDIEnv3 | Add-Member -type NoteProperty -name VMCount -Value 0

<#$VDIEnv4 = New-Object System.Object
$VDIEnv4 | Add-Member -type NoteProperty -name VMEnv "HGB Non-Per"
$VDIEnv4 | Add-Member -type NoteProperty -name Name -Value "louvcswps02.rsc.humad.com"
$VDIEnv4 | Add-Member -type NoteProperty -name ClusterID -Value "*HGB*"
$VDIEnv4 | Add-Member -type NoteProperty -name VMCount -Value 0
#>

$AllVDIEnvs = @()
$AllVDIEnvs += $VDIEnv1, $VDIEnv2, $VDIEnv3

# Init some Variables
$VMHostCount = 0       #Catch the numbers of VMs per Host.
$TotalVMCount = 0      #Total VM count across the environment. 


for ($v=0; $v -lt $AllVDIEnvs.count; $v++ ) #Loop through the vCenter definitions
{
    Write-host `n`n "Processing Environment: " $AllVDIEnvs[$v].VMEnv  #A little output to show the script is running.
    Connect-VIServer $AllVDIEnvs[$v].name     #Create the connection to the VCenter. 
    $XDClusters = get-cluster -Name $AllVDIEnvs[$v].ClusterID | Sort  #Get the list of clusters based on ClusterID

    for ($c=0; $c -lt $XDClusters.count; $c++)  #Loop through the Clusters
        {
            Write-host "Processing Cluster: " $XDClusters[$c]  #A little output to show the script is running. 
        
            $Hosts = $XDClusters[$c] | Get-VMHost | sort         #Determine the list of Hosts within the current cluster.
            for ($h=0; $h -lt $Hosts.count; $h++)  #Loop throguh the hosts for the given cluster.
                { 
                    $VMHostCount = $Hosts[$h] | Get-View
                    $VMClusterCount = $VMClusterCount + $VMHostCount.vm.count  #Add to the VM count tracking this cluster.
                    #Output the total for the cluster if the last host is being processed. 
                    if ($h -eq $Hosts.count - 1) {Write-host $XDClusters[$c].name "VM Count: " $VMClusterCount `n}
                }
            $AllVDIEnvs[$v].VMCount = $AllVDIEnvs[$v].VMCount + $VMClusterCount #Record the VM count for the cluster in the cluster's object.  
            $VMClusterCount = 0    #Reset the VM counter per cluster to 0.              
        }
}
$AllVDIEnvs | format-table -AutoSize
$AllVDIEnvs | foreach {$TotalVMCount+=$_.VMcount}
Write-host `n "Total VM Count: " $TotalVMCount


