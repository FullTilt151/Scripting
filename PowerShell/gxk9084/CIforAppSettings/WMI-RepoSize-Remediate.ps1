#Reset WMI and repair MEMCM Client if Detection Script doesn't return "Compliant"

$Filename = "C:\temp\Wmirepair.ps1"
If (Test-Path $Filename)
    {
        Remove-Item $Filename
    }
New-Item -Path $Filename -ItemType File
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Write-Output "String" | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Write-Output "Disable WinMgmt Service" | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Set-Service -Name Winmgmt -StartupType Disabled -PassThru | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Write-Output "Get WinMgmt processid" | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
$id = Get-WmiObject -Class Win32_Service -Filter "Name LIKE 'Winmgmt'" | Select-Object -ExpandProperty ProcessId
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Write-Output "Stop WinMgmt processid" | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value "Stop-Process -Id $id -Force -PassThru | Out-File `"C:\Temp\WMI_Repo.log`" -Append -NoClobber"
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Write-Output "Reset WMI Repository" | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Start-Process -FilePath "c:\windows\system32\wbem\WinMgmt.exe" -ArgumentList "/resetrepository" -wait -PassThru | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Write-Output "Enable WinMgmt Service" | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Set-Service -Name Winmgmt -StartupType Automatic -PassThru | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Write-Output "Start CCMRepair" | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Start-Process -filepath "C:\windows\ccm\ccmrepair.exe" -wait -PassThru | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Write-Output "Start CCMExec" | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Start-Service -Name CcmExec -PassThru | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber'
Start-Sleep -seconds 2
Add-Content -Path C:\temp\wmirepair.ps1 -Value '$backupdir01 = "C:\Windows\system32\wbem\repository.001"'
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'If (Test-Path -Path $backupdir01) {Remove-Item -Path $backupdir01 -Recurse -force}'

    

powershell.exe -executionpolicy bypass C:\temp\Wmirepair.ps1 -whatif