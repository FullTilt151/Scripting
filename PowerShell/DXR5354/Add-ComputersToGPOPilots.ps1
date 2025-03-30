# Method 1
Add-ADGroupMember -Identity 'G_CIS_GPO_W10_P3b' -members  (Get-CMDeviceCollectionDirectMembershipRule -CollectionId WP10646B | Select-Object -ExpandProperty RuleName | ForEach-Object { Get-ADComputer $_ }) -Confirm:$false

Add-ADGroupMember -Identity 'G_CIS_GPO_W10_P4a' -members  (Get-CMDeviceCollectionDirectMembershipRule -CollectionId WP1064C5 | Select-Object -ExpandProperty RuleName | ForEach-Object { Get-ADComputer $_ }) -Confirm:$false
Add-ADGroupMember -Identity 'G_CIS_GPO_W10_P4a' -members  (Get-CMDeviceCollectionDirectMembershipRule -CollectionId WP1064AC | Select-Object -ExpandProperty RuleName | ForEach-Object { Get-ADComputer $_ }) -Confirm:$false

Add-ADGroupMember -Identity 'G_CIS_GPO_W10_P4b' -members  (Get-CMDeviceCollectionDirectMembershipRule -CollectionId WP1064E0 | Select-Object -ExpandProperty RuleName | ForEach-Object { Get-ADComputer $_ }) -Confirm:$false
Add-ADGroupMember -Identity 'G_CIS_GPO_W10_P4b' -members  (Get-CMDeviceCollectionDirectMembershipRule -CollectionId WP1064B1 | Select-Object -ExpandProperty RuleName | ForEach-Object { Get-ADComputer $_ }) -Confirm:$false

Add-ADGroupMember -Identity 'G_CIS_GPO_W10_P5a' -members  (Get-CMDeviceCollectionDirectMembershipRule -CollectionId WP10670E | Select-Object -ExpandProperty RuleName | ForEach-Object { Get-ADComputer $_ }) -Confirm:$false
Add-ADGroupMember -Identity 'G_CIS_GPO_W10_P5a' -members  (Get-CMDeviceCollectionDirectMembershipRule -CollectionId WP1064B9 | Select-Object -ExpandProperty RuleName | ForEach-Object { Get-ADComputer $_ }) -Confirm:$false

Add-ADGroupMember -Identity 'G_CIS_GPO_W10_P5b' -members  (Get-CMDeviceCollectionDirectMembershipRule -CollectionId WP10677C | Select-Object -ExpandProperty RuleName | ForEach-Object { Get-ADComputer $_ }) -Confirm:$false
Add-ADGroupMember -Identity 'G_CIS_GPO_W10_P5b' -members  (Get-CMDeviceCollectionDirectMembershipRule -CollectionId WP10670D | Select-Object -ExpandProperty RuleName | ForEach-Object { Get-ADComputer $_ }) -Confirm:$false

# Method 2
$Pilot = (Get-ADGroup -Identity T_Client_SecurityControlsEnablement -Properties Members).Members
$Pilot1 = (Get-ADGroup -Identity T_CIS_GPO_SecControls_Pilot1 -Properties Members).Members
$Pilot2 = (Get-ADGroup -Identity T_CIS_GPO_SecControls_Pilot2 -Properties Members).Members
$Pilot3 = (Get-ADGroup -Identity T_CIS_GPO_SecControls_Pilot3 -Properties Members).Members
$Pilot4 = (Get-ADGroup -Identity T_CIS_GPO_Pilot4 -Properties Members).Members

$Pilot.count
$Pilot1.count
$Pilot2.count
$Pilot3.count
$Pilot4.count
$Pilot5.Count
$Pilot6.Count


(Get-ADGroup -Identity T_CIS_GPO_SecControls_Prod2 -Properties Members).Members
(Get-ADGroup -Identity T_CIS_GPO_SecControls_Prod3 -Properties Members).Members

$WKIDs = Get-ADComputer -Filter {operatingsystem -eq 'Windows 10 Enterprise' -and enabled -eq 'True'}
$WKIDs.count

