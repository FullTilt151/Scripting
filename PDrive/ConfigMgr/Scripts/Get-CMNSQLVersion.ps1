 Function Get-CMNSqlVersion
{
    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'Site Server(s) to connect to')]
        [String[]]$siteServers
    )

    foreach($siteServer in $siteServers)
    {
        $sccmCon = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
        $dbCon = Get-CMNConnectionString -DatabaseServer $sccmCon.SCCMDBServer -Database $sccmCon.SCCMDB
        $query = "SELECT compatibility_level FROM sys.databases Where name = '$($sccmCon.SCCMDB)'"
        $dbLevel = Get-CMNDatabaseData -connectionString $dbCon -query $query -isSQLServer
        "Site $($sccmCon.SiteCode) = $($dbLevel.compatibility_level)"
    }
}

$SiteServers = ('LOUAPPWPS875','LOUAPPWPS1658','LOUAPPWPS1825','LOUAPPWQS1151','LOUAPPWTS1140')
Get-CMNSqlVersion -siteServers $SiteServers  

