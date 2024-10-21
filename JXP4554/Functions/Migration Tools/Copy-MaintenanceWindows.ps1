$CASConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS875
$WP1ConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS1658
$containerID = Get-CMNObjectContainerNodeID -SCCMConnectionInfo $CASConnectionInfo -Name 'Maintenance Windows' -ObjectType SMS_Collection_Device
$collectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $CASConnectionInfo -ObjectiD $containerID -ObjectType SMS_Collection_Device 
foreach($collectionID in $collectionIDs)
{
    $query = "SELECT * from SMS_Collection where CollectionID = '$collectionID'"
    if(Get-WmiObject -Query $query -Namespace $WP1ConnectionInfo.NameSpace -ComputerName $WP1ConnectionInfo.ComputerName)
    {
        $query = "SELECT * FROM SMS_CollectionSettings WHERE CollectionID='$collectionID'"
        $sourceCollectionMW = Get-WmiObject -Query $query -Namespace $CASConnectionInfo.NameSpace -ComputerName $CASConnectionInfo.ComputerName
        $sourceCollectionMW.Get()
        $destinationCollectionMW = ([WMIClass]"//$($WP1ConnectionInfo.ComputerName)/$($WP1ConnectionInfo.NameSpace):SMS_CollectionSettings").CreateInstance()
        foreach($Property in ($sourceCollectionMW.Properties.Name))
        {
            $destinationCollectionMW.$Property = $sourceCollectionMW.$Property
        }
        $destinationCollectionMW.Put()
    }
}