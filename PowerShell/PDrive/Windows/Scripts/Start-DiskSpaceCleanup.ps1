param(
    [Parameter(Mandatory = $true)]
    $WKID
)
Get-WmiObject -ComputerName $WKID Win32_DiskDrive | Select-Object -ExpandProperty Size
Copy-Item \\lounaswps08\pdrive\dept907.cit\configmgr\scripts\ConfigMgrCacheClean\Remove-ConfigMgrCache.ps1 \\$wkid\c$\temp
Copy-Item \\lounaswps08\pdrive\dept907.cit\windows\scripts\Start-DiskCleanup.ps1 \\$wkid\c$\temp
Copy-Item \\lounaswps08\pdrive\dept907.cit\windows\scripts\Start-VMDiet.ps1 \\$wkid\c$\temp
Start-Process -filepath '\\lounaswps08\pdrive\Dept907.CIT\Windows\Software\Delprof2 1.6.0\DelProf2.exe' -Verb runAs -ArgumentList "/u /i /d:15 /c:\\$WKID"
Invoke-Command -ComputerName $WKID -ScriptBlock {
    c:\temp\Remove-ConfigMgrCache.ps1
    if (test-path 'c:\Program Files\1e\NomadBranch\NomadBranch.exe' -erroraction silentlycontinue) {
        & 'C:\Program Files\1E\NomadBranch\NomadBranch.exe' -ActivateAll
        & 'C:\Program Files\1e\NomadBranch\CacheCleaner.exe' -DeleteAll -Force=8
    }
    IF (Test-Path -Path 'C:\Program Files\Microsoft SQL Server') {
        $SQLKB = Get-ChildItem 'C:\Program Files\Microsoft SQL Server' -Recurse | Where-Object { $_.PSIsContainer -eq $True -and $_.Name -match 'Update Cache' } | Select-Object -ExpandProperty FullName
        Remove-Item $SQLKB\*.* -Force
    }
    if ((Get-ItemProperty C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb).Length -gt 1000000000) {
        Stop-Service 'Windows Search' -Force
        Remove-Item C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb -Force
        Start-Service 'Windows Search'
    }
    $FS = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object -ExpandProperty FreeSpace
    IF ($FS -lt 10737418240) {
        & dism /online /cleanup-image /StartComponentCleanup /ResetBase
    }
    c:\temp\Start-VMDiet.ps1
    c:\temp\Start-DiskCleanup.ps1
}
Get-WmiObject -ComputerName $WKID win32_logicaldisk -Filter "DeviceID='C:'"  -ErrorAction SilentlyContinue | ForEach-Object { "$_ $($_.DeviceID) - $( $_.Freespace/1GB)" }