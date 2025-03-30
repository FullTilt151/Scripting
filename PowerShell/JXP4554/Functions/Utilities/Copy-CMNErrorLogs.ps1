$basedir = 'D:\PatchLogs'
$copyDir = 'D:\LogsToSend'

$WKIDS = Get-ChildItem -Path $basedir
foreach($WKID in $WKIDS)
{
    $hasError = $false
    $file = "$basedir\$($WKID.Name)\WindowsUpdate.log"
    $WindowsUpdateLog = Get-Content -Path $file
    for($x=0;$x -lt $WindowsUpdateLog.Count;$x++)
    {
        if($WindowsUpdateLog[$x] -match 'WARNING: Failed to evaluate Installable rule')
        {
            $destFile = "$copyDir\$($WKID.Name) - WindowsUpdate.log"
            Copy-Item -Path $file -Destination $destFile -Force
            $hasError = $true
            break
        }
    }
    if($hasError){Write-Output $WKID.Name}
}