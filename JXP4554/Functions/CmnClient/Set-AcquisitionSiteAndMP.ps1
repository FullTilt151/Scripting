param
(
[Parameter(Mandatory=$false)]
$SiteCode = 'WP1',

[Parameter(Mandatory=$false)]
$mp = 'LOUAPPWPS1642.rsc.humad.com',

$port = '80'
)

if ($port -eq '80') {
    $httpportdword = '0x00000050'
    $httpsportdword = '0x000001bb'
    $smsslp = 'LOUAPPWPS1620.RSC.HUMAD.COM'
} elseif ($port -eq '48018') {
    $portdword = '0x0000bb92'
    $portdword = '0x00000050'
}

$Client = New-Object -ComObject Microsoft.SMS.Client
$Client.SetAssignedSite($SiteCode)
$Client.SetCurrentManagementPoint($mp)
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name HTTPPort -Value $httpportdword
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name HTTPSPort -Value $httpsportdword
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name SMSSLP -Value $smsslp

Restart-Service CCMExec

$Client = New-Object -ComObject Microsoft.SMS.Client
$Client.GetAssignedSite()
$Client.GetCurrentManagementPoint()
(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name HTTPPort).httpport
(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name HTTPPort).httpsport
(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name HTTPPort).smsslp