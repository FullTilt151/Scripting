$objDrives = Get-WmiObject -Namespace root\cimv2 -Class Win32_LogicalDisk
foreach($Drive in $objDrives)
{
	if(($Drive.DeviceID -eq 'C:') -or ($Drive.DeviceID -eq 'F:')){"$($Drive.DeviceID) = $($Drive.Size / 1024 / 1024)" | Out-File -FilePath 'C:\Temp\DriveInfo.txt' -Append}
}