/* Software inventory Count */

SELECT        CASE SYS.operating_system_name_and0
				WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
				WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
				WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
				end as OS, 
			SFT.FileVersion, Count (SYS.Netbios_Name0) Count
FROM            dbo.v_R_System SYS JOIN
                         dbo.v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID INNER JOIN
                         dbo.v_GS_SoftwareFile SFT ON SYS.ResourceID = SFT.ResourceID
WHERE        SYS.Operating_System_Name_and0 like '%workstation%' and 
			 (SFT.FileName = 'iexplore.exe') and 
			 (FilePath = 'c:\program files\internet explorer\')
group by CASE SYS.operating_system_name_and0
				WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
				WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
				WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1' end, fileversion
ORDER BY OS, SFT.FileVersion

/* Hardware inventory Count */

select CASE SYS.operating_system_name_and0
				WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
				WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
				WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
				end as OS, 
				case when ie.svcversion0 is null then
				cast(ParseName(ie.version0,4) AS BIGINT)
				else cast(ParseName(ie.svcversion0,4) AS BIGINT) end as 'IE Version', 
				count(*) Count
from v_r_system SYS JOIN
	 v_GS_InternetExplorer640 IE ON SYS.ResourceID = IE.ResourceID
where operating_system_name_and0 like '%workstation%'
group by CASE SYS.operating_system_name_and0
				WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
				WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
				WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
				end,
				case when ie.svcversion0 is null then
				cast(ParseName(ie.version0,4) AS BIGINT)
				else cast(ParseName(ie.svcversion0,4) AS BIGINT) end
order by os, [IE Version]

/* Software inventory WKID list */

select Netbios_Name0, Operating_System_Name_and0, FileVersion
from v_r_system SYS JOIN
	 v_GS_SoftwareFile IE ON sys.ResourceID = ie.ResourceID
where Operating_System_Name_and0 like 'microsoft windows nt workstation 6.1%' and
	  FileName = 'iexplore.exe' and FilePath = 'c:\program files\internet explorer\' and FileVersion like '11%'
order by Netbios_Name0

/* Hardware inventory WKID list */

select netbios_name0, Operating_System_Name_and0, ie.svcVersion0
from v_r_system SYS join
	 v_GS_InternetExplorer640 IE ON sys.ResourceID = ie.ResourceID
	 where Operating_System_Name_and0 like 'microsoft windows nt workstation 6.1%' and ie.svcVersion0 like '11%'
order by Netbios_Name0

-- Hardware inventory count
select Operating_System_Name_and0, ie.svcVersion0, count(*)
from v_R_System_Valid SYS join
	 v_GS_InternetExplorer640 IE ON sys.ResourceID = ie.ResourceID
where Operating_System_Name_and0 like 'microsoft windows nt workstation 6.1%' and ie.svcVersion0 like '11%'
group by Operating_System_Name_and0, ie.svcVersion0
order by svcVersion0



-- IE11 by filename
select FileName, FileVersion, FilePath, FileModifiedDate
from v_gs_softwarefile
where filename = 'iexplore.exe' and
	  FilePath = 'C:\Program Files (x86)\Internet Explorer\' and
	  FileVersion like '11%'

-- IE11 by registry
select Build0, svcUpdateVersion0, svcVersion0
from v_GS_InternetExplorer0
where svcUpdateVersion0 like '11%'

-- IE11 by QFE
select netbios_name0, Resource_Domain_OR_Workgr0, Operating_System_Name_and0, HotFixID0, CAST(InstalledOn0 as Datetime) InstalledOn0
from v_r_system SYS join
	 v_GS_QUICK_FIX_ENGINEERING ON sys.ResourceID = v_GS_QUICK_FIX_ENGINEERING.ResourceID
where HotFixID0 = 'KB2841134'
order by InstalledOn0 DESC