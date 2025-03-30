#Add computers to an AD group
$WKIDS = (Get-Content -Path C:\temp\wkids.txt)
foreach ($WKID in $WKIDS){
$DistinguishedName = Get-ADComputer -Identity "$wkid" 
Add-ADGroupMember -Identity 'T_Client_AvayaQOS' -Members $DistinguishedName
}