-- Server drive info and cache info
select distinct Netbios_Name0 [Name], Client_Version0 [Version],
	     case Operating_System_Name_and0
		 when 'Microsoft Windows NT Server 6.0' then 'Server 2008'
		 when 'Microsoft Windows NT Server 6.1' then 'Server 2008 R2'
		 when 'Microsoft Windows NT Server 6.2' then 'Server 2012'
		 when 'Microsoft Windows NT Server 6.3' then 'Server 2012 R2'
		 when 'Microsoft Windows NT Advanced Server 5.2' then 'Server 2003'
		 when 'Microsoft Windows NT Advanced Server 6.0' then 'Server 2008'
		 when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
		 when 'Microsoft Windows NT Advanced Server 6.2' then 'Server 2012'
		 when 'Microsoft Windows NT Advanced Server 6.3' then 'Server 2012 R2'
		 end [OS], 
		(select DeviceID0
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and DeviceID0 = 'C:') [C],
		(select cast(FreeSpace0 as nvarchar) + ' MB'
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'C:') [Freespace C], 
		(select cast(Size0 as nvarchar) + ' MB' 
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'C:') [TotalSize C], 
		(select DeviceID0
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and DeviceID0 = 'D:') [D],
		(select cast(FreeSpace0 as nvarchar) + ' MB'
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'D:') [Freespace D], 
		(select cast(Size0 as nvarchar) + ' MB' 
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'D:') [TotalSize D], 
		(select DeviceID0
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and DeviceID0 = 'E:') [E],
		(select cast(FreeSpace0 as nvarchar) + ' MB'
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'E:') [Freespace E], 
		(select cast(Size0 as nvarchar) + ' MB' 
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'E:') [TotalSize E], 
		(select DeviceID0
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and DeviceID0 = 'F:') [F],
		(select cast(FreeSpace0 as nvarchar) + ' MB'
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'F:') [Freespace F], 
		(select cast(Size0 as nvarchar) + ' MB' 
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'F:') [TotalSize F], 
		cache.Location0 [SCCM Cache], cache.Size0 [SCCM Cache Size]
from v_r_system SYS join
	 v_GS_LOGICAL_DISK DSK on sys.ResourceID = DSK.ResourceID join
	 v_GS_SMS_ADVANCED_CLIENT_CACHE CACHE on sys.ResourceID = cache.ResourceID
where client0 = 1 and
	  Operating_System_Name_and0 in (
	  'Microsoft Windows NT Server 6.0',
	  'Microsoft Windows NT Server 6.1',
	  'Microsoft Windows NT Server 6.2',
	  'Microsoft Windows NT Server 6.3',
	  'Microsoft Windows NT Advanced Server 5.2',
	  'Microsoft Windows NT Advanced Server 6.0',
	  'Microsoft Windows NT Advanced Server 6.1',
	  'Microsoft Windows NT Advanced Server 6.2',
	  'Microsoft Windows NT Advanced Server 6.3'
	  ) and
	  dsk.DriveType0 = 3 and
	  ((left(cache.Location0,2) not in (
	  select DeviceID0
	  from v_GS_LOGICAL_DISK
	  where ResourceID = sys.ResourceID )) or (
	  cache.Location0 like 'c:\%'
	  ))
order by Netbios_Name0