with ArrayVersion (ResourceID, DisplayName0, Version0, V9)
as (
select ResourceID, DisplayName0, Version0, 
	   (select max(ARP1.Version0)
	    from v_add_remove_programs ARP1
		where Publisher0 = 'Array Networks' and
			  Version0 like '9%' and
			  arp1.ResourceID = arp.ResourceID) 
from v_add_remove_programs ARP
where Publisher0 = 'Array Networks' and
	  DisplayName0 like '%SSL VPN%'
)

select CASE sys.Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   else 'Unknown'
	   end as [OS], 
	   DisplayName0 [Product], Version0 [Version 1], V9 [Version 2], Count(*)
from ArrayVersion join
	 v_r_system SYS on ArrayVersion.ResourceID = sys.ResourceID
group by CASE sys.Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   else 'Unknown'
	   end, DisplayName0, Version0, V9
order by OS, Version0