$WKIDs.Where({$_.distinguishedname -notin $pilot -and $_.distinguishedname -notin $pilot1 -and $_.distinguishedname -notin $pilot2 -and $_.distinguishedname -notin $pilot3 -and $_.distinguishedname -notin $pilot4 -and $_.distinguishedname -notin $pilot5}) |
Get-Random -Count 1062 |
ForEach-Object {
    Add-ADGroupMember -Identity T_CIS_GPO_SecControls_Prod2 -Members $_
}

$Pilot5 = (Get-ADGroup -Identity T_CIS_GPO_SecControls_Prod2 -Properties Members).Members
$Pilot5.Count


$WKIDs.Where({$_.distinguishedname -notin $pilot -and $_.distinguishedname -notin $pilot1 -and $_.distinguishedname -notin $pilot2 -and $_.distinguishedname -notin $pilot3 -and $_.distinguishedname -notin $pilot4 -and $_.distinguishedname -notin $pilot5}) |
Get-Random -Count 10000 |
ForEach-Object {
    Add-ADGroupMember -Identity T_CIS_GPO_SecControls_Prod3 -Members $_
}

$Pilot6 = (Get-ADGroup -Identity T_CIS_GPO_SecControls_Prod2 -Properties Members).Members
$Pilot6.Count

# Removable Storage block rollout

$Allowed = Get-ADGroupMember -Identity T_Azure_Intune_USBAllowed | Select-Object -ExpandProperty name

$PM = Get-ADComputer -SearchBase 'OU=Physical,OU=Workstations,DC=HUMAD,DC=COM' -Filter "Enabled -eq 'true'"

$PM | Where-Object {$_.Name -notin $Allowed -and $_.name -notin $Prod1 -and $_.name -notin $Prod2 -and $_.name -notin $Prod3`
    -and $_.name -notin $Prod4 -and $_.Distinguishedname -notin $Prod5 -and $_.Distinguishedname -notin $Prod6} | 
Get-Random -Count 10000 |
ForEach-Object {
    Add-ADGroupMember -Identity T_Azure_Intune_USBBlocked_Prod6 -Members $_
}

# 2/17 - Prod 1 - 1000 WKIDs
# 2/23 - Prod 2 - 2500 WKIDs
# 2/25 - Prod 3 - 5000 WKIDs
# 3/2 - Prod 4 - 5000 WKIDs
# 3/4 - Prod 5 – 10,000 WKIDs
# 3/8 - Prod 6 – 10,000 WKIDs

$Test = Get-ADGroupMember -identity T_Azure_Intune_USBAllowed_Test
$Prod1 = Get-ADGroupMember -identity T_Azure_Intune_USBBlocked_Prod1
$Prod2 = Get-ADGroupMember -identity T_Azure_Intune_USBBlocked_Prod2
$Prod3 = Get-ADGroupMember -identity T_Azure_Intune_USBBlocked_Prod3
$Prod4 = Get-ADGroupMember -identity T_Azure_Intune_USBBlocked_Prod4
$Prod5 = Get-ADGroup T_Azure_Intune_USBBlocked_Prod5 -Properties Member | Select-Object -ExpandProperty member
$Prod6 = Get-ADGroup T_Azure_Intune_USBBlocked_Prod6 -Properties Member | Select-Object -ExpandProperty member

$Test.Count
$Prod1.Count
$Prod2.Count
$Prod3.Count
$Prod4.Count
$Prod5.Count
$Prod6.Count

# Counts of group members

$Prod0 = Get-ADGroup T_CIS_GPO_Pilot0 -Properties Member | Select-Object -ExpandProperty member
$Prod1 = Get-ADGroup T_CIS_GPO_Pilot1 -Properties Member | Select-Object -ExpandProperty member
$Prod2 = Get-ADGroup T_CIS_GPO_Pilot2 -Properties Member | Select-Object -ExpandProperty member
$Prod3 = Get-ADGroup T_CIS_GPO_Pilot3 -Properties Member | Select-Object -ExpandProperty member
$Prod4 = Get-ADGroup T_CIS_GPO_Pilot4 -Properties Member | Select-Object -ExpandProperty member

$Prod0.Count
$Prod1.Count
$Prod2.Count
$Prod3.Count
$Prod4.Count