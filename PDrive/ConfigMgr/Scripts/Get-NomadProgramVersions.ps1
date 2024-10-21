Get-Content C:\temp\servers.txt | 
ForEach-Object {
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        $_ + " NomadBranch: " + (Get-ItemProperty "\\$_\c$\program files\1e\nomadbranch\NomadBranch.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty VersionInfo).FileVersion + " SMSTSNomad: "+ (Get-ItemProperty "\\$_\c$\program files\1e\nomadbranch\SMSTSNomad.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty VersionInfo).FileVersion
    } else {
        $_ + " offline"
    }
}