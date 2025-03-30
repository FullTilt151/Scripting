select *
from v_GS_CUSTOM_MAPPEDDRIVES

select count(resourceid) from v_GS_CUSTOM_MAPPEDDRIVES

select sys.Netbios_Name0, sys.Operating_System_Name_and0, map.DrivePath0, map.Username0
from v_R_System_Valid sys join
	 v_GS_CUSTOM_MappedDrives map on sys.ResourceID = map.ResourceID
where drivepath0 like '\\xerxes%' or DrivePath0 like '\\thor%'
order by Operating_System_Name_and0, Netbios_Name0