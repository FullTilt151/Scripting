$file = Get-Content c:\users\txt.txt

foreach ($computer in $file) {
    if (Test-Connection $computer -Count 1 -ErrorAction SilentlyContinue) {
        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
        $RegKey= $Reg.OpenSubKey("SOFTWARE\\VDG")
        $version = $RegKey.GetValue("Agent Version")   
        Write-host $computer" - "$version | Out-File c:\temp\txt1.txt
    } else {
        Write-warning "$computer is offline!"
    }
}