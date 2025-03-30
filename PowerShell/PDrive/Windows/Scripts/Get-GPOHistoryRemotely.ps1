param(
$ComputerName
)

$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
$ref = $regKey.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History\")
$ref.GetSubKeyNames() |
ForEach-Object {
    $Subkey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History\$_\0"
    $regkeysub = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ComputerName)
    $refsub = $regKeysub.OpenSubKey($Subkey)
    "$($refsub.GetValue("Link")) - $($refsub.GetValue("DisplayName"))"
}