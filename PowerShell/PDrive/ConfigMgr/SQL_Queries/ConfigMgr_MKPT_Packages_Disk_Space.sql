select NOM.DiskUsageKB0/1024 [Usage MB] , NOM.PackageID0, PKG.Name, Count(*) [Total Machines]
from v_r_system SYS INNER JOIN
	 v_gs__e_nomadpackages0 NOM ON SYS.resourceid = NOM.resourceid FULL JOIN
	 v_Package PKG ON NOM.PackageID0 = PKG.PackageID
where Netbios_Name0 like 'WKMP%' and DiskUsageKB0/1024 > 10
group by NOM.DiskUsageKB0, NOM.PackageID0, PKG.Name
Having Count(*) > 1
order by DiskUsageKB0/1024 desc

select Netbios_name0 [WKID], SYS.User_Name0 [User], USR.Full_User_Name0, LD.DeviceID0 [Drive], LD.FreeSpace0 [Free Space MB], LD.Size0 [Disk Size MB], FreeSpace0*100/Size0 [Percent Free]
from v_r_system SYS INNER JOIN
	 v_GS_LOGICAL_DISK LD ON SYS.resourceid = LD.resourceid INNER JOIN
	 v_r_user USR ON SYS.User_Name0 = USR.User_Name0
where netbios_name0 like '%WKMP%' and
	  DeviceID0 = 'C:'
Order by [Percent Free]