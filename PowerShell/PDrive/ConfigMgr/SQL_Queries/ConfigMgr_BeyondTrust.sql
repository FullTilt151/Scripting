select arp.DisplayName0, arp.Version0, count(*) [Total]
from v_r_system_valid sys left join
	 v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID
where Operating_System_Name_and0 like 'Microsoft Windows NT Workstation 10%' and arp.DisplayName0 = 'BeyondTrust PowerBroker Desktops Client for Windows'
group by arp.DisplayName0, arp.Version0
order by arp.DisplayName0, arp.Version0


select arp.DisplayName0, arp.Version0, count(*) [Total]
from v_r_system_valid sys left join
	 v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID
where arp.DisplayName0 = 'BeyondTrust PowerBroker Desktops Client for Windows'
group by arp.DisplayName0, arp.Version0
order by arp.DisplayName0, arp.Version0