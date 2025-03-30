select distinct Netbios_name0 [WKID], 
		(select distinct DisplayName0 from v_Add_Remove_Programs where resourceid = sys.ResourceID and 
		DisplayName0 = 'Avaya Proactive Contact Agent API SDK 5.1') [Avaya],
		(select distinct DisplayName0 from v_Add_Remove_Programs where resourceid = sys.ResourceID and displayname0 like 'Microsoft .NET Framework 4.5%') [Dot Net]
from v_r_system SYS left join
	 v_add_remove_programs ARP on sys.resourceid = arp.resourceid
where sys.ResourceID in (select ResourceID from v_CM_RES_COLL_CAS01B60)
order by Netbios_Name0