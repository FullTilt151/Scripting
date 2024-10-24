<#
.SYNOPSIS
    Please note, that this script configures Windows 10 with minimal configuration specifically for Virtual Desktops - VDI.
.DESCRIPTION
    This script is provided as is! Meaning www.ervik.as is not aligable to any problems, issues or other system errors you may or may not encounter!
    This script configures Windows 10 with minimal configuration for VDI. It does not matter if you use Citrix XenDesktop or VMWare Horizon View, this script tunes Windows 10 as an OS!
       
    // ************* 
    // *  CAUTION  * 
    // ************* 
    THIS SCRIPT MAKES CONSIDERABLE CHANGES TO THE DEFAULT CONFIGURATION OF WINDOWS.
    This script is provided AS IS! Meaning www.ervik.as is NOT aligable to any problems, issues or other system errors you may or may not encounter!
    Please review this script THOROUGHLY before applying to your virtual machine, and disable changes below as necessary to adjust it 
    to your current environment.
    Remember if you break it, it's your own fault!!!!! 
.PARAMETER NoWarn
    Need to debug, or have you added more tuning? Use this to remove the warning prompts at the beginning and end of the script!
.EXAMPLE
    .\VDI_Tuner_for_Windows_10.ps1 -NoWarn $true
.NOTES
    Author:       Alexander Ervik Johnsen
    Last Update:  15.04.2016
    Version:      1.0
.LOG
    1.0 - First release, 
#>


# Parse Params:
[CmdletBinding()]
Param(
    [Parameter(
        Position=0,
        Mandatory=$False,
        HelpMessage="True or False, do you want to see the warning prompts"
        )] 
        [bool] $NoWarn = $False
    )


# Throw caution (to the wind?) - show if NoWarn param is not passed, or passed as $false:
If ($NoWarn -eq $False)
{
    Write-Host "THIS SCRIPT MAKES MANY CHANGES TO THE DEFAULT INSTALLATION OF WINDOWS 10 - SO USE ONLY FOR VDI AND AT YOUR OWN RISK!." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please review this script THOROUGHLY before applying to your virtual machine, and disable changes below as necessary to suit your current environment." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "This script is provided AS-IS - usage of this source assumes that you are at the very least familiar with PowerShell, and the tools used to create and debug this script." -ForegroundColor Yellow
    Write-Host ""
    Write-Host ""
    Write-Host "In other words, if you break it, you get to keep the pieces." -ForegroundColor Magenta
    Write-Host ""
    Write-Host ""
}


$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"

# Configure Constants:
$BranchCache = "False"
$Cortana = "False"
$DiagService = "False"
$EAPService = "False"
$EFS = "False"
$FileHistoryService = "False"
$iSCSI = "False"
$MachPass = "True"
$MSSignInService = "True"
$OneDrive = "True"
$PeerCache = "False"
$Search = "True"
$SMB1 = "False"
$SMBPerf = "False"
$Themes = "True"
$Touch = "False"

$StartApps = "False"
$AllStartApps = "True"

$Install_NetFX3 = "True"
$NetFX3_Source = "D:\Sources\SxS"

$RDPEnable = 1
$RDPFirewallOpen = 1
$NLAEnable = 1


# Set up additional registry drives:
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null


# Get list of Provisioned Start Screen Apps
$Apps = Get-ProvisionedAppxPackage -Online


# // ============
# // Begin Config
# // ============


# Set VM to High Perf scheme:
Write-Host "Setting VM to High Performance Power Scheme..." -ForegroundColor Green
Write-Host ""
POWERCFG -SetActive '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'


#Install NetFX3
If ($Install_NetFX3 -eq "True")
{
    Write-Host "Installing .NET 3.5..." -ForegroundColor Green
    dism /online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:$NetFX3_Source /NoRestart
    Write-Host ""
    Write-Host ""
}


