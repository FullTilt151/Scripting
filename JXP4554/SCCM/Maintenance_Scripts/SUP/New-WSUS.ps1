<#
UpdateServices
UpdateServices-Services
UpdateServices-DB
UpdateServices-RSAT
UpdateServices-API
UpdateServices-UI

SP1
GRBAPPWPS12 - WID
LOUAPPWPS1740,1741,1821,1822 - LOUSQLWPS618 \\LOUAPPWPS1740.rsc.humad.com\WSUS

WP1
LOUAPPWPS1642-45 - LOUSQLWPS606 \\LOUAPPWPS1642.rsc.humad.com\WSUS
LOUAPPWPS1646-49 - LOUSQLWPS601 \\LOUAPPWPS1646.rsc.humad.com\WSUS
LOUAPPWPS1653-56 - LOUSQLWPS602 \\LOUAPPWPS1653.rsc.humad.com\WSUS
#>

Switch -Regex ($env:COMPUTERNAME) {
    'GRBAPPWPS12' {
        $sqlserver = 'localhost'
        $contentDir = 'D:\WSUS'
    }
    'LOUAPPWPS1405' {
        $sqlserver = 'localhost'
        $contentDir = 'D:\WSUS'
    }
    'LOUAPPWTS115[012]' {
        $sqlserver = 'LOUSQLWTS553'
        $contentDir = '\\LOUAPPWTS1150.rsc.humad.com\WSUS'
    }
    'LOUAPPWPS174[01]' {
        $sqlserver = 'LOUSQLWPS618'
        $contentDir = '\\LOUAPPWPS1740.rsc.humad.com\WSUS'
    }
    'LOUAPPWPS182[12]' {
        $sqlserver = 'LOUSQLWPS618'
        $contentDir = '\\LOUAPPWPS1740.rsc.humad.com\WSUS'
    }
    'LOUAPPWPS164[2-5]' {
        $sqlserver = 'LOUSQLWPS618'
        $contentDir = '\\LOUAPPWPS1642.rsc.humad.com\WSUS'
    }
    'LOUAPPWPS164[6-9]' {
        $sqlserver = 'LOUSQLWPS601'
        $contentDir = '\\LOUAPPWPS1646.rsc.humad.com\WSUS'
    }
    'LOUAPPWPS165[3-7]' {
        $sqlserver = 'LOUSQLWPS602'
        $contentDir = '\\LOUAPPWPS1653.rsc.humad.com\WSUS'
    }
    default {
        Write-Output 'This is not a SCCM Server'
        throw 'This is not a SCCM Server'
    }
}

if ($sqlserver -eq 'localhost') {$params = ('postinstall', "CONTENT_DIR=`"$contentDir`"")}
else {$params = ('postinstall', "SQL_INSTANCE_NAME=$sqlserver", "CONTENT_DIR=`"$contentDir`"")}
Write-Output $params
if (!(Test-Path 'D:\WSUS' -PathType Container)) {
    Write-Output 'Creating D:\WSUS directory'
    New-Item -Path 'D:\WSUS' -ItemType Container
}

if ($env:COMPUTERNAME -in 'LOUAPPWTS1150', 'LOUAPPWPS1642', 'LOUAPPWTS1646', 'LOUAPPWTS1653', 'LOUAPPWPS1740') {
    if ((Get-SmbShare -Name 'WSUS' -ErrorAction SilentlyContinue).Name -ne 'WSUS' -and $env:COMPUTERNAME -in ('LOUAPPWTS1150', 'LOUAPPWPS1642', 'LOUAPPWPS1646', 'LOUAPPWPS1740', 'LOUAPPWPS1653')) {
        Write-Output 'Creating share'
        New-SmbShare -Name 'WSUS' -Path 'D:\WSUS' -FullAccess 'Everyone'
    }
}

Write-Output 'Installing WSUS features'
if ($sqlserver -eq 'localhost') {Install-WindowsFeature -Name UpdateServices-Services, UpdateServices-WidDB -IncludeManagementTools}
else {Install-WindowsFeature -Name UpdateServices-Services, UpdateServices-DB -IncludeManagementTools}

Write-Output 'Sleeping two minutes'
Start-Sleep -Seconds 120

$cmd = 'C:\Program Files\Update Services\Tools\wsusutil.exe'
Write-Output "Executing $cmd $params"
& $cmd $params