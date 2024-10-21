$OSDBranding = (Get-ItemProperty HKLM:\software\humana\OSD)
$windows = Get-ItemProperty 'HKLM:\software\microsoft\Windows NT\CurrentVersion'

Start-Transcript -Path "c:\temp\BaseImageInventory_$($OSDBranding.imagename)_$($windows.ReleaseId)_$($OSDBranding.ImageRelease).log"

$header = "<style> BODY{font-size:3 ;font-family:calibri;} TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;} TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:#0099FF} TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:lightblue} </style>"

Write-Output "`n"
write-output "OSD Image Name: $($OSDBranding.ImageName)"
write-output "OSD Image Release: $($OSDBranding.ImageRelease)"
write-output "OSD Image Creation Date: $($OSDBranding.ImageCreationDate)"

$os = $Windows.ProductName
Write-Output $windows

if (test-path c:\temp) {
    write-output "c:\temp exists!`n" 
} else {
    write-warning "c:\temp does not exist!`n"
    write-output "`n"
}

if (Test-Path C:\windows\ccm\CcmExec.exe) {
    $ConfigMgrClientVersion = (Get-WmiObject -Namespace root\ccm -class sms_client -ErrorAction SilentlyContinue).ClientVersion
    Write-Output "ConfigMgr client: $ConfigMgrClientVersion"
}

$cmtracever = (Get-ItemProperty C:\windows\system32\CMTrace.exe).VersionInfo.FileVersion
Write-Output "CMTrace.exe version: $cmtracever!" 

$wua = (Get-ItemProperty C:\windows\system32\wuaueng.dll).VersionInfo.ProductVersion
Write-Output "Windows Update Agent: $wua"

$rdpversion = (Get-ItemProperty c:\windows\system32\mstsc.exe | Select-Object -ExpandProperty VersionInfo).FileVersion
Write-Output "Remote Desktop version: $rdpversion" 

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | out-null
if (Test-Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{C2FBB631-2971-11D1-A18C-00C04FD75D13}") {
    Write-Output "SUCCESS: MoveTo key exists!`n" 
} else {
    Write-Warning "MoveTo key does not exist!`n"
}

if (Test-Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\{C2FBB630-2971-11D1-A18C-00C04FD75D13}") {
    Write-Output "SUCCESS: CopyTo key exists!`n" 
} else {
    Write-Warning "CopyTo key does not exist!`n"
}

