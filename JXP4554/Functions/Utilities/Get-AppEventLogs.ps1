$siteServer = 'LOUAPPWPS1658'
$databaseServer = 'LOUSQLWTS553'
$database = 'RCA'
$collectionID = 'WP1000CC'
$scriptStart = Get-Date
Write-Output "Starting - $scriptStart"
$sccmCon = Get-CMNSCCMConnectionInfo -SiteServer $siteServer
$sccmCS = Get-CMNConnectionString -DatabaseServer $sccmCon.SCCMDBServer -Database $sccmCon.SCCMDB
$dbCS = Get-CMNConnectionString -DatabaseServer $databaseServer -Database $database

$query = "SELECT SYS.netbios_name0
    FROM   v_r_system SYS
            JOIN v_fullcollectionmembership FCS
                ON SYS.resourceid = FCS.resourceid
                AND FCS.collectionid = '$collectionID'
    ORDER  BY SYS.netbios_name0"

$wkids = Get-CMNDatabaseData -connectionString $sccmCS -query $query -isSQLServer
foreach($wkid in $wkids.Netbios_Name0)
{
    Write-Output "Checking $wkid"
    #$AppLogs = get-eventlog -LogName Application -ComputerName $wkid -After '1/10/2017' -Before '1/12/2017'
    #$AppLogs = Get-WinEvent -ListProvider "MOVE AV Client" -ComputerName $wkid 
    $AppLogs = Get-WinEvent -LogName Application -ComputerName $wkid -ErrorAction SilentlyContinue -MaxEvents 1500
    Write-Output 'Checking for any appropriate entries'
    foreach($AppLog in $AppLogs)
    {
        if($AppLog.ProviderName -match 'MOVE')
        {
            $utcDate = (Get-Date $AppLog.TimeCreated).ToUniversalTime()
            if($utcDate -gt (Get-Date '1/10/2017') -and $utcDate -lt (Get-Date '1/12/2017'))
            {
                $entry = ConvertTo-CMNSingleQuotedString -text $AppLog.Message
                $query = "insert Entries (WKID, Entry, UTCDateTime, Component, Context, Type, Source)
                            values (N'$wkid',N'$entry', '$utcDate', N'$($AppLog.Source)',N'$context','$type',N'Application Log')"
                Invoke-CMNDatabaseQuery -connectionString $dbCS -query $query -isSQLServer
                $query
            }
        }
    }
    Write-Output 'Cleanup'
    Remove-Variable AppLog -ErrorAction SilentlyContinue
    Remove-Variable AppLogs -ErrorAction SilentlyContinue
}
