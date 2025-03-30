Get-Content C:\temp\pxe.txt | 
foreach {
    $tasks = (Get-WmiObject -Namespace root\ccm -Class sms_maintenancetaskrequests -ComputerName $_)
    Write-Output "$_ - $($tasks.count) found"
    if ($tasks.count -ne 0) {
        $tasks | Remove-WmiObject -Verbose
    }
    Get-Service ccmexec -ComputerName $_ | Restart-Service -Force
    #pause
}