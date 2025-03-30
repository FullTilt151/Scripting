--WKID count
select distinct CASE Operating_System_Name_and0
				WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
				WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
				WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
				END as [OS],
				FileVersion, Count (*) [Totals]
from v_r_system SYS FULL JOIN
	 v_gs_softwarefile SF ON sys.resourceid = sf.ResourceID FULL JOIN
	 v_GS_OSD640 OSD ON SYS.ResourceID = OSD.ResourceID FULL JOIN
	 v_GS_SystemSoftware640 SS ON sys.ResourceID = ss.ResourceID
where filename = 'wmplayer.exe' and filepath = 'c:\program files\Windows Media Player\' and Operating_System_Name_and0 like '%workstation%'
GROUP BY CASE Operating_System_Name_and0
				WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
				WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7' 
				WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7' 
				WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
				WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
				END, 
				FileVersion
order by os, FileVersion

-- WKID list
select netbios_name0 [WKID], user_name0 [User],
	   CASE 
	   WHEN Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
	   WHEN Operating_System_Name_and0 LIKE 'Microsoft Windows NT Workstation 6.1%' THEN 'Windows 7'
	   WHEN Operating_System_Name_and0 LIKE 'Microsoft Windows NT Workstation 6.2%' THEN 'Windows 8'
	   END as [OS],
		FileName, FileVersion, FilePath, ImageCreationDate0, ImageInstalled0, ImageVersion0, TaskSequence0, Install_Date0, OSVersion0
from v_r_system SYS FULL JOIN
	 v_GS_OSD640 OSD ON sys.ResourceID = osd.ResourceID FULL JOIN
	 v_GS_SystemSoftware640 SS ON sys.ResourceID = ss.ResourceID FULL JOIN
	 v_gs_softwarefile SF ON sys.ResourceID = sf.ResourceID
where filename = 'wmplayer.exe' and filepath = 'c:\program files\Windows Media Player\' and Operating_System_Name_and0 like '%workstation%'
order by FileVersion, ImageCreationDate0, Install_date0, OSVersion0, TaskSequence0, netbios_name0