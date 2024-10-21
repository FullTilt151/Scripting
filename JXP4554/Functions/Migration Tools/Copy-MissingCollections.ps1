$CASConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS875
$WP1ConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer LOUAPPWPS1658
$containerID = Get-CMNObjectContainerNodeID -SCCMConnectionInfo $CASConnectionInfo -Name 'All Virtual Machines' -ObjectType SMS_Collection_Device
$collectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $CASConnectionInfo -ObjectiD $containerID -ObjectType SMS_Collection_Device 
Copy-CMNCollection -SourceConnectionInfo $CASConnectionInfo -DestinationConnectionInfo $WP1ConnectionInfo -CollectionIDs $collectionIDs -Verbose
$containerID = Get-CMNObjectContainerNodeID -SCCMConnectionInfo $CASConnectionInfo -Name 'Maintenance Windows' -ObjectType SMS_Collection_Device
$collectionIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $CASConnectionInfo -ObjectiD $containerID -ObjectType SMS_Collection_Device
#Copy-CMNCollection -SourceConnectionInfo $CASConnectionInfo -DestinationConnectionInfo $WP1ConnectionInfo -CollectionIDs $collectionIDs -Verbose
