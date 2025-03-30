if ($env:COMPUTERNAME -eq 'GRBAPPWPS12' -or $env:COMPUTERNAME -match 'LOUAPPWTS115[012]' -or $env:COMPUTERNAME -match 'LOUAPPWPS174[01]' -or $env:COMPUTERNAME -match 'LOUAPPWPS182[12]' -or $env:COMPUTERNAME -match 'LOUAPPWPS164[2-5]' -or $env:COMPUTERNAME -match 'LOUAPPWPS164[6-9]' -or $env:COMPUTERNAME -match 'LOUAPPWPS165[3-7]') {
    Write-Output 'Removing WSUS services'
    Get-WindowsFeature -Name UpdateServices* | Where-Object {$_.InstallState -eq 'Installed'} | Uninstall-WindowsFeature
    Write-Output 'Removing D:\WSUS'
    Remove-Item -Path 'D:\WSUS' -Recurse -Force
    Write-Output 'Sleeping for two minutes'
    Start-Sleep -Seconds 120
    Write-Output 'Restarting computer'
    Restart-Computer
}
else {
    Write-Output 'This server isn''t supposed to be modified'
}