SELECT        RV.Netbios_Name0 AS WKID, SCUM.TopConsoleUser0 AS Owner, CS.UserName0 AS [Last User 1], RV.User_Name0 AS [Last User 2], 
                         RV.User_Domain0 AS [Last User Domain]
FROM            v_R_System_Valid AS RV LEFT OUTER JOIN
                         v_GS_COMPUTER_SYSTEM AS CS ON RV.ResourceID = CS.ResourceID LEFT OUTER JOIN
                         v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP AS SCUM ON RV.ResourceID = SCUM.ResourceID
WHERE        (RV.Netbios_Name0 LIKE @WKID)
ORDER BY WKID


declare @userid varchar(30)
set @userid = '%dxr5354%';

select distinct cs.UserName0 [Last User 1], sys.User_Name0 [Last User 2], scum.TopConsoleUser0 [Top User], 
		cs.Caption0 [WKID 1], sys.Netbios_Name0 [WKID 2], 
		case 
		WHEN sys.Operating_System_Name_and0 LIKE 'Microsoft Windows NT Workstation 6.1%' THEN 'Windows 7'
		WHEN sys.Operating_System_Name_and0 LIKE 'Microsoft Windows NT Workstation 5.1%' THEN 'Windows XP'
		WHEN sys.Operating_System_Name_and0 LIKE 'Microsoft Windows NT Workstation 6.2%' THEN 'Windows 8'
		WHEN sys.Operating_System_Name_and0 LIKE 'Microsoft Windows NT Workstation 6.3%' THEN 'Windows 8.1'
		end as [OS],
		case cs.Manufacturer0
		when 'VMware, Inc.' THEN 'Yes'
		when 'Microsoft Corporation' THEN 'Yes'
		else 'No'
		end as [Is VM?], 
		case 
		when cs.Caption0 like '%XDW%' THEN 'Yes'
		else 'No'
		end as 'VDI?', 
		cs.manufacturer0 [Mfg], csp.Version0 [Model], cs.Model0 [Model Number],
		CPU.Name0 [CPU], CS.TotalPhysicalMemory0/1000 [RAM in MB], disk.Size0/1024 [Disk Size in GB]
from v_r_system SYS full join
	 v_GS_COMPUTER_SYSTEM CS ON sys.resourceid = cs.resourceid FULL JOIN
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM ON SCUM.ResourceID = SYS.ResourceID FULL JOIN
	 v_GS_PROCESSOR CPU ON SYS.ResourceID = CPU.ResourceID FULL JOIN
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID FULL JOIN
	 v_GS_LOGICAL_DISK DISK ON sys.ResourceID = disk.ResourceID
where (sys.User_Name0 like @userid or cs.UserName0 like @userid or scum.TopConsoleUser0 like @userid) and (sys.Netbios_Name0 IS NOT NULL or cs.Caption0 IS NOT NULL) and (DISK.DeviceID0 = 'C:' or DISK.DeviceID0 IS NULL)
order by cs.caption0, sys.Netbios_Name0