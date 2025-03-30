-- Virtuals with low disk space
select Netbios_Name0 [WKID], sys.Is_Virtual_Machine0 [VM], dsk.Caption0 [Disk], dsk.FreeSpace0 [Free GB], dsk.Size0 [Total GB]
from v_r_system sys join
	 v_GS_LOGICAL_DISK dsk on sys.ResourceID = dsk.ResourceID and dsk.Caption0 = 'C:' and dsk.FreeSpace0 < 20
where build01 = '10.0.14393' and Client0 = 1 and Is_Virtual_Machine0 = 1
order by Netbios_Name0

-- Physicals with low disk space
select Netbios_Name0 [WKID], sys.Is_Virtual_Machine0 [VM], dsk.Caption0 [Disk], dsk.FreeSpace0 [Free GB], dsk.Size0 [Total GB]
from v_r_system sys join
	 v_GS_LOGICAL_DISK dsk on sys.ResourceID = dsk.ResourceID and dsk.Caption0 = 'C:' and dsk.FreeSpace0 < 20
where build01 = '10.0.14393' and Client0 = 1 and Is_Virtual_Machine0 = 0
order by Netbios_Name0