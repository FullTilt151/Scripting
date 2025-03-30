$WKID='LOUAPPWPS2086'
#Get-WinEvent -ListLog * -ComputerName $WKID
#$LogName='Application'
#$LogName='System'
#$LogName='Security'
#$LogName='Microsoft-Windows-BitLocker/BitLocker Operational'
#$LogName='Microsoft-Windows-BitLocker/BitLocker Management'
#$LogName='Microsoft-Windows-MBAM/Operational'
#$LogName='Microsoft-Windows-MBAM/Admin'
###$LogName='Microsoft-Windows-BitLocker-DrivePreparationTool/Operational'
###$LogName='Microsoft-Windows-BitLocker-DrivePreparationTool/Admin'
$LogName='Microsoft-Windows-Deployment-Services-Diagnostics/Debug'
#$LogName='Cisco AnyConnect Secure Mobility Client'
#$ProviderName='Microsoft-Windows-Time-Service'
#$ProviderName='Microsoft-Windows-DNS-Client'
$Message = 'Relay'
$StartTime=Get-Date -Year 2022 -Month 03 -Day 23 -Hour 14 -Minute 58 -Second 00
$EndTime=Get-Date -Year 2022 -Month 03 -Day 23 -Hour 15 -Minute 50
IF (Test-Connection -ComputerName $WKID -Count 2 -ErrorAction SilentlyContinue) {
    Get-WinEvent -ComputerName $WKID -FilterHashtable @{
    LogName="$LogName";
    #ProviderName="$ProviderName";
    StartTime=$StartTime;EndTime=$EndTime;
    #Level=1
    #Level=2
    #Level=3
    #Level=1,2
    #Level=1,2,3
    #ID = 41 #System - Unexpected shutdown "System"
    #ID = 105 #System - Power source change.
    #ID = 506, 507 #System - Enter Connected Standby / Exited Connected Standby
    #ID = 1074 #System - initiated the restart of computer
    #ID = 6005, 6006 #System - The event log service was started" (Power on) #The event log service was stopped" (Power off)
    #ID = 2011, 2016, 2061 #Cisco AnyConnect Secure Mobility Client - Disruption of the VPN connection to the secure gateway. - Loss of the network interface used for the VPN connection. - The network interface for the VPN connection has gone down.
    #ID = 2012, 2070, 3020 #Cisco AnyConnect Secure Mobility Client - New network interface. - A new network interface has been detected. - VPN state: Connected
    #ID = 8003 #System - The system failed to register network adapter with settings:
    ID = 32769 #Microsoft-Windows-Deployment-Services-Diagnostics/Debug - BL Network Unlock
    } | 
    #Format-List
    Where-Object -Property Message -Match "$Message" 
    #| Out-File -FilePath C:\CIS_Temp\WKDC0KX93.txt
}