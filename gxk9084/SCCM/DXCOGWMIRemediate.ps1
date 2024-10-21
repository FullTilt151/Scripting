$svc = Get-Service -Name Winmgmt
Stop-Service Winmgmt -Force      
$svc.WaitForStatus('Stopped', '00:00:45')
& c:\windows\system32\wbem\WinMgmt.exe /resetrepository
Start-Process C:\windows\ccm\ccmrepair.exe
Get-Service -Name CcmExec | Start-Service

$Filename = "C:\temp\Wmirepair.ps1"
If (Test-Path $Filename)
    {
        Remove-Item $Filename
    }
New-Item -Path $Filename -ItemType File
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Net stop winmgmt /y' -Force
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Start-process c:\windows\system32\wbem\WinMgmt.exe /resetrepository -wait' -Force
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Start-Process C:\windows\ccm\ccmrepair.exe -wait' -Force
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Get-Service -Name CcmExec | Start-Service' -Force
Start-process powershell.exe -ArgumentList c:\temp\wmirepair.ps1



# $svc = Get-Service -Name Winmgmt
# Stop-Service Winmgmt -Force    
Net stop winmgmt /y  
# $svc.WaitForStatus('Stopped', '00:00:45')
# & c:\windows\system32\wbem\WinMgmt.exe /resetrepository
Start-process c:\windows\system32\wbem\WinMgmt.exe /resetrepository -wait
Start-Process C:\windows\ccm\ccmrepair.exe -wait
Get-Service -Name CcmExec | Start-Service

$Filename = "C:\temp\Wmirepair.ps1"
If (Test-Path $Filename)
    {
        Remove-Item $Filename
    }
New-Item -Path $Filename -ItemType File
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Net stop winmgmt /y' -Force
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Start-process c:\windows\system32\wbem\WinMgmt.exe /resetrepository -wait' -Force
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Start-Process C:\windows\ccm\ccmrepair.exe -wait' -Force
Add-Content -Path C:\temp\wmirepair.ps1 -Value 'Get-Service -Name CcmExec | Start-Service' -Force
Start-process powershell.exe -ArgumentList c:\temp\wmirepair.ps1