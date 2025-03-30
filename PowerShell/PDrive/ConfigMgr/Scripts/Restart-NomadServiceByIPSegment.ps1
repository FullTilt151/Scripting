for($i=5; $i -le 254; $i++) {
    $ip = "32.32.91.$i"
    if (Test-Connection -ComputerName $ip -Count 1 -ErrorAction SilentlyContinue) {
        "$ip is online"
        if (Get-Service NomadBranch -ComputerName $ip -ErrorAction SilentlyContinue) {
            #"$ip has Nomad"
            $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
            $ref = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\")
            write-host $_" - SpecialNetShare:"($ref.GetValue("SpecialNetShare"))"- P2P:"($ref.GetValue("P2PEnabled"))"- Compat:"($ref.GetValue("CompatibilityFlags"))
        
            if (($ref.GetValue("SpecialNetShare")) -ne 8256) {
                $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
                $ref = $regKey.OpenSubKey("SOFTWARE\1e\NomadBranch\",$true)
                $ref.SetValue("SpecialNetShare","8256","DWORD")
                Get-Service NomadBranch -ComputerName $_ | Restart-Service -Force
            }
            #Get-Service NomadBranch -ComputerName $ip -ErrorAction SilentlyContinue | Restart-Service
        } else {
            "$ip doesn't have Nomad"
        }
    } else {
        "$ip is not online"
    }
}