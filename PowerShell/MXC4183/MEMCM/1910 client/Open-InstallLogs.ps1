$logDir = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM\Logging\@Global -ErrorAction SilentlyContinue).LogDirectory
if (!$logdir) {$logDir = "$($env:windir)\CCM\Logs"}
$params = @("C:\Temp\Software_Install_Logs\System_Center_Configuration_Manager_(SCCM)_Client_PSAppDeployToolkit_Install.log","C:\Temp\Software_Install_Logs\MSI_Logs\ShoppingAgent_Install.log", "C:\Temp\Software_Install_Logs\MSI_Logs\NomadBranch-x64_Install.log", "C:\Windows\CCMSetup\Logs\CCMSetup.log", "$logdir\NomadBranch.log", "$logdir\DataTransferService.log", "$logdir\CAS.log", "$logdir\ClientIDManagerStartup.log", "$logdir\PolicyAgent.log", "$logdir\CCMExec.log", "$logdir\execmgr.log")
$cmd = 'cmtrace'
& $cmd $params