$OU = Get-ADComputer -Filter * -SearchBase "OU=Workstations,OU=Testing, DC=humad, DC=com" 

"Currently $($ou.count) WKIDs in Testing OU."
"Currently $((Get-ADGroupMember -Identity T_Azure_Intune_Win10HybridCompliance).count) WKIDs in Compliance group."

$OU |
ForEach-Object {
    Add-ADGroupMember -Identity T_Azure_Intune_Win10HybridCompliance -Members $_ -Confirm:$false
}

"Now $((Get-ADGroupMember -Identity T_Azure_Intune_Win10HybridCompliance).count) WKIDs in Compliance group."