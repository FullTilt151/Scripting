select sys.Netbios_Name0, disk.Caption0, FreeSpace0, Size0
from v_r_system_valid sys join 
	 v_GS_LOGICAL_DISK disk on sys.ResourceID = disk.ResourceID
where Operating_System_Name_and0 like '%server%' and disk.DriveType0 = 3 and FreeSpace0 < 5000 and Caption0 = 'D:'
order by FreeSpace0