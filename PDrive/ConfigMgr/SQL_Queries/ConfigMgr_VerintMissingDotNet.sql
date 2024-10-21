select Name
from v_cm_res_coll_cas02E5b
where name in (
select netbios_name0
from v_R_System_Valid
where Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 6.1','Microsoft Windows NT Workstation 6.1 (Tablet Edition)') and
	  Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and
	 ResourceID not in (
select sys.ResourceID
from v_R_System_Valid SYS left join
	 v_add_remove_programs ARP on sys.ResourceID = arp.ResourceID
where DisplayName0 in (
	  'Microsoft .NET Framework 4.5.2',
	  'Microsoft .NET Framework 4.6',
	  'Microsoft .NET Framework 4.6.1') and
	  ProdID0 not like '%1033'
)
)