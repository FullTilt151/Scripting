-- Count of VMs
select Resource_Domain_OR_Workgr0 [Domain], 
	   case Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   end [OS], count(*) [Total]
from v_r_system SYS
where client0 = 1 and 
	  is_virtual_machine0 = 1 and
	  Operating_System_Name_and0 like 'Microsoft Windows NT Workstation%'
group by Resource_Domain_OR_Workgr0, 
	   case Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   end
order by Domain, OS

-- List of VMs
select sys.netbios_name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain], sys.AD_Site_Name0 [AD Site],
	   case Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   end [OS]
from v_r_system SYS
where client0 = 1 and 
	  is_virtual_machine0 = 1 and
	  Operating_System_Name_and0 like 'Microsoft Windows NT Workstation%'
order by netbios_name0, Domain, OS