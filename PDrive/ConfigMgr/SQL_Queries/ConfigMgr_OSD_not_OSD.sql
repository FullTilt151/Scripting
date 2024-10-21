SELECT top 250 SYS.Netbios_Name0 [WKID], Resource_Domain_OR_Workgr0 [Domain], SYS.AD_Site_Name0 [AD Site], CASE SYS.Operating_System_Name_and0
					WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
					WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
					WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
					END as [OS], 
					CASE 
					WHEN SS.OSVersion0 LIKE 'W7%' THEN 'Ghost' 
					WHEN SS.OSVersion0 LIKE 'XP%' THEN 'Ghost'
					WHEN SS32.OSVersion0 LIKE 'XP%' THEN 'Ghost'
					WHEN TaskSequence0 IS NOT NULL THEN 'OSD' 
					WHEN SS.OSVersion0 = '0214' THEN 'OSD' 
					WHEN SS.OSVersion0 = '0114' THEN 'OSD' 
					WHEN SS.OSVersion0 = '0314' THEN 'OSD'
					WHEN SS.OSVersion0 = '0414' THEN 'OSD'
					WHEN SS.OSVersion0 = '0115' THEN 'OSD'
					WHEN SS.OSVersion0 = '0215' THEN 'OSD'
					WHEN SS.OSVersion0 = '0315' THEN 'OSD'
					WHEN SS.OSVersion0 = '0415' THEN 'OSD'
					WHEN SS.OSVersion0 = '0116' THEN 'OSD'
					WHEN SS.OSVersion0 = '0216' THEN 'OSD'
					WHEN SS.OSVersion0 = '0316' THEN 'OSD'
					WHEN SS.OSVersion0 = '0416' THEN 'OSD'
					WHEN SS.OSVersion0 = '10092013' THEN 'OSD' 
					WHEN SS.OSVersion0 = '08302013' THEN 'OSD' 
					WHEN SS.OSVersion0 = '10152013' THEN 'OSD'
					ELSE 'Unknown'
					END AS Method, 
						 CONVERT(date, OS.InstallDate0) [OS Install Date], OSD.TaskSequence0 [OSD Task Sequence], OSD.SMSTSRole0 [OSD Build], OSD.ImageCreationDate0 [OSD Image Created], 
						 SS.Install_Date0 [SS Image Created], SS.OSVersion0 [SS Image Version], SS32.Install_Date0 [SS Image Created 32], SS32.OSVersion0 [SS Image Version 32],
						 OSD.DeployedBy0 [Deployed By], SYS.User_Name0 [UserName], USR.Full_User_Name0 [User]
FROM            dbo.v_R_System SYS LEFT JOIN
                         dbo.v_GS_OSD640 OSD ON SYS.resourceid = OSD.resourceid LEFT JOIN
                         dbo.v_GS_SystemSoftware640 SS ON SYS.ResourceID = SS.ResourceID LEFT JOIN
						 dbo.v_GS_SystemSoftware0 SS32 ON SYS.ResourceID = SS32.ResourceID LEFT JOIN
						 v_gs_operating_system OS ON SYS.ResourceID = OS.ResourceID LEFT JOIN
						 v_GS_WORKSTATION_STATUS WS ON SYS.ResourceID = WS.ResourceID LEFT JOIN
						 v_r_user USR ON SYS.User_Name0 = USR.User_Name0
WHERE Operating_System_Name_and0 like '%workstation%' and 
	  SYS.Is_Virtual_Machine0 = 0 and 
	  Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and
	  Resource_Domain_OR_Workgr0 != 'CORP' and
	  TaskSequence0 IS NULL and 
	  ImageName0 IS NULL and
	  ImageRelease0 IS NULL and
	  WS.LastHWScan IS NOT NULL
ORDER BY InstallDate0 DESC