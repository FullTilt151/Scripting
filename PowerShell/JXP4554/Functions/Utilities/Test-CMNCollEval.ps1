[cmdletBinding(ConfirmImpact = 'Low')]
PARAM(
    [Parameter(Mandatory = $true, HelpMessage = 'Site Server Connection info')]
    [psobject]$sccmConnectionInfo,

    [Parameter(Mandatory = $false, HelpMessage = 'Show Notification Table Count')]
    [switch]$showNotificationTableCount,

    [Parameter(Mandatory = $false, HelpMessage = 'Show Blocking Info')]
    [switch]$showBlockingInfo,

    [Parameter(Mandatory = $false, HelpMessage = 'Kill blocking Spids')]
    [Switch]$killSpids
)

$dbConnectionString = Get-CMNConnectionString -DatabaseServer $sccmConnectionInfo.SCCMDBServer -Database $sccmConnectionInfo.SCCMDB

$collectionNotificationsQuery = 'Select count(*) [Count] from CollectionNotifications' #Get the count of notifications
$statusCountQuery = "SELECT Count(*) [Count],
CASE CurrentStatus
    WHEN 0
        THEN 'None'
    WHEN 1
        THEN 'Ready'
    WHEN 2
        THEN 'Refreshing'
    WHEN 3
        THEN 'Saving'
    WHEN 4
        THEN 'Evaluating'
    WHEN 5
        THEN 'Awaiting Refresh'
    WHEN 6
        THEN 'Deleting'
    WHEN 7
        THEN 'Appending Member'
    WHEN 8
        THEN 'Querying'
    END AS CurrentSTATUS
FROM V_collection
GROUP BY CurrentStatus" #Get Status Counts
$notificationTablesQuery = "SELECT tablename,
count(*) [Count]
FROM CollectionNotifications
GROUP BY tableName
ORDER BY count(*) DESC"
$divider = "$('-' * 80)"
$returnHashTable = @{}

#Start gathering information
$message += "`r`nStarting $(Get-Date)"

$collectionNotificationCount = (Get-CMNDatabaseData -connectionString $dbConnectionString -query $collectionNotificationsQuery -isSQLServer).Count
$message += "`r`nCollection Notification table has {0:n0} rows.`r`n" -f $collectionNotificationCount

$statusCount = Get-CMNDatabaseData -connectionString $dbConnectionString -query $statusCountQuery -isSQLServer
$message += "`r`n$divider"
$message += "`r`nStatus Counts:`r`n"
foreach ($item in $statusCount) {
    $message += "{0,-10:n0} {1}`r`n" -f $item.Count, $item.CurrentSTATUS
}

if ($PSBoundParameters['showNotificationTableCount']) {
    $notificationTablesCount = Get-CMNDatabaseData -connectionString $dbConnectionString -query $notificationTablesQuery -isSQLServer
    $message = "`r`n$divider"
    $message += "`r`nNotification Table Counts"
    foreach ($item in $notificationTablesCount) {
        $message += "`r`n{0,-10:n0} {1}" -f $item.Count, $item.tablename
    }
    $message += "`r`n"
}

if ($PSBoundParameters['showBlockingInfo']) {
    $message += "`r`n$divider`r`n"
    $message += "Blocking Information`r`n"
    $blockingHT = @{}
    $query = 'exec sp_who2'
    $spwho2s = Get-CMNDatabaseData -connectionString $dbConnectionString -query $query -isSQLServer
    foreach ($spwho2 in $spwho2s) {
        if ($spwho2.BlkBy -notmatch '\.') {
            if (-not($blockingHT.ContainsKey($spwho2.SPID))) {
                $blockingHT.Add($spwho2.SPID, $spwho2.BlkBy)
                $message += "`r`nSPID:$($spwho2.SPID) BlkBy:$($spwho2.BlkBy) Status:$(($spwho2.Status).Trim()) Login:$($spwho2.Login) HostName:$($spwho2.HostName) DBName:$($spwho2.DBName) CPUTime:$($spwho2.CPUTime) PrgmName:$($spwho2.ProgramName)"
            }
        }
    }
    $message += "`r`n"
    $queryHT = @{}
    foreach ($spid in $blockingHT.GetEnumerator()) {
        if (-not($queryHT.ContainsKey($spid.Value))) {
            $key = ($spid.Value).Trim()
            $query = "DBCC InputBuffer($key)"
            $results = Get-CMNDatabaseData -connectionString $dbConnectionString -query $query -isSQLServer
            $queryHT.Add($spid.Value, $results.EventInfo)
            $message += "`r`n$($spid.Value) - $($results.EventInfo)"
        }
        if (-not($queryHT.ContainsKey($spid.Name))) {
            $key = ($spid.Name).Trim()
            $query = "DBCC InputBuffer($key)"
            $results = Get-CMNDatabaseData -connectionString $dbConnectionString -query $query -isSQLServer
            $queryHT.Add($spid.Key, $results.EventInfo)
            $message += "`r`n$($spid.Name) - $($results.EventInfo)"
        }
    }
    $message += "`r`n"
}
if ($PSBoundParameters['killSpids']) {
    $message += "`r`n$divider"
    $message += "`r`nKilling spids"
    $SPIDS = $blockingHT.Values | Sort-Object -Unique
    foreach ($spid in $SPIDS) {
        $query = "Kill $spid"
        $message += $query
        Invoke-CMNDatabaseQuery -connectionString $dbConnectionString -query $query -isSQLServer | Out-Null
    }
}
Write-Output $message