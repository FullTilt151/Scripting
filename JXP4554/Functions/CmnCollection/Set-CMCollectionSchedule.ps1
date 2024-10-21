<#
SMS_ObjectContainerNode - Maps Folder name to ConatainerNodeID
SMS_ObjectContainerItem - Maps ContainerNodeID to CollectionID
#>
PARAM(
    [Parameter(Mandatory = $true, HelpMessage = "SiteServer")]
    [String]$SiteServer,
    [Parameter(Mandatory = $true, HelpMessage = "Folder Name")]
    [String]$FolderName
)
$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode
$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace    = "root\sms\site_$SiteCode"
}
#Create Schedule Object
$CMSchedule = ([WMIClass]"\\$($SiteServer)\Root\sms\site_$($SiteCode):SMS_ST_RecurInterval").CreateInstance()
$CMSchedule.DaySpan = “1”
$CMSchedule.StartTime = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((get-date -Format "MM/dd/yyy 02:00:00").ToString())

#Get Shopping Folder ConainerNodeID's
if ($FolderName -match '''') {
    $FolderName = $FolderName -replace '''', '%'
    $ContainerNodeID = (Get-WmiObject @WMIQueryParameters -Class SMS_ObjectContainerNode -Filter "Name like '$FolderName'" ).ContainerNodeID
}
else {
    $ContainerNodeID = (Get-WmiObject @WMIQueryParameters -Class SMS_ObjectContainerNode -Filter "Name = '$FolderName'" ).ContainerNodeID
}
if ($ContainerNodeID -eq $null) {
    Write-Host "No folder by that name."
    throw "Unknown Folder"
}

#Get CollectionID's of collections in the nodes
$CollectionIDs = (Get-WmiObject @WMIQueryParameters -Class SMS_ObjectContainerItem -Filter "ContainerNodeID = '$ContainerNodeID'").InstanceKey

#Cycle through each collection and add schedule
foreach ($CollectionID in $CollectionIDs) {
    $objCollection = Get-WmiObject @WMIQueryParameters -Class SMS_Collection -Filter "CollectionID = '$CollectionID'"
    $objCollection.Get()
    $objCollection.RefreshSchedule = $CMSchedule
    $objCollection.RefreshType = 2
    $objCollection.Put() | Out-Null
}