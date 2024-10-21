$comps = Get-Content E:\comps.txt

foreach ($remotecomputer in $comps) {
    $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $remoteComputer)
    $ref = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\")
    write-host $remoteComputer" -"($ref.GetValue("LocalCachePath"))
}