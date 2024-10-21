$WKID = 'WKMPMP19TW6N'
$Files = 'Nomad*'
$Date = Get-Date -Format MM-dd-yy

New-Item -Path "\\LOUNASWPS08\PDRIVE\Dept907.CIT\OSD\logs" -Name "$WKID" -ItemType Directory
New-Item -Path "\\LOUNASWPS08\PDRIVE\Dept907.CIT\OSD\logs\$WKID" -Name "$Date" -ItemType Directory
Copy-Item -Path \\$WKID\C$\Windows\CCM\Logs\$Files -Destination "\\LOUNASWPS08\PDRIVE\Dept907.CIT\OSD\logs\$WKID\$Date"