##RSAT
$Build = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
IF ($Build -ge '1809') {
    $currentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | Select-Object -ExpandProperty UseWUServer 
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0 
    Restart-Service wuauserv 
    Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU 
    Restart-Service wuauserv
}
IF ($Build -le '1803') {
    #Microsoft Remote Server Administration Tools for Windows 10 1803 (KB2693643)
    Start-Process -Wait "\\RSC.humad.com\iDrive\\d907ats\62849\install\deploy-application.exe" 
}

#Microsoft Quick Assist
Get-WindowsCapability -Name App.Support.QuickAssist* -Online | Add-WindowsCapability -Online

#PSTools
Robocopy \\LOUNASWPS08\pDrive\Dept907.CIT\Windows\Software\SysInternalsSuite\PsTools C:\Windows\System32 *.* /E

##Microsoft System Center Configuration Manager (SCCM) Console 5.2010.1093.1900 (2010)
Write-Host "Installing MEMCM Console and other software"
$SCode = Read-Host "Enter the Site Code"
Start-Process -Wait "\\lounaswps08\idrive\d907ats\68402\install\deploy-application.exe" -ArgumentList "-Site $SCode"
##1E Nomad admin extensions 
#Start-Process -Wait "\\lounaswps08\pdrive\Dept907.CIT\ConfigMgr\Packages\1E\Nomad\7.0_AdminExtTools\Deploy-Application.exe" -ArgumentList "-DeployMode Silent"
Start-Process -Wait "\\lounaswps08\pdrive\Dept907.CIT\1E\Repos\Nomad\7.0.200\NomadBranchAdminUIExt.msi"
Import-Module -Name "C:\Program Files (x86)\ConfigMgr10\bin\NomadBranchAdminUIExt\N1E.Precaching.Powershell" -Verbose
#1E PXEEveryWhere Central (Admin Tools - UpdateBootImage.exe)
Start-Process -Wait "\\LOUNASWPS08\pDrive\Dept907.CIT\1E\Repos\PXE Everywhere\4.0.100.22\PXEEverywhereCentral.msi"
#Dell Command Integration Suite for System Center
Start-Process -Wait "\\LOUNASWPS08\pDrive\Dept907.CIT\Windows\Software\Dell Command Integration Suite for System Center\Dell-Command-Integration-Suite-for-System-Center_JMPN3_WIN_6.0.0_A00.EXE"
##Microsoft Deployment Toolkit
Start-Process -Wait "\\LOUNASWPS08\pDrive\Dept907.CIT\Windows\Software\Microsoft Deployment Toolkit 8456\MicrosoftDeploymentToolkit_x64.msi"
##1E Shopping Administration 6.0
Start-Process -Wait "\\lounaswps08\idrive\d907ats\68202\install\deploy-application.exe" -ArgumentList "-DeployMode Silent"
##Azure Portal
Start-Process -Wait "\\LOUNASWPS08\pDrive\Dept907.CIT\ConfigMgr\Packages\Portal\AzurePortalInstaller.exe"
##Windows ADK
Start-Process -Wait "\\LOUNASWPS08\pDrive\Dept907.CIT\Windows\Software\Windows ADK 11\ADK\adksetup.exe"
Start-Process -Wait "\\LOUNASWPS08\pDrive\Dept907.CIT\Windows\Software\Windows ADK 11\ADKWinPEAddons\adkwinpesetup.exe"
##1E BIOS 2 UEFI
#Start-Process -Wait "\\LOUNASWPS08\pDrive\Dept907.CIT\1E\Repos\BIOStoUEFI\1ebiostouefi.v1.3.1703.2301\1EBiosToUefi.msi"

#Don Ho Notepad++ 8.2
Start-Process -Wait "\\LOUNASWPS08\iDrive\\d907ats\70284\Install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent" 

#Flo's Freeware Notepad2 4.2.25
Start-Process -Wait "\\RSC.humad.com\iDrive\d907ats\60462\Install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent" 

#Microsoft PowerShell 7.2.1
Start-Process -Wait "\\LOUNASWPS08\iDrive\d907ats\70276\install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent"
Install-Module  Invoke-CommandAs
Install-Module -Name PnP.PowerShell

#Igor Pavlov 7-Zip 19.00
Start-Process -Wait "\\RSC.humad.com\iDrive\d907ats\65210\install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent"

