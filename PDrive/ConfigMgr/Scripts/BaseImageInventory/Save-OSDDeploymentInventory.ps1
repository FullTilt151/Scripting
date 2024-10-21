Start-Transcript -Path "c:\temp\DeploymentInventory.log"

$header = "<style> BODY{font-size:3 ;font-family:calibri;} TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;} TH{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:#0099FF} TD{border-width: 1px;padding: 2px;border-style: solid;border-color: black;background-color:lightblue} </style>"

Write-Output "`n"
write-output "--------------------------------------------------" 
write-output "Gathering Image Information" 
write-output "--------------------------------------------------" 
write-output "OSD Image Creation Date: "(Get-ItemProperty HKLM:\software\humana\OSD).ImageCreationDate
write-output "OSD Image Release: "(Get-ItemProperty HKLM:\software\humana\OSD).ImageRelease
write-output "OSD Image Name: "(Get-ItemProperty HKLM:\software\humana\OSD).ImageName
write-output "OSD Deployment Date: "(Get-ItemProperty HKLM:\software\humana\OSD).ImageInstalled
write-output "OSD Deployment User: "(Get-ItemProperty HKLM:\software\humana\OSD).DeployedBy
write-output "OSD Deployment Task Sequence: "(Get-ItemProperty HKLM:\software\humana\OSD).TaskSequence
write-output "OSD Deployment PXE: "(Get-ItemProperty HKLM:\software\humana\OSD).PXE
write-output "System Software Install Date: "(Get-ItemProperty 'HKLM:\software\humana\System Software').Install_Date
write-output "System Software OS Version: "(Get-ItemProperty 'HKLM:\software\humana\System Software').'OS Version'
Write-Output "`n"

write-output "--------------------------------------------------" 
write-output "Gathering Windows Settings" 
write-output "--------------------------------------------------" 
$tz = & tzutil /g
Write-Output "TimeZone: "$tz

$windows = Get-ItemProperty 'HKLM:\software\microsoft\Windows NT\CurrentVersion'
$os = $Windows.ProductName
write-output $windows

write-output "--------------------------------------------------" 
write-output "Verifying Admin account is enabled" 
write-output "--------------------------------------------------" 
$Computer = (gwmi Win32_ComputerSystem).Name
$admin = (Get-WmiObject -Class win32_useraccount -Filter "Domain = '$computer' and Name = 'Administrator'").disabled
if ($admin) {
    write-warning "The local administrator account is disabled!`n"
    write-output "`n"
} else {
    write-output "SUCCESS: The local administrator account is enabled.`n"
}

write-output "--------------------------------------------------" 
write-output "Verifying Admin Password" 
write-output "--------------------------------------------------" 
if ($admin -ne $true) {
    $user = "$computer\administrator"
    $Cred = Get-Credential -UserName $user -Message "Please type current release admin password"
    $Pass = $Cred.GetNetworkCredential().Password

    Add-Type -assemblyname System.DirectoryServices.AccountManagement 
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Machine)
    if ($DS.ValidateCredentials($User, $pass)) {
        write-output "SUCCESS: Current Admin Password matches what you typed!`n"
    } else {
        write-warning "Current admin password does not match!`n"
        write-output "`n"
    }
} else {
    write-warning "SKIPPING: Local administrator is not enabled!`n"
    write-output "`n"
}

write-output "--------------------------------------------------" 
write-output "Verify ConfigMgr Client version" 
write-output "--------------------------------------------------" 
$ConfigMgrClientVersion = (Get-WmiObject -Namespace root\ccm -class sms_client).ClientVersion
if ($ConfigMgrClientVersion -eq '5.00.7958.1501') {
    write-output "SUCCESS: ConfigMgr client is correct!!`n" 
} else {
    write-warning "ConfigMgr client is incorrect!"
    write-output "`n"
}

write-output "--------------------------------------------------" 
write-output "Verify hibernate is disabled" 
write-output "--------------------------------------------------" 
$hibernate = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\Power -Name HibernateEnabled | Select-Object -ExpandProperty HibernateEnabled
if ($hibernate -eq 0) {
    write-output "SUCCESS: Hibernate is disabled!`n" 
} else {
    write-warning "Hibernate is still enabled!"
    write-output "`n"
}

write-output "--------------------------------------------------" 
write-output "Verify Automatic Updates are disabled" 
write-output "--------------------------------------------------" 
$update=new-object -comobject microsoft.update.autoupdate
if ($update.settings.notificationlevel -eq 1) {
    Write-Output "SUCCESS: Automatic Updates are disabled!`n"
} else {
    write-warning "Will be moved to deployment script! Not functional in image script!"
    Write-Output "`n"
}

write-output "--------------------------------------------------" 
write-output "Verify Remote Desktop/Assistance Settings" 
write-output "--------------------------------------------------" 
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

write-output "--------------------------------------------------" 
write-output "Verify IPv6 is disabled"
write-output "--------------------------------------------------" 
$ipv6hex = (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters).DisabledComponents
$ipv6decimal = [Convert]::ToString($ipv6hex, 16)
if ($ipv6decimal -eq "ffffffff") {
    write-output "SUCCESS: IPv6 is disabled!" 
} else {
    write-warning "IPv6 is not disabled!"
}
Write-Output "`n"

