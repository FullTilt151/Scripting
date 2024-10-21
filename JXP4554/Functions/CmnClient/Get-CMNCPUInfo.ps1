$FileName = "C:\Temp\$($env:CLIENTNAME).txt"
#Drive Info
$objDrives = Get-WmiObject -Namespace root\cimv2 -Class Win32_LogicalDisk
foreach($Drive in $objDrives)
{
	if(($Drive.DeviceID -eq 'C:') -or ($Drive.DeviceID -eq 'F:')){"$($Drive.DeviceID) = $($Drive.Size / 1024 / 1024)" | Out-File -FilePath $FileName -Append}
}

#CPU Info
$objProccessor = Get-WmiObject -Namespace root\cimv2 -Class Win32_Processor
[int]$intTotalCores = 0
foreach($CPU in $objProccessor)
{
	$intTotalCores += $CPU.NumberOfLogicalProcessors
}

"Num Procs = $intTotalCores, Name = $($objProccessor[0].Name), Speed = {0:N0}" -f $objProccessor[0].MaxClockSpeed | Out-File -FilePath $FileName -Append

#Memory
$objMemory = Get-WmiObject -Namespace root\cimv2 -Class Win32_PhysicalMemory
[int64]$intTotalMemory = 0

foreach($Bank in $objMemory)
{
	$intTotalMemory += "{0:N0}" -f $Bank.Capacity
}
"Memory = $intTotalMemory" | Out-File -FilePath $FileName -Append