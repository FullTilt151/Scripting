$SerialNum=(Get-WmiObject MSFT_Disk -Namespace root/Microsoft/Windows/Storage).AdapterSerialNumber
Write-host $SerialNum