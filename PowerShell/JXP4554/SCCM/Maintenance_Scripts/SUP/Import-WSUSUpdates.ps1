Clear-Host
$logFile = 'c:\Temp\Import-WSUSUpdates.log'
$cmd = "cmtrace"
$params = ($logfile, 'C:\Temp\Optimize-CMNWSUSIndexSQL.log', 'C:\Temp\Optimize-CMNWSUSIndex.log', 'C:\Temp\Optimize-CMNWSUSCleanUp.log')
& $cmd $params
$newLogEntry = @{
    Component = 'Import-WSUSUpdates';
    logFile   = $logFile;
}
New-CMNLogEntry -entry 'Started!!!' -type 1 @newLogEntry
#$source = $PSScriptRoot
$source = 'D:\Win2K3 Patches'
$cmd = "C:\Program Files\Update Services\Tools\WsusUtil.exe"
$arg1 = 'CSAImport'
$arg3 = "$source\Payload\"
$dirs = Get-ChildItem -Path "$source\ScanCab" | Where-Object {$_.PSIsContainer -eq $true} | Sort-Object -Property Name

foreach ($dir in $dirs) {
    $files = Get-ChildItem -Path $dir.FullName
    foreach ($file in $files) {
        New-CMNLogEntry -entry 'Indexing....' -type 1 @newLogEntry
        & .\Optimize-CMNWSUSIndex.ps1
        New-CMNLogEntry -entry 'WSUS Cleanup...' -type 1 @newLogEntry
        & .\Optimize-CMNWSUSCleanUp.ps1
        $arg2 = $file.FullName
        New-CMNLogEntry -entry "Executing $cmd $arg1 $arg2 $arg3" -type 1 @newLogEntry
        & $cmd $arg1 $arg2 $arg3
        Remove-Item -Path $file.FullName -Force
    }
}
New-CMNLogEntry -entry 'Indexing....' -type 1 @newLogEntry
& .\Optimize-CMNWSUSIndex.ps1
New-CMNLogEntry -entry 'WSUS Cleanup...' -type 1 @newLogEntry
& .\Optimize-CMNWSUSCleanUp.ps1
New-CMNLogEntry -entry 'Finished!!!' -type 1 @newLogEntry