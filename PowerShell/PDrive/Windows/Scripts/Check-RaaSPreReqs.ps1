$wkid = "citpxewpw01"

(Get-ItemProperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -name "Personal").Personal.toString()

[System.Net.Dns]::GetHostByName($wkid).HostName

get-wmiobject Win32_ComputerSystem -computer $wkid | fl Name,Domain

[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$wkid).opensubkey('SOFTWARE\Microsoft\Windows NT\CurrentVersion').GetValue('CurrentVersion')

get-wmiobject WIN32_Share -computer $wkid | ? {$_.Name -eq"C$"} | FL Name

wevtutil qe System /c:1 /f:text /r:$wkid 2>&1

$([xml](schtasks /query /XML ONE /S $wkid)).Tasks.Task.Count