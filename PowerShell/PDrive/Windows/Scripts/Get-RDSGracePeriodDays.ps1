param(
[string]$ComputerName
)
$rds = Get-WmiObject -Namespace root\cimv2\terminalservices -Class win32_terminalservicesetting -ComputerName $ComputerName
$rds.GetGracePeriodDays().DaysLeft