Get-Content C:\temp\servers.txt | 
ForEach-Object {
    if (Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue) {
        $nomadlog = Get-Content \\$_\c$\windows\ccm\logs\nomadbranch.log
        #($nomadlog | Select-String "evt_StartedCopy" | Select-Object -Last 1).tostring()
        $_ + " $(($nomadlog | Select-String PkgCacheStatusSet -ErrorAction SilentlyContinue | Select-Object -Last 1 -ErrorAction SilentlyContinue).tostring().split("<")[0])"
    } else {
        $_ + " offline"
    }
}