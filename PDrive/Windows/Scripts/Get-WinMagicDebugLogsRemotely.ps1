$LogDir = "\\wkmj029cw9\shared\logs\WinMagic-BootLoader"

Get-Content c:\temp\wkids.txt | 
ForEach-Object {
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        $LogPath = "$LogDir\$_"
        New-Item "$LogDir\$_" -ItemType Directory -Force
        if (Test-Path "\\$_\c$\windows\temp\sdsetupsilent.log" -ErrorAction SilentlyContinue) {
            Copy-Item -Path "\\$_\c$\windows\temp\sdsetupsilent.log" -Destination $LogPath -ErrorAction SilentlyContinue
        }
        Copy-Item -Path "\\$_\c$\program files\winmagic\Securedoc-NT\userdata" -Destination $LogPath -Recurse -ErrorAction SilentlyContinue
        \\lounaswps01\pdrive\dept907.cit\windows\Scripts\Export-EventLog.ps1 -ComputerName $_ -LogName Application -Destination c:\temp\EventLog-Application.evtx
        \\lounaswps01\pdrive\dept907.cit\windows\Scripts\Export-EventLog.ps1 -ComputerName $_ -LogName System -Destination c:\temp\EventLog-System.evtx
        Copy-Item -Path "\\$_\c$\temp\EventLog-Application.evtx" -Destination $LogPath -ErrorAction SilentlyContinue
        Copy-Item -Path "\\$_\c$\temp\EventLog-System.evtx" -Destination $LogPath -ErrorAction SilentlyContinue
    }
}