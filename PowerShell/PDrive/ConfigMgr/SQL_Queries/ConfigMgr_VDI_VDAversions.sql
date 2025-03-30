select DisplayName0 [Display], Version0 [Version], count(*) [Total]
from v_add_remove_programs ARP join
	 v_r_system SYS ON arp.resourceid = sys.resourceid
where (displayname0 like 'citrix virtual delivery agent%' or displayname0 = 'Citrix Virtual Desktop Agent') and Is_Virtual_Machine0 = '1'
group by DisplayName0, Version0
order by Version0


select netbios_name0 [WKID], DisplayName0 [Product], Version0 [Version]
from v_add_remove_programs ARP join
	 v_r_system SYS ON arp.resourceid = sys.resourceid
where (displayname0 like 'citrix virtual delivery agent%' or displayname0 = 'Citrix Virtual Desktop Agent')
	  and Is_Virtual_Machine0 = '1'
order by netbios_name0