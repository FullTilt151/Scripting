function checkWindowsVersion {
    PARAM($computer)
    if (Test-Connection $computer -Count 1 -ErrorAction SilentlyContinue) {
        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
        $RegKey = $Reg.OpenSubKey("SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion")
        $windowsVersion = $RegKey.GetValue("ReleaseID")
        $RegKey = $Reg.OpenSubKey("SOFTWARE\\1E\\NomadBranch")
        $nomadVersion = $RegKey.GetValue("ProductVersion")
        $cachePath = $RegKey.GetValue("LocalCachePath")
        $packageExists = Test-Path -Path "$($cachePath)$($package)_cache" -PathType Container
        $lszExists = Test-Path -Path "$($cachePath)$($file)" -PathType Leaf
        $returnHashTable = @{
            WindowsVersion = $windowsVersion;
            NomadVersion = $nomadVersion;
            PackageExists = $packageExists;
            lszExists = $lszExists;
        }
        Return $returnHashTable
    }
}

#Variables
$computer = $env:COMPUTERNAME
$file = "WP10033F_3.LsZ"
$package = "WP10033F"

checkWindowsVersion $computer