param(
[Parameter(Mandatory=$true)]
[ValidateSet('LOUVRIWPS01:29522,LOUVRIWPS02:29522','SIMVRIWPS01:29522,SIMVRIWPS02:29522','GRBVRIWPS01:29522,GRBVRIWPS02:29522','LOUVRIWPS05:29522,LOUVRIWPS06:29522','PURVRCWPS01:29522,APAVRCWPS01:29522','SIMVRCWPS11:29522, SIMVRCWPS122:29522')]
[string]$Server
)

$wkid = Read-Host -Prompt "Enter Workstation ID"

#$server = Read-Host -Prompt "Enter server"

$RemoteReg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$wkid)
$NewKey = $RemoteReg.OpenSubKey("SOFTWARE\Wow6432Node\Witness Systems\eQuality Agent\Capture\CurrentVersion\",$true)

if ($newkey -ne $null){
    $NewKey.SetValue("IntegrationServicesServersList", $server)
} else {
    Write-Output 'IntegrationServicesServersList does not exist'
}