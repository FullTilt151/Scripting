$WKID = Read-Host -Prompt 'Please enter the WKID to check available storage '
Get-WmiObject Win32_logicaldisk -ComputerName  $WKID `
| Format-Table DeviceID,`
 @{Name="Size(GB)";Expression={[decimal]("{0:N0}" -f($_.size/1gb))}}, `
 @{Name="Free Space(GB)";Expression={[decimal]("{0:N2}" -f($_.freespace/1gb))}}, `
@{Name="Free (%)";Expression={"{0,6:P0}" -f(($_.freespace/1gb) / ($_.size/1gb))}} `
-AutoSize