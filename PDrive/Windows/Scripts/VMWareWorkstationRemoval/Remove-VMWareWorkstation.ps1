(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{A3FF5CB2-FB35-4658-8751-9EDE1D65B3AA}'} | ForEach-Object {
    Write-Output 'Found {A3FF5CB2-FB35-4658-8751-9EDE1D65B3AA} x64'
    & MsiExec.exe /x '{A3FF5CB2-FB35-4658-8751-9EDE1D65B3AA}' /qn /norestart /l*v c:\temp\VMWareWorkstationUninstall.log
}

(Get-ChildItem -Path HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{A3FF5CB2-FB35-4658-8751-9EDE1D65B3AA}'} | ForEach-Object {
    Write-Output 'Found {A3FF5CB2-FB35-4658-8751-9EDE1D65B3AA} x86'
    & MsiExec.exe /x '{A3FF5CB2-FB35-4658-8751-9EDE1D65B3AA}' /qn /norestart /l*v c:\temp\VMWareWorkstationUninstall.log
}

(Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{0D94F75A-0EA6-4951-B3AF-B145FA9E05C6}'} | ForEach-Object {
    Write-Output 'Found {0D94F75A-0EA6-4951-B3AF-B145FA9E05C6} x64'
    & MsiExec.exe /x '{0D94F75A-0EA6-4951-B3AF-B145FA9E05C6}' /qn /norestart /l*v c:\temp\VMWareWorkstationUninstall.log
}

(Get-ChildItem -Path HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall -recurse) | Where-Object {$_.PSChildName -eq '{0D94F75A-0EA6-4951-B3AF-B145FA9E05C6}'} | ForEach-Object {
    Write-Output 'Found {0D94F75A-0EA6-4951-B3AF-B145FA9E05C6} x86'
    & MsiExec.exe /x '{0D94F75A-0EA6-4951-B3AF-B145FA9E05C6}' /qn /norestart /l*v c:\temp\VMWareWorkstationUninstall.log
}