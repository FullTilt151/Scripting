Get-WmiObject Win32_Process -ComputerName WKMJNGD85 | 
select Name, @{Name="CPU_Time";
 Expression={$_.kernelmodetime + $_.usermodetime}} | sort Name