# Remove (Almost All) Inbox Universal Apps:
If ($StartApps -eq "False")
{
    # Disable "Consumer Features" (aka downloading apps from the internet automatically)
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'CloudContent' | Out-Null
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures' -PropertyType DWORD -Value '1' | Out-Null
    # Disable the "how to use Windows" contextual popups
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableSoftLanding' -PropertyType DWORD -Value '1' | Out-Null 

    Write-Host "Removing (most) built-in Universal Apps..." -ForegroundColor Yellow
    Write-Host ""
    
    ForEach ($App in $Apps)
    {
        # Help / "Get" Apps
        If ($App.DisplayName -eq "Microsoft.Getstarted")
        {
            Write-Host "Removing Get Started App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.SkypeApp")
        {
            Write-Host "Removing Get Skype App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.MicrosoftOfficeHub")
        {
            Write-Host "Removing Get Office App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        # Games / XBox apps
        If ($App.DisplayName -eq "Microsoft.XboxApp")
        {
            Write-Host "Removing XBox App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.ZuneMusic")
        {
            Write-Host "Removing Groove Music App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.ZuneVideo")
        {
            Write-Host "Removing Movies & TV App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.MicrosoftSolitaireCollection")
        {
            Write-Host "Removing Microsoft Solitaire Collection App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

	# News / Sports / Weather
        If ($App.DisplayName -eq "Microsoft.BingFinance")
        {
            Write-Host "Removing Finance App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.BingNews")
        {
            Write-Host "Removing News App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.BingSports")
        {
            Write-Host "Removing Sports App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.BingWeather")
        {
            Write-Host "Removing Weather App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        # Others
        If ($App.DisplayName -eq "Microsoft.3DBuilder")
        {
            Write-Host "Removing 3D Builder App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.People")
        {
            Write-Host "Removing People App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.WindowsAlarms")
        {
            Write-Host "Removing Alarms App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

	If ($App.DisplayName -eq "Microsoft.Windows.Photos")
        {
            Write-Host "Removing Photos App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        <#
        If ($App.DisplayName -eq "Microsoft.WindowsCalculator")
        {
            Write-Host "Removing Calculator Store App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }
        #>

        If ($App.DisplayName -eq "Microsoft.WindowsCamera")
        {
            Write-Host "Removing Camera App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.WindowsMaps")
        {
            Write-Host "Removing Maps App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.WindowsPhone")
        {
            Write-Host "Removing Phone Companion App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }

        If ($App.DisplayName -eq "Microsoft.WindowsSoundRecorder")
        {
            Write-Host "Removing Voice Recorder App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }
        
        If ($App.DisplayName -eq "Microsoft.Office.Sway")
        {
            Write-Host "Removing Office Sway App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }
        
        If ($App.DisplayName -eq "Microsoft.Messaging")
        {
            Write-Host "Removing Messaging App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }
        
        If ($App.DisplayName -eq "Microsoft.ConnectivityStore")
        {
            Write-Host "Removing Connectivity Store helper App..." -ForegroundColor Yellow
            Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
            Remove-AppxPackage -Package $App.PackageName | Out-Null
        }
    }

    Start-Sleep -Seconds 5
    Write-Host ""
    Write-Host ""

    # Remove (the rest of the) Inbox Universal Apps:
    If ($AllStartApps -eq "False")
    {
        Write-Host "Removing (the rest of the) built-in Universal Apps..." -ForegroundColor Magenta
        Write-Host ""
        ForEach ($App in $Apps)
        {
            If ($App.DisplayName -eq "Microsoft.Office.OneNote")
            {
                Write-Host "Removing OneNote App..." -ForegroundColor Magenta
                Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
                Remove-AppxPackage -Package $App.PackageName | Out-Null
            }

            If ($App.DisplayName -eq "Microsoft.windowscommunicationsapps")
            {
                Write-Host "Removing People, Mail, and Calendar Apps support..." -ForegroundColor Magenta
                Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
                Remove-AppxPackage -Package $App.PackageName | Out-Null
            }
            
            If ($App.DisplayName -eq "Microsoft.CommsPhone")
            {
                Write-Host "Removing CommsPhone helper App..." -ForegroundColor Yellow
                Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
                Remove-AppxPackage -Package $App.PackageName | Out-Null
            }

            If ($App.DisplayName -eq "Microsoft.WindowsStore")
            {
                Write-Host "Removing Store App..." -ForegroundColor Red
                Remove-AppxProvisionedPackage -Online -PackageName $App.PackageName | Out-Null
                Remove-AppxPackage -Package $App.PackageName | Out-Null
            }
        }
        Start-Sleep -Seconds 5
        Write-Host ""
        Write-Host ""
    }
}


# Disable Cortana:
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'Windows Search' | Out-Null
If ($Cortana -eq "False")
{
    Write-Host "Disabling Cortana..." -ForegroundColor Yellow
    Write-Host ""
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -PropertyType DWORD -Value '0' | Out-Null
}


# Remove OneDrive:
If ($OneDrive -eq "False")
{
    # Remove OneDrive (not guaranteed to be permanent - see https://support.office.com/en-US/article/Turn-off-or-uninstall-OneDrive-f32a17ce-3336-40fe-9c38-6efb09f944b0):
    Write-Host "Removing OneDrive..." -ForegroundColor Yellow
    C:\Windows\SysWOW64\OneDriveSetup.exe /uninstall
    Start-Sleep -Seconds 30
    New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'Skydrive' | Out-Null
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive' -Name 'DisableFileSync' -PropertyType DWORD -Value '1' | Out-Null
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive' -Name 'DisableLibrariesDefaultSaveToSkyDrive' -PropertyType DWORD -Value '1' | Out-Null 
    Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{A52BBA46-E9E1-435f-B3D9-28DAA648C0F6}' -Recurse
    Remove-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{A52BBA46-E9E1-435f-B3D9-28DAA648C0F6}' -Recurse
    Set-ItemProperty -Path 'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Name 'System.IsPinnedToNameSpaceTree' -Value '0'
    Set-ItemProperty -Path 'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Name 'System.IsPinnedToNameSpaceTree' -Value '0' 
}


# Set PeerCaching to Disabled (0) or Local Network PCs only (1):
If ($PeerCache -eq "False")
{
    Write-Host "Disabling PeerCaching..." -ForegroundColor Yellow
    Write-Host ""
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' -Name 'DODownloadMode' -Value '0'
}
Else
{
    Write-Host "Configuring PeerCaching..." -ForegroundColor Cyan
    Write-Host ""
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config' -Name 'DODownloadMode' -Value '1'
}


# Disable Services:
Write-Host "Configuring Services..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Disabling AllJoyn Router Service..." -ForegroundColor Cyan
Set-Service AJRouter -StartupType Disabled

Write-Host "Disabling Application Layer Gateway Service..." -ForegroundColor Cyan
Set-Service ALG -StartupType Disabled

Write-Host "Disabling Background Intelligent Transfer Service..." -ForegroundColor Cyan
Set-Service BITS -StartupType Disabled

Write-Host "Disabling Bitlocker Drive Encryption Service..." -ForegroundColor Cyan
Set-Service BDESVC -StartupType Disabled

Write-Host "Disabling Block Level Backup Engine Service..." -ForegroundColor Cyan
Set-Service wbengine -StartupType Disabled

Write-Host "Disabling Bluetooth Handsfree Service..." -ForegroundColor Cyan
Set-Service BthHFSrv -StartupType Disabled

Write-Host "Disabling Bluetooth Support Service..." -ForegroundColor Cyan
Set-Service bthserv -StartupType Disabled

If ($BranchCache -eq "False")
{
    Write-Host "Disabling BranchCache Service..." -ForegroundColor Yellow
    Set-Service PeerDistSvc -StartupType Disabled
}

Write-Host "Disabling Computer Browser Service..." -ForegroundColor Cyan
Set-Service Browser -StartupType Disabled

Write-Host "Disabling Device Association Service..." -ForegroundColor Cyan
Set-Service DeviceAssociationService -StartupType Disabled

Write-Host "Disabling Device Setup Manager Service..." -ForegroundColor Cyan
Set-Service DsmSvc -StartupType Disabled

Write-Host "Disabling Diagnostic Policy Service..." -ForegroundColor Cyan
Set-Service DPS -StartupType Disabled

Write-Host "Disabling Diagnostic Service Host Service..." -ForegroundColor Cyan
Set-Service WdiServiceHost -StartupType Disabled

Write-Host "Disabling Diagnostic System Host Service..." -ForegroundColor Cyan
Set-Service WdiSystemHost -StartupType Disabled

If ($DiagService -eq "False")
{
    Write-Host "Disabling Diagnostics Tracking Service..." -ForegroundColor Yellow
    Set-Service DiagTrack -StartupType Disabled
}

If ($EFS -eq "False")
{
    Write-Host "Disabling Encrypting File System Service..." -ForegroundColor Yellow
    Set-Service EFS -StartupType Disabled
}

If ($EAPService -eq "False")
{
    Write-Host "Disabling Extensible Authentication Protocol Service..." -ForegroundColor Yellow
    Set-Service Eaphost -StartupType Disabled
}

Write-Host "Disabling Fax Service..." -ForegroundColor Cyan
Set-Service Fax -StartupType Disabled

Write-Host "Disabling Function Discovery Resource Publication Service..." -ForegroundColor Cyan
Set-Service FDResPub -StartupType Disabled

If ($FileHistoryService -eq "False")
{
    Write-Host "Disabling File History Service..." -ForegroundColor Yellow
    Set-Service fhsvc -StartupType Disabled
}

Write-Host "Disabling Geolocation Service..." -ForegroundColor Cyan
Set-Service lfsvc -StartupType Disabled

Write-Host "Disabling Home Group Listener Service..." -ForegroundColor Cyan
Set-Service HomeGroupListener -StartupType Disabled

Write-Host "Disabling Home Group Provider Service..." -ForegroundColor Cyan
Set-Service HomeGroupProvider -StartupType Disabled

Write-Host "Disabling Home Group Provider Service..." -ForegroundColor Cyan
Set-Service HomeGroupProvider -StartupType Disabled

Write-Host "Disabling Internet Connection Sharing (ICS) Service..." -ForegroundColor Cyan
Set-Service SharedAccess -StartupType Disabled

If ($MSSignInService -eq "False")
{
    Write-Host "Disabling Microsoft Account Sign-in Assistant Service..." -ForegroundColor Yellow
    Set-Service wlidsvc -StartupType Disabled
}

If ($iSCSI -eq "False")
{
    Write-Host "Disabling Microsoft iSCSI Initiator Service..." -ForegroundColor Yellow
    Set-Service MSiSCSI -StartupType Disabled
}

Write-Host "Disabling Microsoft Software Shadow Copy Provider Service..." -ForegroundColor Cyan
Set-Service swprv -StartupType Disabled

Write-Host "Disabling Microsoft Storage Spaces SMP Service..." -ForegroundColor Cyan
Set-Service swprv -StartupType Disabled

Write-Host "Disabling Offline Files Service..." -ForegroundColor Cyan
Set-Service CscService -StartupType Disabled

Write-Host "Disabling Optimize drives Service..." -ForegroundColor Cyan
Set-Service defragsvc -StartupType Disabled

Write-Host "Disabling Program Compatibility Assistant Service..." -ForegroundColor Cyan
Set-Service PcaSvc -StartupType Disabled

Write-Host "Disabling Quality Windows Audio Video Experience Service..." -ForegroundColor Cyan
Set-Service QWAVE -StartupType Disabled

Write-Host "Disabling Retail Demo Service..." -ForegroundColor Cyan
Set-Service RetailDemo -StartupType Disabled

Write-Host "Disabling Secure Socket Tunneling Protocol Service..." -ForegroundColor Cyan
Set-Service SstpSvc -StartupType Disabled

Write-Host "Disabling Sensor Data Service..." -ForegroundColor Cyan
Set-Service SensorDataService -StartupType Disabled

Write-Host "Disabling Sensor Monitoring Service..." -ForegroundColor Cyan
Set-Service SensrSvc -StartupType Disabled

Write-Host "Disabling Sensor Service..." -ForegroundColor Cyan
Set-Service SensorService -StartupType Disabled

Write-Host "Disabling Shell Hardware Detection Service..." -ForegroundColor Cyan
Set-Service ShellHWDetection -StartupType Disabled

Write-Host "Disabling SNMP Trap Service..." -ForegroundColor Cyan
Set-Service SNMPTRAP -StartupType Disabled

Write-Host "Disabling Spot Verifier Service..." -ForegroundColor Cyan
Set-Service svsvc -StartupType Disabled

Write-Host "Disabling SSDP Discovery Service..." -ForegroundColor Cyan
Set-Service SSDPSRV -StartupType Disabled

Write-Host "Disabling Still Image Acquisition Events Service..." -ForegroundColor Cyan
Set-Service WiaRpc -StartupType Disabled

Write-Host "Disabling Telephony Service..." -ForegroundColor Cyan
Set-Service TapiSrv -StartupType Disabled

If ($Themes -eq "False")
{
    Write-Host "Disabling Themes Service..." -ForegroundColor Yellow
    Set-Service Themes -StartupType Disabled
}

If ($Touch -eq "False")
{
    Write-Host "Disabling Touch Keyboard and Handwriting Panel Service..." -ForegroundColor Yellow
    Set-Service TabletInputService -StartupType Disabled
}

Write-Host "Disabling UPnP Device Host Service..." -ForegroundColor Cyan
Set-Service upnphost -StartupType Disabled

Write-Host "Disabling Volume Shadow Copy Service..." -ForegroundColor Cyan
Set-Service VSS -StartupType Disabled

Write-Host "Disabling Windows Color System Service..." -ForegroundColor Cyan
Set-Service WcsPlugInService -StartupType Disabled

Write-Host "Disabling Windows Connect Now - Config Registrar Service..." -ForegroundColor Cyan
Set-Service wcncsvc -StartupType Disabled

Write-Host "Disabling Windows Error Reporting Service..." -ForegroundColor Cyan
Set-Service WerSvc -StartupType Disabled

Write-Host "Disabling Windows Image Acquisition (WIA) Service..." -ForegroundColor Cyan
Set-Service stisvc -StartupType Disabled

Write-Host "Disabling Windows Media Player Network Sharing Service..." -ForegroundColor Cyan
Set-Service WMPNetworkSvc -StartupType Disabled

Write-Host "Disabling Windows Mobile Hotspot Service..." -ForegroundColor Cyan
Set-Service icssvc -StartupType Disabled

If ($Search -eq "False")
{
    Write-Host "Disabling Windows Search Service..." -ForegroundColor Yellow
    Set-Service WSearch -StartupType Disabled
}

Write-Host "Disabling WLAN AutoConfig Service..." -ForegroundColor Cyan
Set-Service WlanSvc -StartupType Disabled

Write-Host "Disabling WWAN AutoConfig Service..." -ForegroundColor Cyan
Set-Service WwanSvc -StartupType Disabled

Write-Host "Disabling Xbox Live Auth Manager Service..." -ForegroundColor Cyan
Set-Service XblAuthManager -StartupType Disabled

Write-Host "Disabling Xbox Live Game Save Service..." -ForegroundColor Cyan
Set-Service XblGameSave -StartupType Disabled

Write-Host "Disabling Xbox Live Networking Service Service..." -ForegroundColor Cyan
Set-Service XboxNetApiSvc -StartupType Disabled
Write-Host ""


# Reconfigure / Change Services:
Write-Host "Configuring Network List Service to start Automatic..." -ForegroundColor Green
Write-Host ""
Set-Service netprofm -StartupType Automatic
Write-Host ""

Write-Host "Configuring Windows Update Service to run in standalone svchost..." -ForegroundColor Cyan
Write-Host ""
sc.exe config wuauserv type= own
Write-Host ""


# Disable Scheduled Tasks:
Write-Host "Disabling Scheduled Tasks..." -ForegroundColor Cyan
Write-Host ""
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Autochk\Proxy" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Bluetooth\UninstallDeviceTask" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Diagnosis\Scheduled" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maintenance\WinSAT" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsToastTask" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Maps\MapsUpdateTask" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Ras\MobilityManager" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Registry\RegIdleBackup" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Shell\FamilySafetyMonitor" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Shell\FamilySafetyRefresh" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\SystemRestore\SR" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\UPnP\UPnPHostConfig" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\WDI\ResolutionHost" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\WOF\WIM-Hash-Management" | Out-Null
Disable-ScheduledTask -TaskName "\Microsoft\Windows\WOF\WIM-Hash-Validation" | Out-Null


# Disable Hard Disk Timeouts:
Write-Host "Disabling Hard Disk Timeouts..." -ForegroundColor Yellow
Write-Host ""
POWERCFG /SETACVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
POWERCFG /SETDCVALUEINDEX 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0


# Disable Hibernate
Write-Host "Disabling Hibernate..." -ForegroundColor Green
Write-Host ""
POWERCFG -h off


# Disable Large Send Offload
Write-Host "Disabling TCP Large Send Offload..." -ForegroundColor Green
Write-Host ""
New-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -Name 'DisableTaskOffload' -PropertyType DWORD -Value '1' | Out-Null


# Disable System Restore
Write-Host "Disabling System Restore..." -ForegroundColor Green
Write-Host ""
Disable-ComputerRestore -Drive "C:\"


# Disable NTFS Last Access Timestamps
Write-Host "Disabling NTFS Last Access Timestamps..." -ForegroundColor Yellow
Write-Host ""
FSUTIL behavior set disablelastaccess 1 | Out-Null

If ($MachPass -eq "False")
{
    # Disable Machine Account Password Changes
    Write-Host "Disabling Machine Account Password Changes..." -ForegroundColor Yellow
    Write-Host ""
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters' -Name 'DisablePasswordChange' -Value '1'
}

# Disable Default system Screensaver
Write-Host "Disabling Default System Screensaver..." -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_USERS\.DEFAULT\ControlPanel\Desktop' -Name 'ScreenSaveActive' -PropertyType DWORD -Value '0'

# Disable the Windows 10 First Logon Animation
Write-Host "Disabling Windows 10 First Logon Animation..." -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableFirstLogonAnimation' -PropertyType DWORD -Value '0'

# Hide Hard Error Messages
Write-Host "Hides Hard Error Messages" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_LOCAL_MACHINE\SOFTWARE\System\CurrentControlSet\Control\Windows' -Name 'ErrorMode' -PropertyType DWORD -Value '2'

# Settings "Visual Effects to Custom"	
Write-Host "Set Visual Effects to Custom" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -PropertyType DWORD -Value '3'

# Settings "Disable Show translucent selection rectangle"
Write-Host "Disable Show translucent selection rectangle" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewAlphaSelect' -PropertyType DWORD -Value '0'

# Settings "Disable Show shadows under windows"
Write-Host "Disable Show shadows under windows" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewShadow' -PropertyType DWORD -Value '0'

# Settings "Disable Animate windows when minimizing and maximizing"
Write-Host "Disable ate windows when minimizing and maximizing" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_CURRENT_USER \ControlPanel\Desktop\WindowMetrics' -Name 'MinAnimate' -Value '0'

# Settings "Disable Animations in the taskbar"
Write-Host "Disable Animations in the taskbar" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -PropertyType DWORD -Value '0'

# Settings "Disable Save Taskbar Thumbnail Previews"
Write-Host "Disable Save Taskbar Thumbnail Previews" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM' -Name 'AlwaysHibernateThumbnails' -PropertyType DWORD -Value '0'

# Settings "Disable Enable Peek"
Write-Host "Disable Enable Peek" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM' -Name 'EnableAeroPeek' -PropertyType DWORD -Value '0'

# Settings "Disable Smooth edges of screen fonts"
Write-Host "Disable Smooth edges of screen fonts" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_CURRENT_USER \Control Panel\Desktop' -Name 'FontSmoothing' -Value '0'

# Settings "Reduce menu show delay"
Write-Host "Reduce menu show delay" -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKEY_CURRENT_USER\ControlPanel\Desktop' -Name 'MenuShowDelay' -Value '0'

# Disable Memory Dumps
Write-Host "Disabling Memory Dump Creation..." -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'CrashDumpEnabled' -Value '1'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'LogEvent' -Value '0'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'SendAlert' -Value '0'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'AutoReboot' -Value '1'


# Increase Service Startup Timeout:
Write-Host "Increasing Service Startup Timeout To 180 Seconds..." -ForegroundColor Yellow
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'ServicesPipeTimeout' -Value '180000'


# Increase Disk I/O Timeout to 200 Seconds:
Write-Host "Increasing Disk I/O Timeout to 200 Seconds..." -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Disk' -Name 'TimeOutValue' -Value '200'


# Disable IE First Run Wizard:
Write-Host "Disabling IE First Run Wizard..." -ForegroundColor Green
Write-Host ""
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft' -Name 'Internet Explorer' | Out-Null
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer' -Name 'Main' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main' -Name DisableFirstRunCustomize -PropertyType DWORD -Value '1' | Out-Null


# Disable New Network Dialog:
Write-Host "Disabling New Network Dialog..." -ForegroundColor Green
Write-Host ""
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Network' -Name 'NewNetworkWindowOff' | Out-Null


If ($SMB1 -eq "False")
{
    # Disable SMB1:
    Write-Host "Disabling SMB1 Support..." -ForegroundColor Yellow
    dism /online /Disable-Feature /FeatureName:SMB1Protocol /NoRestart
    Write-Host ""
    Write-Host ""
}


If ($SMBPerf -eq "True")
{
    # SMB Modifications for performance:
    Write-Host "Changing SMB Parameters..."
    Write-Host ""
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'DisableBandwidthThrottling' -PropertyType DWORD -Value '1' | Out-Null
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'DisableLargeMtu' -PropertyType DWORD -Value '0' | Out-Null
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'FileInfoCacheEntriesMax' -PropertyType DWORD -Value '8000' | Out-Null
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'DirectoryCacheEntriesMax' -PropertyType DWORD -Value '1000' | Out-Null
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'FileNotFoundcacheEntriesMax' -PropertyType DWORD -Value '1' | Out-Null
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters' -Name 'MaxCmds' -PropertyType DWORD -Value '8000' | Out-Null
    New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' -Name 'EnableWsd' -PropertyType DWORD -Value '0' | Out-Null
}


# Remove Previous Versions:
Write-Host "Removing Previous Versions Capability..." -ForegroundColor Yellow
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SOFTWARE\\Microsoft\Windows\CurrentVersion\Explorer' -Name 'NoPreviousVersionsPage' -Value '1'


# Change Explorer Default View:
Write-Host "Configuring Windows Explorer..." -ForegroundColor Green
Write-Host ""
New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -PropertyType DWORD -Value '1' | Out-Null


# Configure Search Options:
Write-Host "Configuring Search Options..." -ForegroundColor Green
Write-Host ""
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowSearchToUseLocation' -PropertyType DWORD -Value '0' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'ConnectedSearchUseWeb' -PropertyType DWORD -Value '0' | Out-Null
New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -PropertyType DWORD -Value '1' | Out-Null


# Use Solid Background Color:
Write-Host "Configuring Winlogon..." -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'DisableLogonBackgroundImage' -Value '1'


# DisableTransparency:
Write-Host "Removing Transparency Effects..." -ForegroundColor Green
Write-Host ""
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'EnableTransparency' -Value '0'


# Configure WMI:
Write-Host "Modifying WMI Configuration..." -ForegroundColor Green
Write-Host ""
$oWMI=get-wmiobject -Namespace root -Class __ProviderHostQuotaConfiguration
$oWMI.MemoryPerHost=768*1024*1024
$oWMI.MemoryAllHosts=1536*1024*1024
$oWMI.put()
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Winmgmt -Name 'Group' -Value 'COM Infrastructure'
winmgmt /standalonehost
Write-Host ""

# NLA (Network Level Authentication)
$NLA = Get-WmiObject -Class Win32_TSGeneralSetting -Namespace root\CIMV2\TerminalServices -Authentication PacketPrivacy
$NLA.SetUserAuthenticationRequired($NLAEnable) | Out-Null
$NLA = Get-WmiObject -Class Win32_TSGeneralSetting -Namespace root\CIMV2\TerminalServices -Authentication PacketPrivacy
if ($NLA.UserAuthenticationRequired -eq $NLAEnable){
   Write-Host "NLA setting changed sucessfully" -ForegroundColor Cyan
} else {
   Write-Host "Failed to change NLA setting" -ForegroundColor Red
   exit
}
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""


# Did this break?:
If ($NoWarn -eq $False)
{
    Write-Host "The PowerShellScript has completed." -ForegroundColor Green
    Write-Host ""
    Write-Host "Please review output in your console for any indications of failures, and resolve as necessary." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Remember, this script is provided AS-IS - review the changes that it has done to this VM for validation in your environment." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Now, go do something else!(reboot required)" -ForegroundColor White
    Write-Host "Remember to visit www.ervik.as for the latest edition!(reboot required)" -ForegroundColor White
}