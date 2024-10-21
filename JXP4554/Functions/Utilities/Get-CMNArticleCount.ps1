PARAM
(
    [Parameter(Mandatory = $true,
        HelpMessage = 'SiteServer to check')]
    [String]$siteServer,

    [Parameter(Mandatory = $true,
        HelpMessage = 'Replication Group to find out the number of rows in')]
    [String]$replicationGroup
)

$sccmConnection = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
$dbConnection = Get-CMNConnectionString -DatabaseServer $sccmConnection.SCCMDBServer -Database $sccmConnection.SCCMDB
$query = "SELECT ArticleName
FROM   articledata
WHERE  replicationid IN (SELECT id
                         FROM   replicationdata
                         WHERE  replicationgroup = '$replicationGroup')"

$tables = (Get-CMNDatabaseData -connectionString $dbConnection -query $query -isSQLServer).ArticleName
$total = 0

foreach($table in $tables)
{
    $query = "select count(*) [count] from $table"
    $count = (Get-CMNDatabaseData -connectionString $dbConnection -query $query -isSQLServer -timeout 600).count
    "$table has {0:N0} rows" -f $count
    $total += $count
}
"Total count = {0:N0}" -f $total