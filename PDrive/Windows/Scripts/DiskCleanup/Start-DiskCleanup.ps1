# Clear prior Cleanmgr settings
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' -Name StateFlags0012 -ErrorAction SilentlyContinue | Remove-ItemProperty -Name StateFlags0001 -ErrorAction SilentlyContinue

# Set new CleanMgr settings
Set-ItemProperty -path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Sync Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -name StateFlags0012 -type DWORD -Value 2
Set-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -name StateFlags0012 -type DWORD -Value 2

Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:12' -WindowStyle Hidden -Wait

Get-Process -Name cleanmgr,dismhost -ErrorAction SilentlyContinue | Wait-Process -ErrorAction SilentlyContinue

# Clear user temp files
Get-ChildItem c:\users | ForEach-Object {
    if (Test-Path "$($_.FullName)\AppData\Local\Temp" -ErrorAction SilentlyContinue) {
        Get-ChildItem "$($_.FullName)\AppData\Local\Temp" -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
}

# Remove recycled files
$Shell = New-Object -ComObject Shell.Application
$RecycleBin = $Shell.Namespace(0xA)
$RecycleBin.items() | ForEach-Object { Remove-Item $_.path -Recurse -Force }