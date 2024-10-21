select sys.Netbios_Name0, arp.DisplayName0, 
		(select svc.DisplayName0
			from v_GS_SERVICE svc 
			where svc.DisplayName0 = 'Message Queuing' and
			svc.ResourceID = sys.resourceid),
		(select svc.Name0
			from v_GS_SERVICE svc 
			where svc.DisplayName0 = 'Message Queuing' and
			svc.ResourceID = sys.resourceid),
		(select svc.StartMode0
			from v_GS_SERVICE svc 
			where svc.DisplayName0 = 'Message Queuing' and
			svc.ResourceID = sys.resourceid),
		(select svc.Status0
			from v_GS_SERVICE svc 
			where svc.DisplayName0 = 'Message Queuing' and
			svc.ResourceID = sys.resourceid)
from v_r_system sys left join
	 v_Add_Remove_Programs ARP on sys.ResourceID = arp.ResourceID
where sys.client0 = 1 and 
	  sys.Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 6.1','Microsoft Windows NT Workstation 6.1 (Tablet Edition)') and
	  arp.displayname0 = 'Desktop & Process Analytics Client(x64) - 15.1.0.1666'