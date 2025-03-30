-- List of workstations with image version
SELECT        SYS.Netbios_Name0 [WKID], Resource_Domain_OR_Workgr0 [Domain], CASE SYS.Operating_System_Name_and0
					WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
					WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
					WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
					WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
					WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
					END as [OS], 
					CASE 
					WHEN OSVersion0 LIKE 'W7%' THEN 'Ghost' 
					WHEN TaskSequence0 IS NOT NULL THEN 'OSD' 
					WHEN OSVersion0 = '10092013' THEN 'OSD' 
					WHEN OSVersion0 = '08302013' THEN 'OSD' 
					WHEN OSVersion0 = '0114' THEN 'OSD'
					WHEN OSVersion0 = '0214' THEN 'OSD'
					WHEN OSVersion0 = '0314' THEN 'OSD'
					WHEN OSVersion0 = '0414' THEN 'OSD'
					WHEN OSVersion0 = '0115' THEN 'OSD'
					WHEN OSVersion0 = '0215' THEN 'OSD'
					WHEN OSVersion0 = '0315' THEN 'OSD'
					WHEN OSVersion0 = '0415' THEN 'OSD'
					WHEN OSVersion0 = '0116' THEN 'OSD'
					WHEN OSVersion0 = '0216' THEN 'OSD'
					WHEN OSVersion0 = '0316' THEN 'OSD'
					WHEN OSVersion0 = '0416' THEN 'OSD'
					ELSE 'Unknown' END AS Method, 
					OSD.DeployedBy0 [Deployed By], usr.Full_User_Name0 [Tech Name], osd.ImageCreationDate0 [OSD Image Created], os.InstallDate0 [OS Installed], osd.ImageInstalled0 [OSD Deployed On], osd.ImageName0 [OSD Image], osd.ImageRelease0 [Image Release], osd.TaskSequence0 [OSD Task Sequence], osd.SMSTSRole0 [OSD Build], osd.PXE0 [OSD PXE], ss.Install_Date0 [Ghost Deployed On], ss.OSVersion0 [Ghost Image Release]
FROM            dbo.v_R_System SYS INNER JOIN
                dbo.v_GS_OSD640 OSD ON SYS.resourceid = OSD.resourceid INNER JOIN
                dbo.v_GS_SystemSoftware640 SS ON SYS.ResourceID = SS.ResourceID JOIN
				dbo.v_GS_OPERATING_SYSTEM OS on sys.ResourceID = os.ResourceID join
				dbo.v_R_User USR on osd.DeployedBy0 = usr.User_Name0
WHERE Operating_System_Name_and0 like '%workstation%' and netbios_name0 like @wkid
ORDER BY Netbios_Name0

-- Count of workstations with image version
SELECT        CASE WHEN OSVersion0 LIKE 'W7%' THEN 'Ghost' WHEN OSVersion0 = '10.1' THEN 'Ghost' WHEN TaskSequence0 IS NOT NULL 
                         THEN 'OSD' WHEN OSVersion0 = '10092013' THEN 'OSD' WHEN OSVersion0 = '08302013' THEN 'OSD' WHEN OSVersion0 = '10152013' THEN 'OSD' WHEN OSVersion0 = '0114' THEN 'OSD' ELSE 'Unknown' END AS Method, 
                         CASE Operating_System_Name_and0 
						 WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
						 WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
						 WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
						 WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
						 WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
						 END as [OS] , 
						 dbo.v_GS_OSD640.TaskSequence0, dbo.v_GS_OSD640.ImageCreationDate0, dbo.v_GS_OSD640.ImageVersion0, dbo.v_GS_SystemSoftware640.OSVersion0, 
                         COUNT(*) AS Total
FROM            dbo.v_R_System INNER JOIN
                         dbo.v_GS_OSD640 ON v_r_system.resourceid = v_GS_OSD640.resourceid INNER JOIN
                         dbo.v_GS_SystemSoftware640 ON v_r_system.ResourceID = v_GS_SystemSoftware640.ResourceID
GROUP BY CASE 
		WHEN OSVersion0 LIKE 'W7%' THEN 'Ghost' 
		WHEN OSVersion0 = '10.1' THEN 'Ghost'
		WHEN TaskSequence0 IS NOT NULL THEN 'OSD' 
		WHEN OSVersion0 = '10092013' THEN 'OSD' 
		WHEN OSVersion0 = '08302013' THEN 'OSD' 
		WHEN OSVersion0 = '10152013' THEN 'OSD' 
		WHEN OSVersion0 = '0114' THEN 'OSD'
		END, 
		Operating_System_Name_and0,
		CASE Operating_System_Name_and0 
						 WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
						 WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
						 WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
						 WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
						 WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
						 end,
		dbo.v_GS_OSD640.TaskSequence0, dbo.v_GS_OSD640.ImageCreationDate0, dbo.v_GS_OSD640.ImageVersion0, dbo.v_GS_SystemSoftware640.OSVersion0
HAVING Operating_System_Name_and0 NOT LIKE '%server%'
ORDER BY Method, os, OSVersion0, TaskSequence0