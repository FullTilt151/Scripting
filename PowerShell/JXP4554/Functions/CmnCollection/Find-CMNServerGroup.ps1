$sccmConnection = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWQS1150
$collections = Get-CimInstance -query "Select * from SMS_Collection"  -ComputerName $sccmConnection.ComputerName -Namespace $sccmConnection.NameSpace
$count = 0
$memberCount = 0
foreach ($collection in $collections) {
    $collection = $collection | Get-CimInstance
    if($collection.UseCluster){
        write-output "$($collection.CollectionID) - $($collection.Name)"
        $count++
        $memberCount += $collection.MemberCount
    }
}
write-output "$count collections containing a total of $memberCount machines"