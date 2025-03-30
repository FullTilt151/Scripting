# This script will check if the Shopping service is running. If it is, it will then check the shopping.receiver.log file for last write time, if it's older than 7 minutes, email me to check. 
# Log example: New-CmnLogEntry -entry "Machine $computerName needs a restart." -type 2 -component 'Installer' -logFile $logFile -logEntries -MaxLogSize 10485760

$PSEmailServer = "pobox.humana.com"

# Check if the service is running.
$ShoppingService = Get-Service -ComputerName LOUAPPWPS1658 -Name shopping.receiver.v5.5.100

If($ShoppingService.Status -ne 'Running'){
    #Email me that it's not running.
    Send-MailMessage -to 'mcook9@Humana.com' -from 'configmgrsupport@humana.com' -Subject "Shopping Receiver service status: $($ShoppingService.Status)"
  
}
$wkids = 'SIMXDWTSSA1080', 'LOUXDWTSSA1221', 'SIMXDWSTDB3233'
foreach ($wkid in $wkids){ | $_ (Get-Service -name sysmon64).Status
        Write-Output $wkid $mc
}

Get-Service -ComputerName SIMXDWTSSA1080 -name sysmon64
Get-Service -ComputerName LOUXDWTSSA1221 -name sysmon64
Get-Service -ComputerName SIMXDWSTDB3233 -name sysmon64





