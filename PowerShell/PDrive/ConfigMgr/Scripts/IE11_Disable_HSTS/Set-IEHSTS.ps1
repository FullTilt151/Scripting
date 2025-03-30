$registryPath = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_DISABLE_HSTS"

    IF(!(Test-Path $registryPath)){
        
        $writable = $true
        $key = (get-item 'HKLM:\Software\Microsoft\Internet Explorer\Main').OpenSubKey("FeatureControl", $writable).CreateSubKey("FEATURE_DISABLE_HSTS")
        $key.SetValue("iexplore.exe", "1", "DWORD")

        $key = (get-item 'HKLM:\Software\Wow6432Node\Microsoft\Internet Explorer\Main').OpenSubKey("FeatureControl", $writable).CreateSubKey("FEATURE_DISABLE_HSTS")
        $key.SetValue("iexplore.exe", "1", "DWORD")

    } else {
        write-host "RegKey Exists"
    }

    IF(!(Test-Path $registryPath)){
        
        $writable = $true
        $key = (get-item 'HKLM:\Software\Microsoft\Internet Explorer\Main').OpenSubKey("FeatureControl", $writable).CreateSubKey("FEATURE_DISABLE_HSTS")
        $key.SetValue("iexplore.exe", "1", "DWORD")
    } else {
        write-host "RegKey Exists"
    }