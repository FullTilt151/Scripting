$Date = Get-Date -Day 1
Get-ADComputer -Filter 'Name -like "*SIMXDWWTS*"' -Properties Name, LastLogonDate | Where-Object {$_.LastLogonDate -le $Date} | 
ForEach-Object {
    $_ | Set-ADComputer -Enabled $false
    Stop-Computer -ComputerName $($_.Name) -Force -ErrorAction SilentlyContinue
}

Get-ADComputer -Filter 'Name -like "SIMXDWWTS*"' -Properties Name, LastLogonDate, Enabled | Where-Object {$_.Enabled -eq $true} | sort LastLogonDate | Format-Table Name, LastLogonDate, Enabled
Get-ADComputer -Filter 'Name -like "LOUXDWWTS*"' -Properties Name, LastLogonDate, Enabled | Where-Object {$_.Enabled -eq $true} | sort LastLogonDate | Format-Table Name, LastLogonDate, Enabled


Get-Content C:\temp\wkids.txt |
ForEach-Object {
    Get-ADComputer -Identity $_ | Set-ADComputer -Enabled $false -Verbose
    if (Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue) {
        Stop-Computer -ComputerName $_ -Force -ErrorAction SilentlyContinue -Verbose
    }
}