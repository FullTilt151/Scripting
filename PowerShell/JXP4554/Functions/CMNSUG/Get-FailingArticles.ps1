$basedir = 'D:\PatchLogs'
$copyDir = 'D:\LogsToSend'
$siteServer = 'LOUAPPWPS1658'

$sccmCon = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
$sccmCS = Get-CMNConnectionString -DatabaseServer $sccmCon.SCCMDBServer -Database $sccmCon.SCCMDB

$WKIDS = Get-ChildItem -Path $basedir
foreach($WKID in $WKIDS)
{
    $file = "$basedir\$($WKID.Name)\WindowsUpdate.log"
    $WindowsUpdateLog = Get-Content -Path $file
    for($x=0;$x -lt $WindowsUpdateLog.Count;$x++)
    {
        if($WindowsUpdateLog[$x] -match 'WARNING: Failed to evaluate Installable rule')
        {
            $updateID = $WindowsUpdateLog[$x] -replace '.*= {([\w\d-]*)}.*','$1'
            $query = "select *
from v_UpdateCIs
where  CI_UniqueID = '$updateID'"
            $CIInfo = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
            if($CIInfo -ne $null){Write-Output "WKID - $WKID is failing to evaluate KB$($CIInfo.ArticleID) - $($CIInfo.BulletinID)"}
            else{Write-Output "WKID - $WKID is failing to evaluate $updateID"}
        }
    }
}