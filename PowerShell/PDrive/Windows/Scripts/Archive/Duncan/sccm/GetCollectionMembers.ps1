$SiteServer = 'LOUAPPWPS875'
$SiteCode = 'CAS' 
$CollectionName = 'Upgrade Intel(R) Centrino(R) Advanced-N 6205' 
#Retrieve SCCM collection by name 
$Collection = get-wmiobject -ComputerName $siteServer -NameSpace "ROOT\SMS\site_$SiteCode" -Query "Select * from SMS_Collection where name ='$CollectionName'"
#Retrieve members of collection 
$SMSMembers = Get-WmiObject -ComputerName $SiteServer -Namespace  "ROOT\SMS\site_$SiteCode" -Query "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($Collection.CollectionID)' order by name" | select Name
$SMSMembers.count