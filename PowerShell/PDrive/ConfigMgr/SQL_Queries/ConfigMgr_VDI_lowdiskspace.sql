select sys.netbios_name0 [Name], sys.User_Name0, disk.FreeSpace0 [Disk Free MB], Size0 [Disk Size MB], ws.lasthwscan [Hardware Scan]
from v_r_system SYS left join
	 v_GS_LOGICAL_DISK DISK on sys.ResourceID = disk.ResourceID left join
	 v_gs_workstation_status WS on sys.resourceid = ws.resourceid
where DeviceID0 = 'C:' and sys.resourceid in (select resourceid from v_CM_RES_COLL_WP101647) and disk.FreeSpace0 < 500
order by Name