$AvayaWKIDs = Invoke-Sqlcmd -ServerInstance CMWPDB -Database CM_WP1 -Query ("select sys.Netbios_Name0
from v_r_system sys inner join
	 v_gs_installed_software sft on sys.ResourceID = sft.ResourceID
where sft.ProductName0 like 'Avaya one-X%'")

$AvayaWKIDs | ForEach-Object {
    if ($_ -in $POC) { Remove-ADGroupMember -Identity 'T_Client_DGReplacement' -Members $(Get-ADComputer -Identity $_) -Verbose }
    if ($_ -in $Pilot1) { Remove-ADGroupMember -Identity 'T_CIS_GPO_DG_Pilot1' -Members $(Get-ADComputer -Identity $_) -Verbose }
    if ($_ -in $Prod1) { Remove-ADGroupMember -Identity 'T_CIS_GPO_DG_Prod1' -Members $(Get-ADComputer -Identity $_) -Verbose }
    if ($_ -in $Prod2) { Remove-ADGroupMember -Identity 'T_CIS_GPO_DG_Prod2' -Members $(Get-ADComputer -Identity $_) -Verbose }
    if ($_ -in $Prod3) { Remove-ADGroupMember -Identity 'T_CIS_GPO_DG_Prod3' -Members $(Get-ADComputer -Identity $_) -Verbose }
    if ($_ -in $Prod4) { Remove-ADGroupMember -Identity 'T_CIS_GPO_DG_Prod4' -Members $(Get-ADComputer -Identity $_) -Verbose }
}

$AllWKIDs = Get-ADComputer -SearchBase "OU=Workstations,OU=Testing,DC=humad,DC=com" -filter *

$POC = Get-ADGroupMember -Identity 'T_Client_DGReplacement' | Select-Object -ExpandProperty Name
$Pilot1 = Get-ADGroupMember -Identity 'T_CIS_GPO_DG_Pilot1' | Select-Object -ExpandProperty Name
$Prod1 = Get-ADGroupMember -Identity 'T_CIS_GPO_DG_Prod1' | Select-Object -ExpandProperty Name # 100 WKIDs
$Prod2 = Get-ADGroupMember -Identity 'T_CIS_GPO_DG_Prod2' | Select-Object -ExpandProperty Name # 250 WKIDs
$Prod3 = Get-ADGroupMember -Identity 'T_CIS_GPO_DG_Prod3' | Select-Object -ExpandProperty Name # 1000 WKIDs
$Prod4 = Get-ADGroupMember -Identity 'T_CIS_GPO_DG_Prod4' | Select-Object -ExpandProperty Name # 5000 WKIDs

$Exclusions = $poc + $pilot1 + $Prod1 + $AvayaWKIDs + $Prod2 + $Prod3

Get-Content C:\temp\wkids.txt | Get-Random -Count 5000 | clip.exe