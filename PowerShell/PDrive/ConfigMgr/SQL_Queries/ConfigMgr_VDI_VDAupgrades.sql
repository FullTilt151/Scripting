select fcm.CollectionID, sys.Netbios_Name0,  arp.DisplayName0, arp.Version0,
	   (select top 1  arp1.DisplayName0
		from v_Add_Remove_Programs arp1
		where arp1.ResourceID = sys.ResourceID and
			  (arp1.DisplayName0 = 'Microsoft .NET Framework 4.5.1' or
			  arp1.DisplayName0 = 'Microsoft .NET Framework 4.5.2')),disk.DeviceID0, disk.FreeSpace0
from v_r_system SYS left join
	 v_GS_LOGICAL_DISK DISK on sys.resourceid = disk.ResourceID left join
	 v_FullCollectionMembership FCM on sys.resourceid = fcm.ResourceID left join
	 v_Add_Remove_Programs ARP on sys.resourceid = arp.resourceid
where fcm.CollectionID = 'CAS01E21' and
	  disk.DeviceID0 = 'C:' and
	  (arp.DisplayName0 = 'Citrix Virtual Desktop Agent - x64' or
	  arp.DisplayName0 = 'Citrix Virtual Desktop Agent')
order by Version0 desc

-- Not in VDA list
select fcm.CollectionID, sys.Netbios_Name0
from v_r_system SYS left join
	 v_FullCollectionMembership FCM on sys.resourceid = fcm.ResourceID
where fcm.CollectionID = 'CAS01E21' and
	  sys.ResourceID not in (select sys.ResourceID
from v_r_system SYS left join
	 v_FullCollectionMembership FCM on sys.resourceid = fcm.ResourceID left join
	 v_Add_Remove_Programs ARP on sys.ResourceID = arp.ResourceID
where fcm.CollectionID = 'CAS01E21' and
	  (arp.DisplayName0 like 'Citrix Virtual Desktop Agent - x64' or
	  arp.DisplayName0 like 'Citrix Virtual Desktop Agent'))