write-output "--------------------------------------------------" 
write-output "Verify startup options" 
write-output "--------------------------------------------------" 
$recovery = bcdedit /enum
if (($recovery | select-string recoveryenabled) -like "recoveryenabled*no") {
    write-output "SUCCESS: Recovery is disabled!`n" 
} else {
    write-warning "Recovery is still enabled!"
    write-output "`n"
}

if (($recovery | select-string bootstatuspolicy) -like "*IgnoreAllFailures*") {
    write-output "SUCCESS: Failures ignored!`n" 
} else {
    write-warning "Failures not ignored!"
    write-output "`n"
}

write-output "--------------------------------------------------" 
write-output "Verify Legal Notice settings" 
write-output "--------------------------------------------------" 
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

write-output "--------------------------------------------------" 
write-output "Verify Crash Dump settings" 
write-output "--------------------------------------------------" 
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

write-output "--------------------------------------------------" 
write-output "Verify duplicate wow6432node" 
write-output "--------------------------------------------------" 
$reg32 = Test-Path HKLM:\SOFTWARE\wow6432node\wow6432node -ErrorAction SilentlyContinue
if ($reg32 -eq $false) {
    write-output "SUCCESS: HKLM:\SOFTWARE\wow6432node\wow6432node doesnt exist!`n" 
} else {
    write-warning "HKLM:\SOFTWARE\wow6432node\wow6432node does exist!`n"
    write-output "`n"
}

write-output "--------------------------------------------------" 
write-output "Verify IE Version and patch level" 
write-output "--------------------------------------------------" 
$ie = ((Get-ItemProperty 'C:\Program Files\Internet Explorer\iexplore.exe').VersionInfo).fileversion
if ($ie -like "9*" -and $os -eq "Windows 7 Enterprise") {
    write-output "SUCCESS: IE version is $ie`n" 
} elseif ($ie -like "11*" -and $os -eq "Windows 8.1 Enterprise") {
    write-output "SUCCESS: IE version is $ie`n" 
} else {
    write-warning "IE version is incorrect!`n"
    write-output "`n"
}

$ieversion = (Get-ItemProperty 'HKLM:\software\microsoft\Internet Explorer' -Name svcUpdateVersion).svcUpdateVersion
Write-Output "IE Patch Level: $ieversion"
if ($ieversion -ge "9.0.28" -and $os -eq "Windows 7 Enterprise") {
    write-output "SUCCESS: IE patch level is greater than 9.0.28`n" 
} elseif ($ieversion -ge "11.0.10" -and $os -eq "Windows 8.1 Enterprise") {
    write-output "SUCCESS: IE patch level is greater than 11.0.10`n" 
} else {
    write-warning "IE patch level is incorrect!!`n"
    write-output "`n"
}

if ($os -eq "Windows 8.1 Enterprise") {
    write-output "--------------------------------------------------" 
    write-output "Verify .NET 3.5 is enabled"
    write-output "--------------------------------------------------" 
    $dotnet = Get-WindowsOptionalFeature -online -FeatureName NetFx3 | Select-Object -ExpandProperty State
    if ($dotnet -eq "Enabled") {
        write-output "SUCCESS: .NET 3.5 is enabled!`n" 
    } else {
        write-warning ".NET 3.5 is not enabled!!`n"
        write-output "`n"
    }
}

if ($os -eq "Windows 7 Enterprise") {
    write-output "--------------------------------------------------" 
    write-output "Verify IE recommended settings wizard is disabled" 
    write-output "--------------------------------------------------"
    $iewizard = (Get-ItemProperty 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main').DisableFirstRunCustomize
    if ($iewizard -eq "1") {
        write-output "SUCCESS: IE recommended settings wizard is disabled!`n" 
    } else {
        write-warning "IE recommended settings wizard is not disabled`n"
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

write-output "--------------------------------------------------" 
write-output "Verifying Teredo tunneling adapter is removed"
write-output "--------------------------------------------------" 

$ipv6device = Get-WmiObject -Namespace root\cimv2 -class win32_pnpsigneddriver | where {$_.DeviceName -eq 'Microsoft Teredo Tunneling Adapter'}

if ($ipv6device -eq $null) {
    write-output "SUCCESS: IPv6 adapter is not present!`n" 
} else {
    write-warning "IPv6 adapter is present!`n"
}

write-output "--------------------------------------------------" 
write-output "Verify McAfee AgentGUID and ComputerName"
write-output "--------------------------------------------------" 
$mcafeeguid = (Get-ItemProperty 'HKLM:\software\wow6432node\Network Associates\ePolicy Orchestrator\Agent').AgentGUID
if ($mcafeeguid -eq "") {
    write-output "SUCCESS: McAfee AgentGUID has been removed!" 
} else {
    write-warning "McAfee AgentGUID exists!"
}
Write-Output "`n"

$mcafeewkid = (Get-ItemProperty 'HKLM:\software\wow6432node\Network Associates\ePolicy Orchestrator\Agent').ComputerName
if ($mcafeewkid -eq "") {
    write-output "SUCCESS: McAfee ComputerName has been removed!`n" 
} else {
    write-warning "McAfee ComputerName exists!`n"
    write-output "`n"
}

Stop-Transcript