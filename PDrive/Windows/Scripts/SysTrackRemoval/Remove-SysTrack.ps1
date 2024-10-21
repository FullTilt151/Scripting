# SysTrack 6.01.0530
(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{A53C29BB-F5D9-441F-961C-EAB8BBC5F084}'} | ForEach-Object {
    Write-Output 'Found {A53C29BB-F5D9-441F-961C-EAB8BBC5F084} x64'
    & MsiExec.exe /x '{A53C29BB-F5D9-441F-961C-EAB8BBC5F084}' /qn /norestart /l*v c:\temp\LakesideSysTrackUninstall.log
}

# SysTrack 6.01.0530
(Get-ChildItem -Path HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{A53C29BB-F5D9-441F-961C-EAB8BBC5F084}'} | ForEach-Object {
    Write-Output 'Found {A53C29BB-F5D9-441F-961C-EAB8BBC5F084} x86'
    & MsiExec.exe /x '{A53C29BB-F5D9-441F-961C-EAB8BBC5F084}' /qn /norestart /l*v c:\temp\LakesideSysTrackUninstall.log
}

# SysTrack 6.01.0558
(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{B2697808-FF1D-4AA1-A6F8-2F1F935F663A}'} | ForEach-Object {
    Write-Output 'Found {B2697808-FF1D-4AA1-A6F8-2F1F935F663A} x64'
    & MsiExec.exe /x '{B2697808-FF1D-4AA1-A6F8-2F1F935F663A}' /qn /norestart /l*v c:\temp\LakesideSysTrackUninstall.log
}

# SysTrack 6.01.0558
(Get-ChildItem -Path HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{B2697808-FF1D-4AA1-A6F8-2F1F935F663A}'} | ForEach-Object {
    Write-Output 'Found {B2697808-FF1D-4AA1-A6F8-2F1F935F663A} x86'
    & MsiExec.exe /x '{B2697808-FF1D-4AA1-A6F8-2F1F935F663A}' /qn /norestart /l*v c:\temp\LakesideSysTrackUninstall.log
}

# SysTrack 7.01.0130
(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{57E21DE2-B8B3-456A-832D-F75511E8E08F}'} | ForEach-Object {
    Write-Output 'Found {57E21DE2-B8B3-456A-832D-F75511E8E08F} x64'
    & MsiExec.exe /x '{57E21DE2-B8B3-456A-832D-F75511E8E08F}' /qn /norestart /l*v c:\temp\LakesideSysTrackUninstall.log
}

# SysTrack 7.01.0130
(Get-ChildItem -Path HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{57E21DE2-B8B3-456A-832D-F75511E8E08F}'} | ForEach-Object {
    Write-Output 'Found {57E21DE2-B8B3-456A-832D-F75511E8E08F} x86'
    & MsiExec.exe /x '{57E21DE2-B8B3-456A-832D-F75511E8E08F}' /qn /norestart /l*v c:\temp\LakesideSysTrackUninstall.log
}