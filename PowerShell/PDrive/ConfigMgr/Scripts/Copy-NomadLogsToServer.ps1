Get-ChildItem \\lounaswps01\pdrive\dept907.cit\osd\logs\ | Sort-Object LastWriteTime -Descending | Select-Object -First 50 |
ForEach-Object {
    if (Test-Connection $_.Name -Count 1 -ErrorAction SilentlyContinue) {
        $_.Name
        $path = $_.FullName
        Get-ChildItem -Path \\$_\c$\windows\ccm\logs\ -Filter "*NomadBranch*" -ErrorAction SilentlyContinue | 
        ForEach-Object {
            $path | out-file c:\temp\NomadLogs.txt
            Copy-Item -Path $_.FullName -Destination $path
        }
        E:\scripts\sccm\Calc-NomadCopyTimes.ps1 -FolderPath $_.FullName
    } else {
        "$_ offline"
    }
}