#The Git Development Community Git-SCM Git 2.35.1.2
Start-Process -Wait "\\LOUNASWPS08\iDrive\d907ats\70290\install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent" 

#Microsoft Visual Studio Code 1.64.2
Start-Process -Wait "\\LOUNASWPS08\iDrive\d907ats\70286\install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent" 

#mRemote mRemoteNG 1.76.20
Start-Process -Wait "\\RSC.humad.com\iDrive\D907ats\66630\install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent"

#Microsoft Remote Desktop Connection Manager 2.83
Start-Process -Wait "\\RSC.humad.com\iDrive\D907ats\69581\install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent"


#VMware Remote Console and Integration Plug-in 10.0.4
Start-Process -Wait "\\RSC.humad.com\iDrive\d907ats\64451\install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent" 

#Microsoft SQL Server Management Studio (SSMS) 18.9.2
Start-Process -Wait "\\LOUNASWPS08\iDrive\D907ATS\69476\Install\Deploy-Application.Exe" -ArgumentList "-DeployMode Silent" 

#Microsoft SQL Server Report Builder 15.0.19611.0
Start-Process -Wait "\\RSC.humad.com\iDrive\d907ats\69715\Install\Deploy-Application.EXE" -ArgumentList "-DeployMode Silent"

#Microsoft Power BI Desktop 2.102.845.0
Start-Process -Wait "\\RSC.humad.com\iDrive\d907ats\70563\install\Deploy-Application.exe" -ArgumentList "-DeployMode Silent" 

#ForeScout CounterACT Enterprise Manager Console 8.0
#Start-Process https://ldcfsemv51.humana.com/install

#Bomgar / Beyond Trust Remote Support
Start-Process https://myremotecontrol.humana.com/login

#MSFT Support Center \ OneTrace
Start-Process -Wait "\\Louappwts1441\sms_mt1\tools\SupportCenter\supportcenterinstaller.msi"

#MSFT CMTrace
Copy-Item -Path "\\Louappwts1441\sms_mt1\tools\cmtrace.exe" -Destination "C:\Windows\System32" -Force

#MSFT Network Monitor 3.4
Start-Process -Wait "\\LOUNASWPS08\pDrive\Dept907.CIT\Windows\Software\Microsoft Network Monitor 3.4\NM34_x64.exe"

#Microsoft Local Administrator Password Solution Management Tools
Start-Process -Wait "\\RSC.humad.com\idrive\Dept907.CIT\Windows\Packages\Microsoft_LAPS_6.2\Deploy-Application.exe " -ArgumentList "-InstallType Client -DeploymentType Uninstall"
Start-Process -Wait "\\RSC.humad.com\idrive\Dept907.CIT\Windows\Packages\Microsoft_LAPS_6.2\Deploy-Application.exe" -ArgumentList "-InstallType ManagementTools"

##Orchestrator Runbook (Need Daniel to push)

#Windows Admin Center
Start-Process -Wait "\\LOUNASWPS08\pDrive\Dept907.CIT\Windows\Software\Windows Admin Center\WindowsAdminCenter2009.msi"

#Windows SDK
Start-Process -Wait "\\LOUNASWPS08\Pdrive\Dept907.CIT\Windows\Software\Windows 10 SDK\2004\winsdksetup.exe"

#Microsoft 365 Enterprise ProPlus 64bit With Skype
#Start-Process -Wait "\\RSC.humad.com\iDrive\d907ats\66955\Install\Deploy-Application.EXE" -ArgumentList "-DeployMode Silent"

#Themes
IF ($env:UserName -eq 'dxc1818a') {
    $USERID = $env:USERNAME.Substring(0, $env:USERNAME.Length - 1)
    $Themes = Get-ChildItem -Path "\\MIRVNXE10\Userdat\$USERID\Themes"
    $Themes | ForEach-Object {
        Start-Process -Wait "\\MIRVNXE10\Userdat\$USERID\Themes\$_" }
    #Start Menu Layout backup
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument 'Export-StartLayout -Path "\\MIRVNXE10\UserDat\DXC1818\Backup\StartLayout_$env:COMPUTERNAME.xml"'
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 12pm
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Export Start Menu layout" -Description "Backup StartMenu layout" -Force -User DXC1818 -RunLevel "Highest"
}