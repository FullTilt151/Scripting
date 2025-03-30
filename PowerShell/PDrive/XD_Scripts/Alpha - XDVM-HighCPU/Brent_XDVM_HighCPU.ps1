if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
       Add-PSSnapin VMware.VimAutomation.Core
}
Connect-VIServer louvcswps05.rsc.humad.com | Out-Null    #Create the connection to the VCenter. 

#Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
 
#$Vms = Get-VM simxdwstdb1108
$VMs = Get-VM -name "*xdwstdb*"
#$MachineList = "VMs.csv"
#$VMs = Import-Csv $MachineList

workflow GetVMCPUStats {
    param($VMs)
    foreach –parallel ($computer in $VMs){
        $cpu = InlineScript {
            Add-PSSnapin VMware.VimAutomation.Core       
            Connect-VIServer louvcswps05.rsc.humad.com | Out-Null 
            $stat = Get-VM -Name $using:computer.name | Get-Stat -Server "louvcswps05.rsc.humad.com" -CPU -Realtime -Stat "cpu.usage.average" -maxsamples 1 | where {$_.MetricID -eq "cpu.usage.average"}
            Write-Output "$($Using:stat.Entity.name) $($Using:stat.value)"
        }
        $cpu
    }
} 

GetVMCPUStats -VMs $VMs





# $stat =$vm | Get-Stat -CPU -Realtime -maxsamples 1 | where {$_.MetricID -eq "cpu.usage.average"}
# Write-host $stat.Entity.name,"  ", $stat.value 
