$DistinguishedName = Get-ADComputer -Identity "$wkid"
Add-ADGroupMember -Identity 'T_Azure_Intune_WindowsHelloForBusiness' -Members $DistinguishedName