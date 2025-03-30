select CASE Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.2' then 'Windows 8'
	   when 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' then 'Windows 8'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   end as [OS], 
	   CASE sys.Is_Virtual_Machine0 
	   when '0' then 'No'
	   when '1' then 'Yes'
	   end as [VM],
	   Publisher0, DisplayName0, Version0, count(*) [Total]
from v_r_system SYS join 
	 v_add_remove_programs ARP ON SYS.resourceid = ARP.resourceid
where (DisplayName0 = 'Systems Management Agent' or DisplayName0 = 'AgentRunTime')
      and Operating_System_Name_and0 like '%workstation%'
group by CASE Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.2' then 'Windows 8'
	   when 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' then 'Windows 8'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   end, 
	   CASE sys.Is_Virtual_Machine0 
	   when '0' then 'No'
	   when '1' then 'Yes' end, 
	   Publisher0, DisplayName0, Version0
order by [OS], [VM], DisplayName0, Version0

select sys.netbios_name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain], sys.Is_Virtual_Machine0 [VM], sft.ProductName0, sft.ProductVersion0
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.resourceid = sft.resourceid
where ProductName0 in ('AgentRunTime','Systems Management Agent')
order by ProductName0, ProductVersion0