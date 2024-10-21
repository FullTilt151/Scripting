select case sys.Operating_System_Name_and0 
		when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
		when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	    end [OS], 
	   case sys.Is_Virtual_Machine0 
	   when 0 then 'No'
	   when 1 then 'Yes'
	   end [VM], arp.DisplayName0, arp.Version0, count(*) [Total]
from v_r_system SYS join
	 v_add_remove_programs ARP on sys.resourceid = arp.ResourceID
where sys.Client0 = 1 and DisplayName0 = '1e agent'
group by case sys.Operating_System_Name_and0 
		when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
		when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	    end, 
		sys.Is_Virtual_Machine0, arp.DisplayName0, arp.Version0
having count(*) > 1
order by Version0, Is_Virtual_Machine0