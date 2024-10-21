Get-ChildItem -Path '\\lounaswps01\pdrive\dept907.cit\osd\logs' -Filter 'smsts*.log' -Recurse | Sort-Object LastWriteTime -Descending |
ForEach-Object {
    $ErrorActionPreference = 'SilentlyContinue'
    $ip = (Get-Content $_.FullName | Select-String 'Found network adapter*' | Select-Object -First 1).tostring()
    #$ip
    if ($ip -like '*32.32.9*') {
        $wkid = $_.FullName.Split('\')[7]
        $path = "\\lounaswps01\pdrive\dept907.cit\logs\$wkid"
        $localpath = "$wkid\c$\windows\ccm\logs"
        if (Get-ChildItem $path -Filter "*NomadBranch*.log") {
            "Nomad files found on P:\..."
            E:\scripts\sccm\Calc-NomadCopyTimes.ps1 -FolderPath $path
            "Creating report in $path"
        } else {
            if (Test-Connection $wkid -Count 1 -ErrorAction SilentlyContinue) {
                "Copying from local machine..."
                Copy-Item -Path "\\$wkid\c$\windows\ccm\logs\*NomadBranch*" -Destination $path -Recurse
                E:\scripts\sccm\Calc-NomadCopyTimes.ps1 -FolderPath $path
                "Creating report in $path"
            }
        }
    }
}