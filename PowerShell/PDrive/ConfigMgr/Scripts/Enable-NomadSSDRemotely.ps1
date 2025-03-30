Get-Content C:\temp\wkids.txt |
ForEach-Object {
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
        $ref = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\")
        $refAE = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\ActiveEfficiency")
        write-host $_" - PlatformURL:"($refAE.GetValue("PlatformURL"))"- SSDEnabled:"($ref.GetValue("SSDEnabled"))"- ContentRegistration:"($refAE.GetValue("ContentRegistration"))
        <#
        if (($refAE.GetValue("PlatformURL")) -ne 'http://activeefficiency.humana.com/activeefficiency') {
            $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
            $refAE = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\ActiveEfficiency",$true)
            $refAE.SetValue("PlatformURL","http://activeefficiency.humana.com/activeefficiency","String")
        }
        #>
        if (($ref.GetValue("SSDEnabled")) -ne 3) {
            $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
            $ref = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\",$true)
            $ref.SetValue("SSDEnabled","3","DWORD")
        }
        <#
        if (($refAE.GetValue("ContentRegistration")) -ne 1) {
            $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
            $refAE = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\ActiveEfficiency",$true)
            $refAE.SetValue("ContentRegistration","1","DWORD")
        }
        Get-Service NomadBranch -ComputerName $_ | Restart-Service -Force
        #>
    } else {
        "$_ - Offline"
    }
}