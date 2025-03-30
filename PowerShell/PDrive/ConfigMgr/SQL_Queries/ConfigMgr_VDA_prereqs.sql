select sys.Netbios_Name0 [WKID], 
	   (select distinct displayname0 from v_Add_Remove_Programs arp1
		where sys.ResourceID = arp1.resourceid and
			   (displayname0 = 'Microsoft .NET Framework 4 Client Profile' or
			   displayname0 = 'Microsoft .NET Framework 4.5' or
			   displayname0 = 'Microsoft .NET Framework 4.5.1' or
			   displayname0 = 'Microsoft .NET Framework 4.5.2' or 
			   displayname0 = 'Microsoft .NET Framework 4.6')) [.NET],
		(select distinct displayname0 from v_Add_Remove_Programs arp2
		where sys.ResourceID = arp2.resourceid and
			   (displayname0 = 'Citrix Virtual Desktop Agent' or
			   displayname0 = 'Citrix Virtual Delivery Agent 7.1' or 
			   displayname0 = 'Citrix Virtual Delivery Agent 7.6')) [VDA],
		(select cast(FreeSpace0 as nvarchar) + ' MB'
			from v_GS_LOGICAL_DISK DISK
			where sys.resourceid = DISK.resourceid and
			deviceid0 = 'C:') [Disk Space],
			(select distinct displayname0 from v_Add_Remove_Programs arp3
		where sys.ResourceID = arp3.resourceid and
			   (displayname0 = 'System Center 2012 R2 Configuration Manager Console')) [CM Console],
			   (select distinct InstallDate0 from v_Add_Remove_Programs arp4
		where sys.ResourceID = arp4.resourceid and
			   (displayname0 = 'System Center 2012 R2 Configuration Manager Console')) [CM Console Installed]
from v_r_system sys
where sys.ResourceID in (
	select ResourceID
	from v_CM_RES_COLL_CAS01E0D)
order by Netbios_Name0