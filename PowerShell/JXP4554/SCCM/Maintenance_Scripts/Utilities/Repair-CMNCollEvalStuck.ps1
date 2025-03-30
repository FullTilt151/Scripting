$siteServer = 'LOUAPPWPS1658'
$siteServerConnection = Get-CMNSCCMConnectionInfo -siteServer $siteServer
$dbConnString = Get-CMNConnectionString -DatabaseServer $siteServerConnection.SCCMDBServer -Database $siteServerConnection.SCCMDB
$query = 'Select CollectionID
from v_collection
where CurrentStatus = 5'
$collections = Get-CMNDatabaseData -connectionString $dbConnString -query $query -isSQLServer
foreach($collection in $collections.CollectionID){
    $fileName = "$collection.UDC"
    Write-Output "Creating $fileName"
    New-Item -Path 'D:\Program Files\Microsoft Configuration Manager\inboxes\COLLEVAL.box' -Name $fileName -ItemType File
}