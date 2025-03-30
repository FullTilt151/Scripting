Get-Content C:\temp\wkids.txt |
ForEach-Object {
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
        $ref = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\NMDS\")
        write-host $_" - MMB:"($ref.GetValue("MaximumMegaByte"))"- "($ref.GetValue("MaxAllocRequest"))

        
        if (($ref.GetValue("MaximumMegaByte")) -ne 61440) {
            $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
            $ref = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\NMDS\",$true)
            $ref.SetValue("MaximumMegaByte","61440","DWORD")
            
        }
        
        if (($ref.GetValue("MaxAllocRequest")) -ne 61440) {
            $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
            $ref = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\NMDS\",$true)
            $ref.SetValue("MaxAllocRequest","61440","DWORD")
            
        }

        
    } else {
        "$_ - Offline"
    }
}