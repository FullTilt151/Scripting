#T_Azure_Intune_USBAllowed
$WKID = 'WKPC169RJX'
$DistinguishedName = Get-ADComputer -Identity "$wkid"
#Get-ADGroupMember -Identity 'T_Azure_Intune_USBAllowed'
Get-ADGroup -Server louadmwps05 -SearchBase "OU=Azure,OU=Testing,DC=humad,DC=com" -Filter "Name -like 'T_Azure_Intune_USBAllowed'" | Add-ADGroupMember -Members $DistinguishedName