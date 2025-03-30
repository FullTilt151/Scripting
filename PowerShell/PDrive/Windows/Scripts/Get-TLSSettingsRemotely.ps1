$ErrorActionPreference = 'SilentlyContinue'
Get-Content C:\temp\wkids.txt |
ForEach-Object {
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
        $ref = $regKey.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp\")
        write-host $_" - WinHTTP:$($ref.GetValue("DefaultSecureProtocols"))"

        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
        $ref = $regKey.OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client")
        write-host $_" - TLS 1.2 Client - Enabled:$($ref.GetValue("Enabled")) DisabledByDefault: $($ref.GetValue("DisabledByDefault"))"
        
        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $_)
        $ref = $regKey.OpenSubKey("SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server")
        write-host $_" - TLS 1.2 Server - Enabled:$($ref.GetValue("Enabled")) DisabledByDefault: $($ref.GetValue("DisabledByDefault"))"
    } else {
        "$_ - Offline"
    }
}