$rdp = (Get-ItemProperty 'HKLM:\system\CurrentControlSet\Control\Terminal Server').fdenytsconnections
$ra = (get-itemproperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance').fallowtogethelp
if ($rdp -eq 0) {
    write-output "SUCCESS: Remote Desktop is enabled and configured without NLA!`n" 
} else {
    write-warning "Remote Desktop is not configured correctly!`n"
    write-output "`n"
}

if ($ra -eq 0) {
    write-output "SUCCESS: Remote Assistance is disabled!`n" 
} else {
    write-warning "Remote Assistance is still enabled!`n"
    write-output "`n"
}

$uac = (get-itemproperty "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System").EnableLUA
Write-Output "User Account Control: $uac"

$copylogs = Test-Path c:\windows\system32\CopyLogs.bat
if ($copylogs) {
    Write-Output "SUCCESS: CopyLogs.bat exists!`n"
} else {
    Write-Warning "CopyLogs.bat does not exist!"
    Write-Output "`n"
}

$msdia = Test-Path 'c:\msdia80.dll'
if (!$msdia) {
    Write-Output "SUCCESS: msdia80.dll does not exist on root of C:\!`n"
} else {
    Write-Warning "msdia80.dll exists at root of c:\!"
    Write-Output "`n"
}

$mailkey = Get-ItemProperty HKLM:\software\clients\Mail
$mailclient = $mailkey.'(Default)'
if ($mailclient -eq "Microsoft Outlook") {
    Write-Output "SUCCESS: Microsoft Outlook is default mail client!"
} else {
    Write-Warning "Microsoft Outlook is NOT default mail client!"
}

$iewizard = (Get-ItemProperty 'HKLM:\software\policies\Microsoft\Internet Explorer\Main').DisableFirstRunCustomize
if ($iewizard -eq 1) {
    Write-Output "SUCCESS: IE Wizard is disabled!"
} else {
    Write-Warning "IE Wizard is NOT disabled!"
}

$games = test-path "c:\ProgramData\Microsoft\Windows\Start Menu\Programs\Games"
if ($games -eq $false) {
    write-output "SUCCESS: Games have been removed!`n" 
} else {
    write-warning "Games have not been removed!`n"
    write-output "`n"
}

$ipv6hex = (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters).DisabledComponents
$ipv6decimal = [Convert]::ToString($ipv6hex, 16)
if ($ipv6decimal -eq "ff") {
    write-output "SUCCESS: IPv6 is disabled! $ipv6decimal" 
} else {
    write-warning "IPv6 is not disabled! $ipv6decimal"
}

$CAD = (Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System').DisableCAD
$LegalNoticeText = (Get-ItemProperty "HKLM:\software\microsoft\windows nt\currentversion\winlogon").LegalNoticeText
$LegalNoticeCaption = (Get-ItemProperty "HKLM:\software\microsoft\windows nt\currentversion\winlogon").LegalNoticeCaption
$LegalNoticeTextValue = 'This is a private system; only authorized users may log in, and your access and use may be monitored.  Because your appropriate access and use is expected, any unauthorized access or use may result in disciplinary action, up to and including termination and/or criminal or civil prosecution under applicable laws.                                                                                                                                                                                                                ATTENTION Outlook Users:  Information you transmit within the company-owned e-mail information system is intended only for the person or entity to which it is addressed and may contain CONFIDENTIAL material.  If you receive any information/material in error, please contact the sender and delete and/or destroy the material/information.'

if ($CAD -eq 0 -and $LegalNoticeCaption -eq "Humana System Security Statement" -and $LegalNoticeText -eq $LegalNoticeTextValue) {
    write-output "SUCCESS: Legal Notice settings are correct!`n" 
} else {
    write-warning "Legal Notice settings are incorrect!"
    write-output "`n"
}

$CrashDump = (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl).CrashDumpEnabled
$CrashLogEvent = (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl).LogEvent

if ($CrashDump -eq "2") {
    write-output "SUCCESS: Crash Dump is enabled!`n" 
} else {
    write-warning "Crash Dump is not enabled!"
    write-output "`n"
}
if ($CrashLogEvent -eq "1") {
    write-output "SUCCESS: Kernel memory dump is enabled!`n" 
} else {
    write-warning "Kernel memory dump is not enabled!"
    write-output "`n"
}

$reg32 = Test-Path HKLM:\SOFTWARE\wow6432node\wow6432node -ErrorAction SilentlyContinue
if ($reg32 -eq $false) {
    write-output "SUCCESS: HKLM:\SOFTWARE\wow6432node\wow6432node doesnt exist!`n" 
} else {
    write-warning "HKLM:\SOFTWARE\wow6432node\wow6432node does exist!`n"
    write-output "`n"
}

$teredo = Get-WmiObject -Class win32_NetworkAdapter -Filter "Name = 'Microsoft Teredo Tunneling Adapter'"
if ($teredo -eq $null) {
    write-output "SUCCESS: Microsoft Teredo Tunneling Adapter does not exist! `n" 
} else {
    write-warning "Microsoft Teredo Tunneling adapter exists!`n"
    write-output "`n"
}

$ie = ((Get-ItemProperty 'C:\Program Files\Internet Explorer\iexplore.exe').VersionInfo).fileversion
write-output "IE version is $ie`n" 

$ieversion = (Get-ItemProperty 'HKLM:\software\microsoft\Internet Explorer' -Name svcUpdateVersion).svcUpdateVersion
Write-Output "IE Patch Level: $ieversion"

$dotnet = Get-WindowsOptionalFeature -online -FeatureName NetFx3 | Select-Object -ExpandProperty State
if ($dotnet -eq "Enabled") {
    write-output "SUCCESS: .NET 3.5 is enabled!`n" 
} else {
    write-warning ".NET 3.5 is not enabled!!`n"
    write-output "`n"
}

if ($os -eq "Windows 7 Enterprise") {
    write-output "--------------------------------------------------" 
    write-output "Verify KMDF 1.11"
    write-output "--------------------------------------------------" 
    $kmdf = Get-CimInstance -Namespace root\ccm\softwareupdates\updatesstore -ClassName CCM_UpdateStatus -filter "Article = '2685811'" | Select-Object Status,Article,Title -Unique | Sort-Object Article | Format-Table -AutoSize
    $kmdf
    if ($kmdf -ne $null) {
        write-output "SUCCESS: KMDF 1.11 is installed`n" 
    } else {
        write-warning "KMDF 1.11 is not installed!`n"
        write-output "`n"
    }
}

if ($os -eq "Windows 7 Enterprise") {
    write-output "--------------------------------------------------" 
    write-output "Verify UMDF 1.11"
    write-output "--------------------------------------------------" 
    $umdf = Get-CimInstance -Namespace root\ccm\softwareupdates\updatesstore -ClassName CCM_UpdateStatus -filter "Article = '2685813'" | Select-Object Status,Article,Title -Unique | Sort-Object Article | Format-Table -AutoSize
    $umdf
    if ($umdf -ne $null) {
        write-output "SUCCESS: UMDF 1.11 is installed`n" 
    } else {
        write-warning "UMDF 1.11 is not installed!`n"
        write-output "`n"
    }
}

if ($os -eq "Windows 7 Enterprise") {
    write-output "--------------------------------------------------" 
    write-output "Verify Cumulative Update Hotfix - KB2775511" 
    write-output "--------------------------------------------------" 
    $cuhotfix = Get-CimInstance -Namespace root\ccm\softwareupdates\updatesstore -ClassName CCM_UpdateStatus -filter "Article = '2775511'" | Select-Object Status,Article,Title -Unique | Sort-Object Article | Format-Table -AutoSize
    $cuhotfix
    if ($cuhotfix -ne $null) {
        write-output "SUCCESS: KB2775511 is installed`n" 
    } else {
        write-warning "KB2775511 is not installed!`n"
        write-output "`n"
    }
}

$Software = Get-Package | Sort-Object Name, Version | Format-Table Name, Version -AutoSize
$Software
Write-Output "Total software: $($software.count)"
#$programs = Get-WmiObject -Namespace root\cimv2\sms -Class sms_installedsoftware -ErrorAction SilentlyContinue | Sort-Object ProductName | Format-Table ProductName,ProductVersion -AutoSize
#$programs
#write-output "Total programs: "$programs.count 
#write-output "`n"

#$hotfix = Get-CimInstance -Namespace root\ccm\softwareupdates\updatesstore -ClassName CCM_UpdateStatus -filter "Status = 'Installed'" -ErrorAction SilentlyContinue | Select-Object Status,Article,Bulletin,Title -Unique | Sort-Object Article | Format-Table -AutoSize
#$hotfix = Get-HotFix
#$hotfix
#write-output "Total hotfixes: "$hotfix.count 
#write-output "`n"

<#
write-output "--------------------------------------------------" 
write-output "Gathering installed non-Microsoft patches" 
write-output "--------------------------------------------------" 
write-warning "Not functional at this time!"
write-output "`n"
#>

Stop-Transcript