$SCCMCon = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS875
$WMIQueryParameters = @{
    ComputerName = $SCCMCon.ComputerName;
    NameSpace = $SCCMCon.NameSpace;
}
$dplmntFolder = 'NWS Patch Management\Deploy to Collections'
$rbtFldr = 'NWS Patch Management\Deploy to Collections\Reboot'
$noRbtFldr = 'NWS Patch Management\Deploy to Collections\NoReboot'
$mwFldr = 'Maintenance Windows'

$dplmntFolderID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMCon -Name $dplmntFolder -ObjectType SMS_Collection_Device
$rbtFldrID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMCon -Name $rbtFldr -ObjectType SMS_Collection_Device
$noRbtFldrID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMCon -Name $noRbtFldr -ObjectType SMS_Collection_Device
$mwFldrID = Get-CMNObjectContainerNodeIDbyName -SCCMConnectionInfo $SCCMCon -Name $mwFldr -ObjectType SMS_Collection_Device 
#Build hash tables of mw collections. One that is auto reboot, and the others.

$colHashTable = @{}
$mwColIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMCon -parentContainerNodeID $mwFldrID -Recurse -ObjectType SMS_Collection_Device
foreach($mwColID in $mwColIDs)
{
    $query = "select * from SMS_Collection where CollectionID = '$mwColID'"
    $collection = Get-WmiObject -Query $query @WMIQueryParameters
    if($collection.Name -match ' No.?Reboot' -or $collection.Name -match 'Manual')
    {
        $colHashTable['NoReboot'] += [Array]$collection.CollectionID
    }
    else
    {
        $colHashTable['Reboot'] += [Array]$collection.CollectionID
    }
}

$depcolIDs = Get-CMNObjectIDsBelowFolder -SCCMConnectionInfo $SCCMCon -parentContainerNodeID $dplmntFolderID -ObjectType SMS_Collection_Device

# Cycle through each collection ID
foreach($depcolID in $depcolIDs)
{
    # Get collection info
    $query = "Select * from SMS_Collection where CollectionID = '$depcolID'"
    $collection = Get-WmiObject -Query $query @WMIQueryParameters

    # Get names of new collections
    $nrColName = "$($collection.Name) - NoReboot"
    $rbColName = "$($collection.Name) - Reboot"

    $query = "Select * from SMS_Collection where Name = '$nrColName'"
    $nrCol = Get-WmiObject -Query $query @WMIQueryParameters
    $query = "Select * from SMS_Collection where Name = '$rbColName'"
    $rbCol = Get-WmiObject -Query $query @WMIQueryParameters

    # If they exist, remove all rules, else create
    if($nrCol)
    {
        $nrCol
    }
    else
    {
        $nrCol = New-CMNDeviceCollection -SCCMConnectionInfo $SCCMCon -comment "Created by script" -limitToCollectionID $depcolID -name $nrColName 
        Move-CMNObject -SCCMConnectionInfo $SCCMCon -objectID $nrCol.CollectionID -destinationContainerID $noRbtFldrID -objectType SMS_Collection_Device
    }
    
    # Add appropriate include rules to the no Reboot collection
    foreach($colID in $colHashTable['NoReboot'])
    {
        $query = "Select * from SMS_Collection where CollectionID = '$colID'"
        $incCol = Get-WmiObject -Query $query @WMIQueryParameters
        New-CMNDeviceCollectionIncludeRule -SCCMConnectionInfo $sccmcon -includeCollectionID $colID -CollectionID $nrCol.CollectionID -ruleName $incCol.Name 
    }

    if($rbCol)
    {
        $rbCol
    }
    else
    {
        $rbCol = New-CMNDeviceCollection -SCCMConnectionInfo $SCCMCon -comment "Created by script" -limitToCollectionID $depcolID -name $rbColName
        Move-CMNObject -SCCMConnectionInfo $SCCMCon -objectID $rbCol.CollectionID -destinationContainerID $rbtFldrID -objectType SMS_Collection_Device
    }

    # Add appropraite include rules to the Reboot collection
    foreach($colID in $colHashTable['Reboot'])
    {
        $query = "Select * from SMS_Collection where CollectionID = '$colID'"
        $incCol = Get-WmiObject -Query $query @WMIQueryParameters
        New-CMNDeviceCollectionIncludeRule -SCCMConnectionInfo $sccmcon -includeCollectionID $colID -CollectionID $rbCol.CollectionID -ruleName $incCol.Name 
    }

    # Now, let
}