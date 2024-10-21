#Below are the updates that can be performed to the PowerShell Memory variable global quota:
Get-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB # 2048

#The PowerShell Memory Plugin Quota values also need to be updated are as below:
Get-Item WSMan:\localhost\Plugin\Microsoft.PowerShell\Quotas\MaxMemoryPerShellMB #2048
Get-Item WSMan:\localhost\Plugin\Microsoft.PowerShell32\Quotas\MaxMemoryPerShellMB #2048  (Essential for MID Server PowerShell as we are running 32 bit scripts)
Get-Item WSMan:\localhost\Plugin\Microsoft.PowerShell.workflow\Quotas\MaxMemoryPerShellMB #2048
Get-Item WSMan:\localhost\Plugin\microsoft.windows.servermanagerworkflows\Quotas\MaxMemoryPerShellMB #2048

#In addition, for scripts like Get Device Collection, which pull a lot of data from the SCCM remote server, below Plugin Quota values need to be updated:
Get-Item WSMan:\localhost\Plugin\’Event Forwarding Plugin’\Quotas\MaxConcurrentOperationsPerUser # 100 (default value is 15)
Get-Item WSMan:\localhost\Plugin\‘SEL Plugin’\Quotas\MaxConcurrentOperationsPerUser # 100 (default value is 15)