param(
[ValidateSet('WP1','SP1','WQ1','SQ1','MT1')]
$SiteCode,
$Port = '80',
$MP
)

$Client = New-Object -ComObject Microsoft.SMS.Client
if ($SiteCode -ne $null) {
    $Client.SetAssignedSite($SiteCode)
}

If ($MP -ne $null) {
    $Client.SetCurrentManagementPoint($MP)
}

if ($Port -ne $null) {
    if ($Port -eq '80') {
        $httpportdword = '0x00000050'
        $httpsportdword = '0x000001bb'
    } elseif ($Port -eq '48018') {
        $portdword = '0x0000bb92'
        $portdword = '0x00000050'
    }
    Set-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name HTTPPort -Value $httpportdword
    Set-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name HTTPSPort -Value $httpsportdword
}

Remove-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name SMSSLP

Restart-Service CCMExec

$Client = New-Object -ComObject Microsoft.SMS.Client
$Client.GetAssignedSite()
$Client.GetCurrentManagementPoint()
(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name HTTPPort).httpport
(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ccm -Name HTTPPort).httpsport