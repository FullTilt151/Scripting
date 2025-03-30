$comps = get-content c:\temp\wkids1.txt

foreach ($wkid in $comps) {
    if (Test-Connection $wkid -Count 1 -ErrorAction SilentlyContinue) {
        Write-Host "`n$wkid is online"
        
        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $wkid)
        $ref = $regKey.OpenSubKey("SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl",$true)
        $ref.CreateSubKey("FEATURE_DISABLE_HSTS")
        
        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $wkid)
        $ref = $regKey.OpenSubKey("SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_HSTS",$true)
        $ref.SetValue("iexplore.exe","1","DWORD")
        $ref.GetValue("iexplore.exe")
        
        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $wkid)
        $ref = $regKey.OpenSubKey("SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl",$true)
        $ref.CreateSubKey("FEATURE_DISABLE_HSTS")
        
        $regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $wkid)
        $ref = $regKey.OpenSubKey("SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_HSTS",$true)
        $ref.SetValue("iexplore.exe","1","DWORD")
        $ref.GetValue("iexplore.exe")

    } else {
        write-host "`n$wkid is offline"
    }
}