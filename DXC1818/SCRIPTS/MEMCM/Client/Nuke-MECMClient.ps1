[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait
#$InstPath = '\\lounaswps08\idrive\D907ATS\70574\install'
#$CRID = '70574'
#$Site = Read-Host -Prompt "Enter the SIte Code"

$wkids = Get-Content -Path $InputPath
$wkids | ForEach-Object -Parallel {
    if (Test-Connection -ComputerName $_ -Count 2 -ErrorAction SilentlyContinue) {
        robocopy "\\lounaswps08\idrive\D907ATS\70574\install" "\\$_\c$\temp\70574" /E /Z /ZB /R:5 /W:5 /TBD /NP /V  
        Invoke-Command -ComputerName $_ -ScriptBlock {
            Set-Service -Name ccmexec -StartupType Disabled
            $svc = Get-Service -Name ccmexec
            Stop-Service -Name ccmexec -Force
            $svc.WaitForStatus('Stopped')
            Write-Output "Uninstall ConfigMgr Client $env:COMPUTERNAME"
            Start-Process -Wait "C:\Windows\ccmsetup\ccmsetup.exe" -ArgumentList "/uninstall" 
            Write-Output "Delete C:\Windows\ccmsetup $env:COMPUTERNAME"
            Remove-Item -Path C:\Windows\ccmsetup -Recurse -Force -ErrorAction SilentlyContinue
            Write-Output "Delete C:\Windows\CCM $env:COMPUTERNAME"
            Remove-Item -Path C:\Windows\CCM -Recurse -Force -ErrorAction SilentlyContinue
            Write-Output "Delete SMS certificates $env:COMPUTERNAME"
            Get-ChildItem Cert:\LocalMachine\SMS | Remove-Item
            Write-Output "Delete smscfg.ini $env:COMPUTERNAME"
            Remove-Item -Path C:\Windows\SMSCFG.INI -Force -ErrorAction SilentlyContinue
            Write-Output "Install ConfigMgr Client $env:COMPUTERNAME"
            #Add-Content -Path "C:\Temp\70574\install.cmd" -Value "C:\temp\70574\ccmsetup.exe /AllowMetered /MP /NoCRLCheck CCMCERTID=SMS;0D0D6E97CB644B5258854DF4AD6B6191D0394240 SMSCACHESIZE=51200 FSP=LOUAPPWPS1642.rsc.humad.com  CCMLOGMAXSIZE=5000000 CCMLOGMAXHISTORY=5 SMSSITECODE=$Site smsmplist=https://LOUAPPWPS1643.rsc.humad.com;https://LOUAPPWPS1644.rsc.humad.com;https://LOUAPPWPS1645.rsc.humad.com;https://LOUAPPWPS1646.rsc.humad.com;https://LOUAPPWPS1647.rsc.humad.com;https://LOUAPPWPS1648.rsc.humad.com;https://LOUAPPWPS1649.rsc.humad.com;https://LOUAPPWPS1653.rsc.humad.com;https://LOUAPPWPS1654.rsc.humad.com;https://LOUAPPWPS1655.rsc.humad.com;https://LOUAPPWPS1656.rsc.humad.com"
            #Start-Process -Wait -FilePath "C:\Temp\70574\install.cmd"
            #Get-Process ccmsetup | Wait-Process
            #Write-Output "Install kb11121541 $env:COMPUTERNAME"
            #& cmd /c msiexec /p "C:\temp\70574\X64\ClientUpdate\cm2107-client-kb11121541-x64.msp" /qn /l*v "C:\Temp\Software_Install_Logs\cm2107-client-kb11121541-x64.msp.log"
            & cmd /c "C:\temp\70574\Deploy-Application.exe -Site WP1"
            #Start-Sleep -Seconds 30
            #Write-Output "Delete $CRID"
            #Remove-Item -Path C:\temp\$CRID -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
