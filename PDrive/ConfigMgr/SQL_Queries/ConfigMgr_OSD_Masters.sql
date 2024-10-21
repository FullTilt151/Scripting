select distinct SYS.Name0 WKID, sys.build01,		  
		 csp.version0 [Model], CAST(os.installdate0 as Date) [Installed], os.LastBootUpTime0 [Boot], AD_Site_Name0 [AD Site], 
					(select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [MB RAM], 
					/*(select cast(na.Speed0 as BIGINT)/1000000
					from v_GS_NETWORK_ADAPTER na
					where sys.ResourceID = na.ResourceID and na.Speed0 is not null and servicename0 != 'ztap') [NIC],
					*/
					ipaddress0 IPAddress,
					Client_Version0 as [CM Version], 
		(select ProductVersion0
		 from v_GS_NomadBranch_640
	     where sys.resourceid = v_gs_nomadbranch_640.resourceid) [Nomad Version],

		 (select ProductVersion0
		  from v_gs_pxeliteserver0
	     where sys.resourceid = v_gs_pxeliteserver0.resourceid) [PXE Version],

		(select cast(FreeSpace0 as nvarchar) + ' MB'
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'C:') [Freespace C], 

		(select cast(Size0 as nvarchar) + ' MB' 
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'C:') [TotalSize C], 
	
		(select FreeSpace0*100/Size0 
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and Name0 = 'C:') [PercentFree C],

		(select top 1 DISK.Name0
		from v_GS_LOGICAL_DISK DISK
		where SYS.resourceid = DISK.resourceid and (Name0 = 'D:' or Name0 = 'E:' or Name0 = 'F:') and DriveType0 = '3') [Drive 1TB],

		(select top 1 cast(FreeSpace0 as nvarchar) + ' MB'
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and (Name0 = 'D:' or Name0 = 'E:' or Name0 = 'F:') and DriveType0 = '3') [Freespace 1TB], 
		
		(select top 1 cast(Size0 as nvarchar) + ' MB' 
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and (Name0 = 'D:' or Name0 = 'E:' or Name0 = 'F:') and DriveType0 = '3') [TotalSize 1TB], 
		
		(select top 1 FreeSpace0*100/Size0 
		from v_GS_LOGICAL_DISK 
		where SYS.resourceid = v_GS_LOGICAL_DISK.resourceid and (Name0 = 'D:' or Name0 = 'E:' or Name0 = 'F:') and DriveType0 = '3') [PercentFree 1TB], 
		CACHE.Location0 [SCCM Cache], CACHE.Size0 [Cache Size], NOMAD.LocalCachePath0 [Nomad Cache]
from v_R_System SYS inner join
	 v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID INNER JOIN
	 v_gs_network_adapter_configuration NET on SYS.ResourceID=NET.ResourceID LEFT JOIN
	 v_GS_LOGICAL_DISK DISK on SYS.ResourceID=DISK.ResourceID LEFT JOIN
	 v_GS_NomadBranch_640 NOMAD ON SYS.ResourceID = NOMAD.ResourceID LEFT JOIN
	 v_GS_SMS_ADVANCED_CLIENT_CACHE CACHE ON SYS.ResourceID = CACHE.ResourceID LEFT JOIN
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on sys.ResourceID = csp.ResourceID
where SYS.Name0 like '%pxewpw%' and IPAddress0 != '$null' and DISK.Size0 != ''
order by SYS.Name0

/*
select sys.Netbios_Name0, na.*
from v_r_system sys inner join
	 v_GS_NETWORK_ADAPTER na on sys.ResourceID = na.ResourceID
where Netbios_Name0 like '%pxewpw%' and na.Speed0 is not null and servicename0 != 'ztap'
*/