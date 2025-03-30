select coll.Name, cache.Size0 [SCCM Cache Max Size], disk.Size0 [Disk Size], disk.FreeSpace0 [Free Space], disk.FreeSpace0*100/disk.Size0 [% Free]
from v_CM_RES_COLL_CAS005F9 coll left join
	 v_GS_SMS_ADVANCED_CLIENT_CACHE cache on coll.ResourceID = cache.ResourceID left join
	 v_GS_LOGICAL_DISK disk on coll.ResourceID = disk.ResourceID
where disk.DeviceID0 = 'C:'