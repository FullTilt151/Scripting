/* 
SCCM SQL Queries
Version Date: 09-Sep-2017
Prepared By
A, Karthikeyan
Email ID
Karthik_bss@yahoo.com
Contact No
+91 9790768919
Document Version No
1.00
Approved By
A, Karthikeyan
Contents
1. A Specific System Is Part of what are all Collections ................................................................................................ 7
2. All Users Names Part of specific AD Group .............................................................................................................. 7
3. Package Deployment Detailed status for specific Advertisement ID ........................................................................ 7
4. All SQL Server Installed Version and Computer Details using Hardware Inventory ................................................. 7
5. All Computers with Last Heartbeat Discovery Time Stamp ...................................................................................... 8
6. All IE Version using Software Inventory .................................................................................................................... 8
7. All Packages Total Targeted DP Counts ................................................................................................................... 8
8. All Packages Compare targeted Packages on Two DPS ......................................................................................... 9
9. Compare Packages with two DP’S ............................................................................................................................ 9
10. All Software Distribution Packages without Advertisements ................................................................................... 10
11. All Client Settings Status ......................................................................................................................................... 10
12. All Workstations Agent Health Status ...................................................................................................................... 10
13. All Servers Agent Health Status .............................................................................................................................. 11
14. All Workstations Agent Detailed Health Status ....................................................................................................... 14
15. All Servers Agent Detailed Health Status ................................................................................................................ 15
16. All Workstations Client Health Summary Status ..................................................................................................... 15
17. All Servers Client Health Summary Status .............................................................................................................. 16
18. All Active and Inactive Workstations Client Status .................................................................................................. 17
19. All Active and Inactive Servers Client Status .......................................................................................................... 17
20. All Active Workstations Client Health Evaluation Status ......................................................................................... 18
21. All Active Servers Client Health Evaluation Status .................................................................................................. 19
22. All Active Workstations Client Heartbeat (DDR) Status .......................................................................................... 20
23. All Active Servers Client Heartbeat (DDR) Status ................................................................................................... 20
24. All Active Workstations Client Hardware Inventory Status ...................................................................................... 21
25. All Active Servers Client Hardware Inventory Status .............................................................................................. 22
26. All Active Workstations Client Software Inventory Status ....................................................................................... 22
27. All Active Servers Client Software Inventory Status ................................................................................................ 23
28. All Active Workstations Client Policy Request Status ............................................................................................. 23
29. All Active Servers Client Policy Request Status ...................................................................................................... 24
30. All PCs discovered from specific site....................................................................................................................... 25
31. All PCs Information with IP address and subnet details .......................................................................................... 25
32. All PCs with chassis type information ...................................................................................................................... 26
33. All Desktops and Laptops counts details ................................................................................................................. 26
34. All PCs Information with subnet and OU details ...................................................................................................... 27
35. All PCs with particular application last used date .................................................................................................... 27
36. All PCs with particular software inventory Exe file .................................................................................................. 28
37. All PCs with Username and Email ID details ........................................................................................................... 28
38. All PCs with Configuration Manager Console installed details ................................................................................ 28
39. All PCs client assigned and installed site code details ............................................................................................ 28
40. All PCs with No Clients based on OS Category status ........................................................................................... 28
41. All Workstations Client version status ..................................................................................................................... 29
42. All PCs with chassis type information ...................................................................................................................... 30
43. All Workstations Client Installation Failure status .................................................................................................... 30
44. All Workstations with Last Boot up time status ........................................................................................................ 30
45. All ConfigMgr Roles Status ...................................................................................................................................... 31
46. All IE Version using Software Inventory .................................................................................................................. 32
47. All Packages which are waiting to distribute content to DPs ................................................................................... 32
48. All Packages Content Distribution Status ................................................................................................................ 33
49. All ConfigMgr Issue Servers Status ......................................................................................................................... 33
50. All Software applications required deployments status within 30 days ................................................................... 33
51. All Software applications available deployments status within 30 days .................................................................. 34
52. All Software applications simulate deployments status within 30 days ................................................................... 34
53. All Software packages required deployments status within 30 days ....................................................................... 35
54. All Software packages available deployments status within 30 days ...................................................................... 35
55. All Software updates required deployments status within 30 days ......................................................................... 36
56. All Software updates available deployments status within 30 days ........................................................................ 36
57. All OSD required deployments status within 30 days.............................................................................................. 37
58. All OSD available deployments status within 30 days............................................................................................. 37
59. All ConfigMgr Roles Detailed status ........................................................................................................................ 38
60. All SCCM Server Software Update Sync status ...................................................................................................... 39
61. All Software applications required deployments status within 5 days ..................................................................... 39
62. All Software packages required deployments status within 5 days ......................................................................... 39
63. All Software updates required deployments status within 5 days ........................................................................... 40
64. All Software applications deployments status within 30 days ................................................................................. 40
65. All Software packages deployments status within 30 days ..................................................................................... 41
66. All Software updates deployments status within 30 days........................................................................................ 42
67. All OS deployments status within 30 days .............................................................................................................. 42
68. All Software updates deployments status within 30 days........................................................................................ 43
69. All OS deployments status within 30 days .............................................................................................................. 43
70. All Site Servers Issue MP components status ......................................................................................................... 44
71. All Site Servers Issue DP components status ......................................................................................................... 44
72. All Site Servers Issue DDR components status ...................................................................................................... 44
73. All Site Servers Issue CCR components status ...................................................................................................... 45
74. All Site Servers Issue WSUS components status ................................................................................................... 45
75. All Site Servers Issue Discovery components status .............................................................................................. 45
76. All Site Servers Issue Collection Evaluator components status .............................................................................. 46
77. All Site Servers Issue Hardware Inventory components status .............................................................................. 46
78. All Site Servers Issue Despooler components status.............................................................................................. 46
79. All Site Servers Issue Inbox Monitor components status ........................................................................................ 47
80. All Site Servers Issue Component Monitor components status .............................................................................. 47
81. All Site Servers Issue Others components status ................................................................................................... 47
82. All Workstations Not Assigned Clients detailed status ............................................................................................ 48
83. All Workstations Unhealthy Clients detailed status ................................................................................................. 48
84. All Workstations Inactive Clients detailed status ..................................................................................................... 49
85. All Obsolete Clients detailed status ......................................................................................................................... 49
86. All Packages available in SCCM ............................................................................................................................. 50
87. All Collections available in SCCM ........................................................................................................................... 50
88. All Managed Workstations details status ................................................................................................................. 50
89. All Workstations Assets Inventory details status ..................................................................................................... 51
90. All Workstations Assets Inventory details status ..................................................................................................... 53
91. All PCs with Office 365 Installed Machines Report Based on Installed Software ................................................... 54
92. All PCs without Office 365 Installed Machines Report Based on Installed Software .............................................. 55
93. All PCs with SEP Antivirus Installed Machines Report Based on Installed Software ............................................. 55
94. All PCs without SEP Antivirus Installed Machines Report Based on Installed Software ........................................ 56
95. All Workstations Client Agent Detailed Report ........................................................................................................ 56
96. All Workstations Low Free Disk Space Report ........................................................................................................ 57
97. All Servers Low Free Disk Space Report ................................................................................................................ 57
98. All Workstations Machines Names Last Logon with Serial No Report .................................................................... 58
99. All Workstations with Adobe Acrobat Reader Installed Machines Report ............................................................... 58
100. All Workstations with Adobe Acrobat Reader Last Usage Machines Report ......................................................... 59
101. All Workstations with Adobe Products Not Used More Than 90 Days Machines Report ...................................... 59
102. All Client and Inventory Health Report ................................................................................................................... 60
103. All Total Scope machines details ............................................................................................................................ 61
104. All Total Healthy machines details .......................................................................................................................... 61
105. All Total Unhealthy machines details ...................................................................................................................... 62
106. All Total Hardware Inventory within 30 Days machines details .............................................................................. 62
107. All Total Hardware Inventory not within 30 Days machines details ........................................................................ 62
108. All Total Software Inventory within 30 Days machines details ............................................................................... 62
109. All Total Software Inventory not within 30 Days machines details ......................................................................... 62
110. All Total WSUS Scan within 30 Days machines details ......................................................................................... 63
111. All Total WSUS Scan not within 30 Days machines details ................................................................................... 63
112. All Deployments status for Specific Application ..................................................................................................... 63
113. All Deployments status for Specific Package ......................................................................................................... 64
114. All Deployments status for Specific Software Update Group ................................................................................. 64
115. All Deployments status for Specific Task Sequence .............................................................................................. 65
116. Deployment Detailed status for specific application with specific collection .......................................................... 65
117. Deployment Detailed status for specific application ............................................................................................... 66
118. Deployment Detailed status for specific package with specific collection .............................................................. 67
119. Deployment Detailed status for specific package ................................................................................................... 68
120. Deployment Detailed status for specific software Update deployment .................................................................. 68
121. All Collections with RefreshType ............................................................................................................................ 69
122. All Software Inventory Report for Specific Computer Based on Installed Software Class ..................................... 69
123. All Applications Deployments Status for Specific Computers ................................................................................ 69
124. Specific Software Update Deployment Failed Errors with Description ................................................................... 69
125. AL_Designer Exe File and Path with version - Based on Software Inventory ........................................................ 70
126. Lync Exe File and Path with version - Based on Software Inventory ..................................................................... 70
127. All PCs with McAfee Antivirus Installed Machines Report Based on Installed Software ....................................... 71
128. All PCs without McAfee Antivirus Installed Machines Report Based on Installed Software .................................. 71
129. All PCs with McAfee DLP Installed Machines Report Based on Installed Software .............................................. 72
130. All PCs without McAfee DLP Installed Machines Report Based on Installed Software ......................................... 72
131. All Workstations Adobe Products Installed Machines Report ................................................................................ 73
132. All Servers Adobe Products Installed Machines Report ......................................................................................... 74
133. All Workstations Adobe Products Installed Machines with Disk Space Report ...................................................... 74
134. All Servers Adobe Products Installed Machines with Disk Space Report .............................................................. 75
135. Deployments status for specific applications .......................................................................................................... 77
136. Deployments status for specific packages ............................................................................................................. 78
137. Deployment status for specific software Update deployments ............................................................................... 78
138. Find SQL Server Installed Version ......................................................................................................................... 78
139. Find SCCM SQL Database Size with Database File Path ..................................................................................... 78
140. Find Overall SCCM Site Hierarchy Information ...................................................................................................... 79
141. Find SCCM Site Hierarchy Detailed Information .................................................................................................... 79
142. Find Overall Windows Workstations Client Machines OS category with counts .................................................... 79
143. Find Overall Windows Servers Client Machines OS category with counts ............................................................ 80
144. Find Overall WSUS Server Configurations and Ports ............................................................................................ 80
145. SEP Antivirus with Specific Version Installed Machines Report Based on Installed Software .............................. 80
146. SEP Antivirus without Specific Version Installed Machines Report Based on Installed Software ......................... 81
147. All Application Installed on Specific Collection ....................................................................................................... 81
148. All Client Health Last Month SLA and KPI Data status .......................................................................................... 82
149. All Software Applications Last Month deployments SLA and KPI Data status....................................................... 83
150. All Software Packages Last Month deployments SLA and KPI Data status .......................................................... 84
151. All Software Updates Last Month deployments SLA and KPI Data status ............................................................. 84
152. All OS Last Month deployments SLA and KPI Data status .................................................................................... 85
153. Selected KB Article ID patch required or installed status for Specific Collection ID .............................................. 85
154. Selected KB Article ID patch required or installed status for Specific Collection ID .............................................. 86
155. Site Status Overview Status ................................................................................................................................... 86
156. Site Status Status ................................................................................................................................................... 87
157. Site Components Status ......................................................................................................................................... 87
158. Overall Content Distribution Status ........................................................................................................................ 88
159. Compare Two DP’s Packages Status .................................................................................................................... 88
160. Top Users for Specific Computer Status ................................................................................................................ 88
161. Software Update Group Created, Modified or Deleted Properties ......................................................................... 88
162. Software Update last month patch compliance report using Compliance Settings ................................................ 89
163. Client Health showing inactive or failed clients status ............................................................................................ 89
164. Check if allow clients to use fallback source location for content ........................................................................... 89
165. All Workstations Computers Name with Last Logon User and Serial No Detailed Report .................................... 90
166. Check Client Versions with Percentage ................................................................................................................. 91
167. Microsoft Installed application counts for a specific Collection............................................................................... 91
168. Client Health Dashboard......................................................................................................................................... 92
169. Client Version with Percentage .............................................................................................................................. 93
170. Compare packages with Another DP ..................................................................................................................... 93
171. OneDrivesetup and Groove application report based on Software Inventory ........................................................ 94
172. All SCCM Servers Inventory status ........................................................................................................................ 94
173. All Workstations Assets Inventory details status .................................................................................................... 96
174. All ConfigMgr roles status ....................................................................................................................................... 97
175. All ConfigMgr Roles Detailed status ....................................................................................................................... 98
176. All Software applications deployments status ........................................................................................................ 98
177. All Software packages deployments status ............................................................................................................ 99
178. All Software updates deployments status ............................................................................................................... 99
179. All Operating systems deployments status ........................................................................................................... 100
 */

-- 1. A Specific System Is Part of what are all Collections 
DECLARE @Name VARCHAR(255)

SET @Name = 'CLIENT01' --Provide Computer Name

SELECT vrs.Name0,
	fcm.CollectionID,
	Col.name AS 'CollectionName',
	vrs.Client0
FROM v_R_System AS VRS
INNER JOIN v_FullCollectionMembership AS FCM ON VRS.ResourceID = FCM.resourceID
INNER JOIN v_Collection AS Col ON fcm.CollectionID = col.CollectionID
WHERE VRS.Name0 = @Name
	AND col.CollectionID NOT LIKE 'SMS%'
ORDER BY col.Name

-- 2. All Users Names Part of specific AD Group 
DECLARE @GroupName VARCHAR(255)

SET @GroupName = '%LAB-SCCM_Device_Adobe_Acrobat_Reader_11.0.03_EN%' -- Provide Group Name

SELECT vrug.User_Group_Name0 AS GroupName,
	Vru.Name0 AS Username
FROM v_R_User AS Vru
INNER JOIN v_RA_User_UserGroupName AS Vrug ON Vru.ResourceID = Vrug.ResourceID
WHERE Vrug.User_Group_Name0 LIKE @GroupName

-- 3. Package Deployment Detailed status for specific Advertisement ID 
DECLARE @AdvID VARCHAR(255)

SET @AdvID = '00020001' --Advertisement ID

SELECT vca.AdvertisementID,
	vc.Name AS 'CollectionName',
	vrs.Name0,
	vrs.User_Name0,
	vrs.AD_Site_Name0,
	vca.LastAcceptanceStateName,
	vca.LastAcceptanceStatusTime,
	vca.LastStateName,
	vca.LastStatusMessageIDName,
	vca.LastExecutionResult
FROM v_Advertisement AS Va
INNER JOIN v_ClientAdvertisementStatus AS Vca ON va.AdvertisementID = vca.AdvertisementID
INNER JOIN v_R_System AS Vrs ON vca.ResourceID = vrs.ResourceID
INNER JOIN v_Collection AS Vc ON va.CollectionID = vc.CollectionID
WHERE va.AdvertisementID = @AdvID
ORDER BY vca.LastStateName

-- 4. All SQL Server Installed Version and Computer Details using Hardware Inventory 
DECLARE @SoftwareName VARCHAR(255)

SET @SoftwareName = '%Microsoft SQL Server%'

SELECT DISTINCT vrs.Name0,
	vrs.User_Name0,
	vga.DisplayName0,
	vga.InstallDate0,
	vga.Publisher0,
	vga.ProdID0
FROM v_R_System AS Vrs
INNER JOIN v_GS_ADD_REMOVE_PROGRAMS_64 AS Vga ON Vrs.ResourceID = Vga.ResourceID
WHERE Vga.DisplayName0 LIKE @SoftwareName
	AND vga.Publisher0 IS NOT NULL

-- 5. All Computers with Last Heartbeat Discovery Time Stamp 
SELECT vrs.Name0 AS 'ComputerName',
	vrs.Client0 AS 'Client',
	vrs.Operating_System_Name_and0 AS 'Operating System',
	Vad.AgentTime AS 'LastHeartBeatTime'
FROM v_R_System AS Vrs
INNER JOIN v_AgentDiscoveries AS Vad ON Vrs.ResourceID = Vad.ResourceId
WHERE vad.AgentName LIKE '%Heartbeat Discovery'

-- 6. All IE Version using Software Inventory 
DECLARE @EXEName VARCHAR(255)
DECLARE @EXEPath VARCHAR(255)

SET @EXEName = 'IExplore%'
SET @EXEPath = '_:\Program Files\Internet Explorer\'

SELECT vrs.Name0,
	vrs.User_Name0,
	vrs.AD_Site_Name0,
	vgs.FileName,
	CASE 
		WHEN vgs.FileVersion LIKE '5.%'
			THEN 'Internet Explorer 5'
		WHEN vgs.FileVersion LIKE '6.%'
			THEN 'Internet Explorer 6'
		WHEN vgs.FileVersion LIKE '7.%'
			THEN 'Internet Explorer 7'
		WHEN vgs.FileVersion LIKE '8.%'
			THEN 'Internet Explorer 8'
		WHEN vgs.FileVersion LIKE '9.%'
			THEN 'Internet Explorer 9'
		WHEN vgs.FileVersion LIKE '10.%'
			THEN 'Internet Explorer 10'
		WHEN vgs.FileVersion LIKE '11.%'
			THEN 'Internet Explorer 11'
		ELSE 'Other Version'
		END AS 'IE Version',
	vgs.FilePath,
	vgs.FileVersion
FROM v_R_System AS Vrs
JOIN v_GS_SoftwareFile AS Vgs ON vrs.ResourceID = vgs.ResourceID
WHERE vgs.FileName LIKE @EXEName
	AND vgs.FilePath LIKE @EXEPath
	-- AND vrs.Name0 IN ('XXXXX', 'xxxxx1')
ORDER BY vrs.Name0

-- 7. All Packages Total Targeted DP Counts
SELECT vp.PackageID,
	vp.Name,
	CASE vp.PackageType
		WHEN 0
			THEN 'Package'
		WHEN 3
			THEN 'Driver'
		WHEN 4
			THEN 'Task Sequence'
		WHEN 5
			THEN 'software Update'
		WHEN 7
			THEN 'Virtual'
		WHEN 8
			THEN 'Application'
		WHEN 257
			THEN 'Image'
		WHEN 258
			THEN 'Boot Image'
		WHEN 259
			THEN 'OS'
		ELSE ' '
		END AS 'PackageType',
	vp.Manufacturer,
	vp.Version,
	vp.LANGUAGE,
	(pkgs.SourceSize / 1024) AS 'Package Size (MB)',
	vp.PkgSourcePath,
	vp.SourceVersion,
	vp.SourceDate,
	Pkgs.Targeted,
	pkgs.Installed,
	pkgs.Pending,
	pkgs.Retrying,
	pkgs.Failed,
	pkgs.UNKNOWN
FROM vPkgStatusSummary AS Pkgs
INNER JOIN v_Package AS Vp ON pkgs.PkgID = vp.PackageID
ORDER BY 3

-- 8. All Packages Compare targeted Packages on Two DPS
SELECT s.SiteCode,
	s.PackageID,
	p.Name,
	(p.sourcesize) / 1024 AS 'Size(MB)',
	s.sourceversion AS 'DPVersion',
	p.storedpkgversion AS 'LastVersion',
	s.Installstatus AS 'Package Status',
	CASE v_Package.PackageType
		WHEN 0
			THEN 'Package'
		WHEN 3
			THEN 'Driver'
		WHEN 4
			THEN 'Task Sequence'
		WHEN 5
			THEN 'software Update'
		WHEN 7
			THEN 'Virtual'
		WHEN 8
			THEN 'Application'
		WHEN 257
			THEN 'Image'
		WHEN 258
			THEN 'Boot Image'
		WHEN 259
			THEN 'OS'
		ELSE ' '
		END AS 'Type'
FROM v_PackageStatusDistPointsSumm s
INNER JOIN smspackages p ON s.packageid = p.pkgid
INNER JOIN v_Package ON v_Package.PackageID = p.[PkgID]
WHERE s.PackageID NOT IN (
		SELECT PackageID
		FROM v_DistributionPoint
		WHERE ServerNALPath LIKE '%DPServerName1%'
		)
	AND ServerNALPath LIKE '%DPServerName1%'
ORDER BY 8

-- 9. Compare Packages with two DP’S 
SELECT Pkg.PackageID,
	Pkg.Name,
	CASE Pkg.PackageType
		WHEN 0
			THEN 'Package'
		WHEN 3
			THEN 'Driver'
		WHEN 4
			THEN 'TaskSequence'
		WHEN 5
			THEN 'softwareUpdate'
		WHEN 7
			THEN 'Virtual'
		WHEN 8
			THEN 'Application'
		WHEN 257
			THEN 'Image'
		WHEN 258
			THEN 'BootImage'
		WHEN 259
			THEN 'OS'
		ELSE ' '
		END AS 'Type'
FROM v_Package Pkg
WHERE Pkg.PackageID IN (
		SELECT PackageID
		FROM v_DistributionPoint
		WHERE ServerNALPath LIKE '%Master DP Name%'
			AND PackageID NOT IN (
				SELECT PackageID
				FROM v_DistributionPoint
				WHERE ServerNALPath LIKE '%Compare DP Name%'
				)
		)
ORDER BY 3

-- 10. All Software Distribution Packages without Advertisements
SELECT v_Package.PackageID,
	v_Package.Name,
	v_Package.SourceVersion,
	v_Package.SourceDate
FROM dbo.v_package
WHERE packageID NOT IN (
		SELECT PackageID
		FROM dbo.v_Advertisement
		)
	AND PackageID NOT IN (
		SELECT ReferencePackageID
		FROM v_TaskSequenceReferencesInfo
		)
	AND v_Package.name NOT LIKE '%osd%'
	AND V_package.PackageType = '0'
GROUP BY v_Package.PackageID,
	v_Package.Name,
	v_Package.SourceVersion,
	v_Package.SourceDate
ORDER BY v_Package.PackageID

-- 11. All Client Settings Status
SELECT *
FROM v_CH_Settings
WHERE SettingsID = 1

-- 12. All Workstations Agent Health Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @Total AS NUMERIC(8)
DECLARE @Healthy AS NUMERIC(8)
DECLARE @Unhealthy AS NUMERIC(8)
DECLARE @HWInventoryOK AS NUMERIC(8)
DECLARE @HWInventoryNotOK AS NUMERIC(8)
DECLARE @SWInventoryOK AS NUMERIC(8)
DECLARE @SWInventoryNotOK AS NUMERIC(8)
DECLARE @WSUSInventoryOK AS NUMERIC(8)
DECLARE @WSUSInventoryNotOK AS NUMERIC(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT @Total = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @Healthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @Unhealthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsActive = 1
					AND IsObsolete = 0
					AND IsClient = 1
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @HWInventoryOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Workstation%'
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_WORKSTATION_STATUS
				WHERE DATEDIFF(day, LastHWScan, GetDate()) < 30
				)
		)

SELECT @HWInventoryNotOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Workstation%'
				)
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_GS_WORKSTATION_STATUS
				WHERE DATEDIFF(day, LastHWScan, GetDate()) < 30
				)
		)

SELECT @SWInventoryOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Workstation%'
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_LastSoftwareScan
				WHERE DATEDIFF(day, LastScanDate, GetDate()) < 30
				)
		)

SELECT @SWInventoryNotOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Workstation%'
				)
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_GS_LastSoftwareScan
				WHERE DATEDIFF(day, LastScanDate, GetDate()) < 30
				)
		)

SELECT @WSUSInventoryOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Workstation%'
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_UpdateScanStatus
				WHERE lastErrorCode = 0
					AND DATEDIFF(day, LastScanTime, GetDate()) < 30
				)
		)

SELECT @WSUSInventoryNotOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Workstation%'
				)
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_UpdateScanStatus
				WHERE lastErrorCode = 0
					AND DATEDIFF(day, LastScanTime, GetDate()) < 30
				)
		)

SELECT @Total AS 'Total',
	@Healthy AS 'Healthy',
	@Unhealthy AS 'Unhealthy',
	@HWInventoryOK AS 'HW<30Days',
	@HWInventoryNotOK AS 'HW>30Days',
	@SWInventoryOK AS 'SW<30Days',
	@SWInventoryNotOK AS 'SW>30Days',
	@WSUSInventoryOK AS 'WSUS<30Days',
	@WSUSInventoryNotOK AS 'WSUS>30Days',
	CASE 
		WHEN (@Total = 0)
			OR (@Total IS NULL)
			THEN '100'
		ELSE (round(@Healthy / convert(FLOAT, @Total) * 100, 2))
		END AS 'Healthy%',
	CASE 
		WHEN (@Healthy = 0)
			OR (@Healthy IS NULL)
			THEN '100'
		ELSE (round(@HWInventoryOK / convert(FLOAT, @Healthy) * 100, 2))
		END AS 'HW%',
	CASE 
		WHEN (@Healthy = 0)
			OR (@Healthy IS NULL)
			THEN '100'
		ELSE (round(@SWInventoryOK / convert(FLOAT, @Healthy) * 100, 2))
		END AS 'SW%',
	CASE 
		WHEN (@Healthy = 0)
			OR (@Healthy IS NULL)
			THEN '100'
		ELSE (round(@WSUSInventoryOK / convert(FLOAT, @Healthy) * 100, 2))
		END AS 'WSUS%'

-- 13. All Servers Agent Health Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @Total AS NUMERIC(8)
DECLARE @Healthy AS NUMERIC(8)
DECLARE @Unhealthy AS NUMERIC(8)
DECLARE @HWInventoryOK AS NUMERIC(8)
DECLARE @HWInventoryNotOK AS NUMERIC(8)
DECLARE @SWInventoryOK AS NUMERIC(8)
DECLARE @SWInventoryNotOK AS NUMERIC(8)
DECLARE @WSUSInventoryOK AS NUMERIC(8)
DECLARE @WSUSInventoryNotOK AS NUMERIC(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT @Total = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
		)

SELECT @Healthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
		)

SELECT @Unhealthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsActive = 1
					AND IsObsolete = 0
					AND IsClient = 1
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
		)

SELECT @HWInventoryOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_WORKSTATION_STATUS
				WHERE DATEDIFF(day, LastHWScan, GetDate()) < 30
				)
		)

SELECT @HWInventoryNotOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_GS_WORKSTATION_STATUS
				WHERE DATEDIFF(day, LastHWScan, GetDate()) < 30
				)
		)

SELECT @SWInventoryOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_LastSoftwareScan
				WHERE DATEDIFF(day, LastScanDate, GetDate()) < 30
				)
		)

SELECT @SWInventoryNotOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_GS_LastSoftwareScan
				WHERE DATEDIFF(day, LastScanDate, GetDate()) < 30
				)
		)

SELECT @WSUSInventoryOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_UpdateScanStatus
				WHERE lastErrorCode = 0
					AND DATEDIFF(day, LastScanTime, GetDate()) < 30
				)
		)

SELECT @WSUSInventoryNotOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_UpdateScanStatus
				WHERE lastErrorCode = 0
					AND DATEDIFF(day, LastScanTime, GetDate()) < 30
				)
		)

SELECT @Total AS 'Total',
	@Healthy AS 'Healthy',
	@Unhealthy AS 'Unhealthy',
	@HWInventoryOK AS 'HW<30Days',
	@HWInventoryNotOK AS 'HW>30Days',
	@SWInventoryOK AS 'SW<30Days',
	@SWInventoryNotOK AS 'SW>30Days',
	@WSUSInventoryOK AS 'WSUS<30Days',
	@WSUSInventoryNotOK AS 'WSUS>30Days',
	CASE 
		WHEN (@Total = 0)
			OR (@Total IS NULL)
			THEN '0'
		ELSE (round(@Healthy / convert(FLOAT, @Total) * 100, 2))
		END AS 'Healthy%',
	CASE 
		WHEN (@Healthy = 0)
			OR (@Healthy IS NULL)
			THEN '0'
		ELSE (round(@HWInventoryOK / convert(FLOAT, @Healthy) * 100, 2))
		END AS 'HW%',
	CASE 
		WHEN (@Healthy = 0)
			OR (@Healthy IS NULL)
			THEN '0'
		ELSE (round(@SWInventoryOK / convert(FLOAT, @Healthy) * 100, 2))
		END AS 'SW%',
	CASE 
		WHEN (@Healthy = 0)
			OR (@Healthy IS NULL)
			THEN '0'
		ELSE (round(@WSUSInventoryOK / convert(FLOAT, @Healthy) * 100, 2))
		END AS 'WSUS%'

DECLARE @CollectionID AS VARCHAR(8)
DECLARE @Total AS NUMERIC(8)
DECLARE @Healthy AS NUMERIC(8)
DECLARE @Unhealthy AS NUMERIC(8)
DECLARE @HWInventoryOK AS NUMERIC(8)
DECLARE @HWInventoryNotOK AS NUMERIC(8)
DECLARE @SWInventoryOK AS NUMERIC(8)
DECLARE @SWInventoryNotOK AS NUMERIC(8)
DECLARE @WSUSInventoryOK AS NUMERIC(8)
DECLARE @WSUSInventoryNotOK AS NUMERIC(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID 

SELECT @Total = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
		)

SELECT @Healthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
		)

SELECT @Unhealthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsActive = 1
					AND IsObsolete = 0
					AND IsClient = 1
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
		)

SELECT @HWInventoryOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_WORKSTATION_STATUS
				WHERE DATEDIFF(day, LastHWScan, GetDate()) < 30
				)
		)

SELECT @HWInventoryNotOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_GS_WORKSTATION_STATUS
				WHERE DATEDIFF(day, LastHWScan, GetDate()) < 30
				)
		)

SELECT @SWInventoryOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_LastSoftwareScan
				WHERE DATEDIFF(day, LastScanDate, GetDate()) < 30
				)
		)

SELECT @SWInventoryNotOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_GS_LastSoftwareScan
				WHERE DATEDIFF(day, LastScanDate, GetDate()) < 30
				)
		)

SELECT @WSUSInventoryOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_UpdateScanStatus
				WHERE lastErrorCode = 0
					AND DATEDIFF(day, LastScanTime, GetDate()) < 30
				)
		)

SELECT @WSUSInventoryNotOK = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete = 0
			AND IsClient = 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Operating_System_Name_and0 LIKE '%Server%'
				)
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_UpdateScanStatus
				WHERE lastErrorCode = 0
					AND DATEDIFF(day, LastScanTime, GetDate()) < 30
				)
		)

SELECT @Total AS 'Total',
	@Healthy AS 'Healthy',
	@Unhealthy AS 'Unhealthy',
	@HWInventoryOK AS 'HW<30Days',
	@HWInventoryNotOK AS 'HW>30Days',
	@SWInventoryOK AS 'SW<30Days',
	@SWInventoryNotOK AS 'SW>30Days',
	@WSUSInventoryOK AS 'WSUS<30Days',
	@WSUSInventoryNotOK AS 'WSUS>30Days',
	CASE 
		WHEN (@Total = 0)
			OR (@Total IS NULL)
			THEN '0'
		ELSE (round(@Healthy / convert(FLOAT, @Total) * 100, 2))
		END AS 'Healthy%',
	CASE 
		WHEN (@Healthy = 0)
			OR (@Healthy IS NULL)
			THEN '0'
		ELSE (round(@HWInventoryOK / convert(FLOAT, @Healthy) * 100, 2))
		END AS 'HW%',
	CASE 
		WHEN (@Healthy = 0)
			OR (@Healthy IS NULL)
			THEN '0'
		ELSE (round(@SWInventoryOK / convert(FLOAT, @Healthy) * 100, 2))
		END AS 'SW%',
	CASE 
		WHEN (@Healthy = 0)
			OR (@Healthy IS NULL)
			THEN '0'
		ELSE (round(@WSUSInventoryOK / convert(FLOAT, @Healthy) * 100, 2))
		END AS 'WSUS%'

-- 14. All Workstations Agent Detailed Health Status
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT DISTINCT (Name),
	CASE 
		WHEN IsClient = 1
			THEN 'Healthy'
		ELSE 'Unhealthy'
		END AS 'HealthStatus',
	(
		SELECT CASE 
				WHEN count(v_GS_WORKSTATION_STATUS.ResourceID) = 1
					THEN 'Healthy'
				ELSE 'Unhealthy'
				END
		FROM v_GS_WORKSTATION_STATUS
		WHERE DATEDIFF(day, LastHWScan, GetDate()) < 31
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'HWScanStatus',
	(
		SELECT CASE 
				WHEN count(v_GS_LastSoftwareScan.ResourceID) = 1
					THEN 'Healthy'
				ELSE 'Unhealthy'
				END
		FROM v_GS_LastSoftwareScan
		WHERE DATEDIFF(day, LastScanDate, GetDate()) < 31
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'SWScanStatus',
	(
		SELECT CASE 
				WHEN count(v_UpdateScanStatus.ResourceID) = 1
					THEN 'Healthy'
				ELSE 'Unhealthy'
				END
		FROM v_UpdateScanStatus
		WHERE DATEDIFF(day, LastScanTime, GetDate()) < 31
			AND LastErrorCode = 0
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'WSUSScanStatus',
	(
		SELECT DATEDIFF(day, LastHWScan, GetDate())
		FROM v_GS_WORKSTATION_STATUS
		WHERE ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'LastHWScanDays',
	(
		SELECT DATEDIFF(day, LastScanDate, GetDate())
		FROM v_GS_LastSoftwareScan
		WHERE ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'LastSWScanDays',
	(
		SELECT DATEDIFF(day, LastScanTime, GetDate())
		FROM v_UpdateScanStatus
		WHERE LastErrorCode = 0
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'LastWSUSScanDays'
FROM v_FullCollectionMembership
WHERE CollectionID = @CollectionID
	AND ResourceID IN (
		SELECT ResourceID
		FROM v_R_System
		WHERE Operating_System_Name_and0 LIKE '%Workstation%'
		)
ORDER BY 2 DESC

-- 15. All Servers Agent Detailed Health Status 
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT DISTINCT (Name),
	CASE 
		WHEN IsClient = 1
			THEN 'Healthy'
		ELSE 'Unhealthy'
		END AS 'HealthStatus',
	(
		SELECT CASE 
				WHEN count(v_GS_WORKSTATION_STATUS.ResourceID) = 1
					THEN 'Healthy'
				ELSE 'Unhealthy'
				END
		FROM v_GS_WORKSTATION_STATUS
		WHERE DATEDIFF(day, LastHWScan, GetDate()) < 31
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'HWScanStatus',
	(
		SELECT CASE 
				WHEN count(v_GS_LastSoftwareScan.ResourceID) = 1
					THEN 'Healthy'
				ELSE 'Unhealthy'
				END
		FROM v_GS_LastSoftwareScan
		WHERE DATEDIFF(day, LastScanDate, GetDate()) < 31
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'SWScanStatus',
	(
		SELECT CASE 
				WHEN count(v_UpdateScanStatus.ResourceID) = 1
					THEN 'Healthy'
				ELSE 'Unhealthy'
				END
		FROM v_UpdateScanStatus
		WHERE DATEDIFF(day, LastScanTime, GetDate()) < 31
			AND LastErrorCode = 0
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'WSUSScanStatus',
	(
		SELECT DATEDIFF(day, LastHWScan, GetDate())
		FROM v_GS_WORKSTATION_STATUS
		WHERE ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'LastHWScanDays',
	(
		SELECT DATEDIFF(day, LastScanDate, GetDate())
		FROM v_GS_LastSoftwareScan
		WHERE ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'LastSWScanDays',
	(
		SELECT DATEDIFF(day, LastScanTime, GetDate())
		FROM v_UpdateScanStatus
		WHERE LastErrorCode = 0
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'LastWSUSScanDays'
FROM v_FullCollectionMembership
WHERE CollectionID = @CollectionID
	AND ResourceID IN (
		SELECT ResourceID
		FROM v_R_System
		WHERE Operating_System_Name_and0 LIKE '%Server%'
		)
ORDER BY 2 DESC

-- 16. All Workstations Client Health Summary Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalClient AS NUMERIC(8)
DECLARE @ClientInstalled AS NUMERIC(8)
DECLARE @ClientNotInstalled AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalClient = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE (
						Client0 = 1
						OR Client0 = 0
						OR Client0 IS NULL
						)
					AND Unknown0 IS NULL
					AND Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ClientInstalled = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Client0 = 1
					AND Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ClientNotInstalled = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE (
						Client0 = 0
						OR Client0 IS NULL
						)
					AND Unknown0 IS NULL
					AND Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @TotalClient AS 'TotalClient',
	@ClientInstalled AS 'ClientInstalled',
	@ClientNotInstalled AS 'ClientNotInstalled',
	CASE 
		WHEN (@TotalClient = 0)
			OR (@TotalClient IS NULL)
			THEN '100'
		ELSE (round(@ClientInstalled / convert(FLOAT, @TotalClient) * 100, 2))
		END AS 'ClientInstalled%'

-- 17. All Servers Client Health Summary Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalClient AS NUMERIC(8)
DECLARE @ClientInstalled AS NUMERIC(8)
DECLARE @ClientNotInstalled AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalClient = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE (
						Client0 = 1
						OR Client0 = 0
						OR Client0 IS NULL
						)
					AND Unknown0 IS NULL
					AND Operating_System_Name_and0 LIKE '%Server%'
				)
		)

SELECT @ClientInstalled = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE Client0 = 1
					AND Operating_System_Name_and0 LIKE '%Server%'
				)
		)

SELECT @ClientNotInstalled = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_R_System
				WHERE (
						Client0 = 0
						OR Client0 IS NULL
						)
					AND Unknown0 IS NULL
					AND Operating_System_Name_and0 LIKE '%Server%'
				)
		)

SELECT @TotalClient AS 'TotalClient',
	@ClientInstalled AS 'ClientInstalled',
	@ClientNotInstalled AS 'ClientNotInstalled',
	CASE 
		WHEN (@TotalClient = 0)
			OR (@TotalClient IS NULL)
			THEN '100'
		ELSE (round(@ClientInstalled / convert(FLOAT, @TotalClient) * 100, 2))
		END AS 'ClientInstalled%'

-- 18. All Active and Inactive Workstations Client Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalClientInstalled AS NUMERIC(8)
DECLARE @ClientActive AS NUMERIC(8)
DECLARE @ClientInActive AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalClientInstalled = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						Ch.ClientActiveStatus = 1
						OR Ch.ClientActiveStatus = 0
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ClientActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ClientInActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 0)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @TotalClientInstalled AS 'TotalClientInstalled',
	@ClientActive AS 'ClientActive',
	@ClientInActive AS 'ClientInActive',
	CASE 
		WHEN (@TotalClientInstalled = 0)
			OR (@TotalClientInstalled IS NULL)
			THEN '100'
		ELSE (round(@ClientActive / convert(FLOAT, @TotalClientInstalled) * 100, 2))
		END AS 'ClientActive%'

-- 19. All Active and Inactive Servers Client Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalClientInstalled AS NUMERIC(8)
DECLARE @ClientActive AS NUMERIC(8)
DECLARE @ClientInActive AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalClientInstalled = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						Ch.ClientActiveStatus = 1
						OR Ch.ClientActiveStatus = 0
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @ClientActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @ClientInActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 0)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @TotalClientInstalled AS 'TotalClientInstalled',
	@ClientActive AS 'ClientActive',
	@ClientInActive AS 'ClientInActive',
	CASE 
		WHEN (@TotalClientInstalled = 0)
			OR (@TotalClientInstalled IS NULL)
			THEN '100'
		ELSE (round(@ClientActive / convert(FLOAT, @TotalClientInstalled) * 100, 2))
		END AS 'ClientActive%'

-- 20. All Active Workstations Client Health Evaluation Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActiveEvalPass AS NUMERIC(8)
DECLARE @ActiveEvalFail AS NUMERIC(8)
DECLARE @ActiveEvalUnknown AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						Ch.ClientStateDescription = 'Active/Pass'
						OR Ch.ClientStateDescription = 'Active/Fail'
						OR Ch.ClientStateDescription = 'Active/Unknown'
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ActiveEvalPass = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientStateDescription = 'Active/Pass')
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ActiveEvalFail = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientStateDescription = 'Active/Fail')
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ActiveEvalUnknown = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientStateDescription = 'Active/Unknown')
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActiveEvalPass AS 'ActiveEvalPass',
	@ActiveEvalFail AS 'ActiveEvalFail',
	@ActiveEvalUnknown AS 'ActiveEvalUnknown',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActiveEvalPass / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActiveEvalPass%'

-- 21. All Active Servers Client Health Evaluation Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActiveEvalPass AS NUMERIC(8)
DECLARE @ActiveEvalFail AS NUMERIC(8)
DECLARE @ActiveEvalUnknown AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						Ch.ClientStateDescription = 'Active/Pass'
						OR Ch.ClientStateDescription = 'Active/Fail'
						OR Ch.ClientStateDescription = 'Active/Unknown'
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @ActiveEvalPass = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientStateDescription = 'Active/Pass')
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @ActiveEvalFail = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientStateDescription = 'Active/Fail')
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @ActiveEvalUnknown = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientStateDescription = 'Active/Unknown')
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActiveEvalPass AS 'ActiveEvalPass',
	@ActiveEvalFail AS 'ActiveEvalFail',
	@ActiveEvalUnknown AS 'ActiveEvalUnknown',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActiveEvalPass / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActiveEvalPass%'

-- 22. All Active Workstations Client Heartbeat (DDR) Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActiveHeartBeatDDR AS NUMERIC(8)
DECLARE @InActiveHeartBeatDDR AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ActiveHeartBeatDDR = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveDDR = 1
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @InActiveHeartBeatDDR = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveDDR = 0
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActiveHeartBeatDDR AS 'ActiveHeartBeatDDR',
	@InActiveHeartBeatDDR AS 'InActiveHeartBeatDDR',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActiveHeartBeatDDR / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActiveHeartBeatDDR%'

-- 23. All Active Servers Client Heartbeat (DDR) Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActiveHeartBeatDDR AS NUMERIC(8)
DECLARE @InActiveHeartBeatDDR AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @ActiveHeartBeatDDR = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveDDR = 1
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @InActiveHeartBeatDDR = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveDDR = 0
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActiveHeartBeatDDR AS 'ActiveHeartBeatDDR',
	@InActiveHeartBeatDDR AS 'InActiveHeartBeatDDR',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActiveHeartBeatDDR / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActiveHeartBeatDDR%'

-- 24. All Active Workstations Client Hardware Inventory Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActiveHWInv AS NUMERIC(8)
DECLARE @InActiveHWInv AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ActiveHWInv = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveHW = 1
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @InActiveHWInv = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveHW = 0
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActiveHWInv AS 'ActiveHWInv',
	@InActiveHWInv AS 'InActiveHWInv',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActiveHWInv / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActiveHWInv%'

-- 25. All Active Servers Client Hardware Inventory Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActiveHWInv AS NUMERIC(8)
DECLARE @InActiveHWInv AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @ActiveHWInv = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveHW = 1
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @InActiveHWInv = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveHW = 0
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActiveHWInv AS 'ActiveHWInv',
	@InActiveHWInv AS 'InActiveHWInv',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActiveHWInv / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActiveHWInv%'

-- 26. All Active Workstations Client Software Inventory Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActiveSWInv AS NUMERIC(8)
DECLARE @InActiveSWInv AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ActiveSWInv = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveSW = 1
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @InActiveSWInv = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveSW = 0
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActiveSWInv AS 'ActiveSWInv',
	@InActiveSWInv AS 'InActiveSWInv',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActiveSWInv / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActiveSWInv%'

-- 27. All Active Servers Client Software Inventory Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActiveSWInv AS NUMERIC(8)
DECLARE @InActiveSWInv AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @ActiveSWInv = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveSW = 1
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @InActiveSWInv = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActiveSW = 0
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActiveSWInv AS 'ActiveSWInv',
	@InActiveSWInv AS 'InActiveSWInv',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActiveSWInv / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActiveSWInv%'

-- 28. All Active Workstations Client Policy Request Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActivePolicyRequest AS NUMERIC(8)
DECLARE @InActivePolicyRequest AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @ActivePolicyRequest = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActivePolicyRequest = 1
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @InActivePolicyRequest = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActivePolicyRequest = 0
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActivePolicyRequest AS 'ActivePolicyRequest',
	@InActivePolicyRequest AS 'InActivePolicyRequest',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActivePolicyRequest / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActivePolicyRequest%'

-- 29. All Active Servers Client Policy Request Status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalActive AS NUMERIC(8)
DECLARE @ActivePolicyRequest AS NUMERIC(8)
DECLARE @InActivePolicyRequest AS NUMERIC(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT @TotalActive = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (Ch.ClientActiveStatus = 1)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @ActivePolicyRequest = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActivePolicyRequest = 1
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @InActivePolicyRequest = (
		SELECT COUNT(*) AS 'Count'
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND v_FullCollectionMembership.ResourceID IN (
				SELECT Vrs.ResourceID
				FROM v_R_System Vrs
				INNER JOIN v_CH_ClientSummary Ch ON Vrs.ResourceID = ch.ResourceID
				WHERE (
						IsActivePolicyRequest = 0
						AND ClientActiveStatus = 1
						)
					AND Vrs.Operating_System_Name_and0 LIKE '%Servers%'
				)
		)

SELECT @TotalActive AS 'TotalActive',
	@ActivePolicyRequest AS 'ActivePolicyRequest',
	@InActivePolicyRequest AS 'InActivePolicyRequest',
	CASE 
		WHEN (@TotalActive = 0)
			OR (@TotalActive IS NULL)
			THEN '100'
		ELSE (round(@ActivePolicyRequest / convert(FLOAT, @TotalActive) * 100, 2))
		END AS 'ActivePolicyRequest%'

-- 30. All PCs discovered from specific site
SELECT agent.AgentSite,
	sys.Netbios_Name0,
	sys.Resource_Domain_OR_Workgr0,
	MAX(AgentTime) AS AgentTime
FROM v_R_System sys
JOIN v_AgentDiscoveries agent ON sys.ResourceID = agent.ResourceId
WHERE agent.AgentSite = 'A00'
GROUP BY agent.AgentSite,
	sys.Netbios_Name0,
	sys.Resource_Domain_OR_Workgr0
ORDER BY agent.AgentSite,
	Netbios_Name0

-- 31. All PCs Information with IP address and subnet details
DECLARE @CollectionID VARCHAR(8)

SET @CollectionID = 'SMS00001'

SELECT vrs.Name0,
	vrs.User_Name0 AS 'LastUserName',
	vos.Caption0,
	vos.CSDVersion0,
	vos.InstallDate0,
	vpb.Manufacturer0,
	vgc.Model0,
	vpb.SerialNumber0,
	vos.LastBootUpTime0,
	(vd.Size0 / 1024) AS 'HDDSize GB)',
	(vpm.TotalPhysicalMemory0 / 1024 / 1024) AS 'RAMSize GB',
	gna.IPAddress0,
	gna.DefaultIPGateway0,
	gna.DHCPServer0,
	CASE gna.DHCPEnabled0
		WHEN 1
			THEN 'Yes'
		ELSE 'No'
		END AS 'DHCPEnabled',
	gna.IPSubnet0,
	gna.MACAddress0,
	vrs.AD_Site_Name0,
	CASE Vrs.client0
		WHEN 1
			THEN 'Yes'
		ELSE 'No'
		END AS 'Client',
	CASE vrs.Active0
		WHEN 1
			THEN 'Active'
		ELSE 'No'
		END AS 'Active'
FROM v_R_System AS Vrs
INNER JOIN v_FullCollectionMembership AS Vfc ON vrs.ResourceID = vfc.ResourceID
LEFT JOIN v_GS_NETWORK_ADAPTER_CONFIGUR AS GNA ON vrs.ResourceID = gna.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM AS VOS ON vrs.ResourceID = vos.ResourceID
LEFT JOIN v_GS_DISK AS VD ON vrs.ResourceID = vd.ResourceID
LEFT JOIN v_GS_X86_PC_MEMORY AS VPM ON vrs.ResourceID = vpm.ResourceID
LEFT JOIN v_GS_PC_BIOS AS VPB ON vrs.ResourceID = vpb.ResourceID
LEFT JOIN v_GS_COMPUTER_SYSTEM AS VGC ON vrs.ResourceID = vgc.ResourceID
WHERE vfc.CollectionID = @CollectionID
	AND GNA.IPAddress0 IS NOT NULL
	AND vd.MediaType0 LIKE 'Fixed hard disk media'

-- 32. All PCs with chassis type information
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT DISTINCT (v_R_System.ResourceID),
	v_R_System.Name0 AS 'Machine Name',
	AD_Site_Name0 AS 'AD Site',
	v_R_System.Operating_System_Name_and0 AS 'Operating System',
	v_RA_System_SMSInstalledSites.SMS_Installed_Sites0 AS 'Installed Site',
	'Chassis Type' = CASE 
		WHEN ChassisTypes0 = 1
			THEN 'Virtual Machine'
		WHEN ChassisTypes0 = 2
			THEN 'Unknown'
		WHEN ChassisTypes0 = 3
			THEN 'Desktop'
		WHEN ChassisTypes0 = 4
			THEN 'Low-profile Desktop'
		WHEN ChassisTypes0 = 5
			THEN 'Pizza Box'
		WHEN ChassisTypes0 = 6
			THEN 'Mini Tower'
		WHEN ChassisTypes0 = 7
			THEN 'Tower'
		WHEN ChassisTypes0 = 8
			THEN 'Portable'
		WHEN ChassisTypes0 = 9
			THEN 'Laptop'
		WHEN ChassisTypes0 = 10
			THEN 'Notebook'
		WHEN ChassisTypes0 = 11
			THEN 'Handheld'
		WHEN ChassisTypes0 = 12
			THEN 'Docking Station'
		WHEN ChassisTypes0 = 13
			THEN 'All-in-One'
		WHEN ChassisTypes0 = 14
			THEN 'Subnotebook'
		WHEN ChassisTypes0 = 15
			THEN 'Space-Saving'
		WHEN ChassisTypes0 = 16
			THEN 'Lunch Box'
		WHEN ChassisTypes0 = 17
			THEN 'Main System chassis'
		WHEN ChassisTypes0 = 18
			THEN 'Expansion chassis'
		WHEN ChassisTypes0 = 19
			THEN 'Sub-Chassis'
		WHEN ChassisTypes0 = 20
			THEN 'Bus-expansion chassis'
		WHEN ChassisTypes0 = 21
			THEN 'Peripheral chassis'
		WHEN ChassisTypes0 = 22
			THEN 'Storage chassis'
		WHEN ChassisTypes0 = 23
			THEN 'Rack-mount chassis'
		WHEN ChassisTypes0 = 24
			THEN 'Sealed-case computer'
		END
FROM v_R_System
INNER JOIN v_GS_SYSTEM_ENCLOSURE ON (v_GS_SYSTEM_ENCLOSURE.ResourceID = v_R_System.ResourceID)
INNER JOIN v_RA_System_SMSInstalledSites ON (v_RA_System_SMSInstalledSites.ResourceID = v_R_System.ResourceID)
INNER JOIN v_FullCollectionMembership ON (v_FullCollectionMembership.ResourceID = v_R_System.ResourceID)
WHERE v_FullCollectionMembership.CollectionID = @CollectionID

-- 33. All Desktops and Laptops counts details
SELECT CASE 
		WHEN ChassisTypes0 = '8'
			THEN 'Notebooks'
		WHEN ChassisTypes0 = '9'
			THEN 'Notebooks'
		WHEN ChassisTypes0 = '10'
			THEN 'Notebooks'
		ELSE 'Desktops'
		END AS "Workstation Type",
	count(sys.name0) AS ClientCount
FROM v_R_System SYS
LEFT JOIN v_GS_SYSTEM_ENCLOSURE ENC ON ENC.ResourceID = SYS.ResourceID
LEFT JOIN v_FullCollectionMembership FCM ON FCM.ResourceID = ENC.ResourceID
WHERE FCM.CollectionID = 'Collection ID'
	AND sys.Obsolete0 = 0
GROUP BY CASE ChassisTypes0
		WHEN '8'
			THEN 'Notebooks'
		WHEN '9'
			THEN 'Notebooks'
		WHEN '10'
			THEN 'Notebooks'
		ELSE 'Desktops'
		END
ORDER BY 2 DESC

-- 34. All PCs Information with subnet and OU details
SELECT DISTINCT SYS.Netbios_Name0,
	SYS.User_Name0,
	OPSYS.InstallDate0 AS InitialInstall,
	BIOS.SerialNumber0,
	CSYS.Model0,
	MEM.TotalPhysicalMemory0,
	HWSCAN.LastHWScan,
	ASSG.SMS_Installed_Sites0,
	MAX(IPSub.IP_Subnets0) AS 'Subnet',
	OPSYS.Caption0 AS 'OS Name',
	MAX(SYSOU.System_OU_Name0) AS 'OU'
FROM v_R_System AS SYS
JOIN v_RA_System_SMSInstalledSites AS ASSG ON SYS.ResourceID = ASSG.ResourceID
LEFT JOIN v_RA_System_IPSubnets IPSub ON SYS.ResourceID = IPSub.ResourceID
LEFT JOIN v_GS_X86_PC_MEMORY MEM ON SYS.ResourceID = MEM.ResourceID
LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS ON SYS.ResourceID = CSYS.ResourceID
LEFT JOIN v_GS_PROCESSOR Processor ON Processor.ResourceID = SYS.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS ON SYS.ResourceID = OPSYS.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON SYS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_GS_LastSoftwareScan SWSCAN ON SYS.ResourceID = SWSCAN.ResourceID
LEFT JOIN v_GS_PC_BIOS BIOS ON SYS.ResourceID = BIOS.ResourceID
LEFT JOIN v_RA_System_SystemOUName SYSOU ON SYS.ResourceID = SYSOU.ResourceID
LEFT JOIN v_R_User USR ON SYS.User_Name0 = USR.User_Name0
LEFT JOIN v_FullCollectionMembership FCM ON FCM.ResourceID = SYS.ResourceID
WHERE SYS.Obsolete0 = 0
	AND FCM.CollectionID = 'Collection ID'
GROUP BY SYS.Netbios_Name0,
	SYS.Obsolete0,
	SYS.Resource_Domain_OR_Workgr0,
	CSYS.Manufacturer0,
	CSYS.Model0,
	BIOS.SerialNumber0,
	OPSYS.InstallDate0,
	HWSCAN.LastHWScan,
	MEM.TotalPhysicalMemory0,
	SYS.User_Name0,
	SYS.User_Domain0,
	ASSG.SMS_Installed_Sites0,
	SYS.Client_Version0,
	OPSYS.Caption0
ORDER BY OPSYS.InstallDate0 DESC

-- 35. All PCs with particular application last used date
DECLARE @Monthold INT

SET @Monthold = 2

SELECT DISTINCT SYS.Netbios_Name0 AS Name,
	SF.FileName,
	SF.FileDescription,
	SF.FileVersion,
	SF.FileSize,
	SF.FileModifiedDate,
	SF.FilePath,
	max(apps.LastUsedTime0) AS LastUsedTime,
	SYS.User_Name0 AS LOGIN,
	CSYS.Manufacturer0 AS Manufacturer,
	CSYS.Model0 AS Model,
	BIOS.SerialNumber0 AS SN,
	MAX(IPSub.IP_Subnets0) AS 'Subnet',
	sys.AD_Site_Name0 AS ADSite,
	MAX(SYSOU.System_OU_Name0) AS 'OU'
FROM v_GS_SoftwareFile SF
JOIN v_R_System SYS ON SYS.ResourceID = SF.ResourceID
LEFT JOIN v_RA_System_IPSubnets IPSub ON SYS.ResourceID = IPSub.ResourceID
LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS ON SYS.ResourceID = CSYS.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS ON SYS.ResourceID = OPSYS.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON SYS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_GS_PC_BIOS BIOS ON SYS.ResourceID = BIOS.ResourceID
LEFT JOIN v_RA_System_SystemOUName SYSOU ON SYS.ResourceID = SYSOU.ResourceID
LEFT JOIN v_R_User USR ON SYS.User_Name0 = USR.User_Name0
LEFT JOIN v_FullCollectionMembership FCM ON SYS.ResourceID = FCM.ResourceID
LEFT JOIN (
	SELECT *
	FROM v_GS_CCM_RECENTLY_USED_APPS
	WHERE ExplorerFileName0 = 'notepad.exe'
	) APPS ON SYS.ResourceID = APPS.ResourceID
WHERE SF.FileName LIKE 'notepad.exe'
GROUP BY SYS.Netbios_Name0,
	apps.LastUsedTime0,
	SF.FileName,
	SF.FileDescription,
	SF.FileVersion,
	SF.FileSize,
	SF.FileModifiedDate,
	SF.FilePath,
	SYS.User_Name0,
	CSYS.Manufacturer0,
	CSYS.Model0,
	BIOS.SerialNumber0,
	sys.AD_Site_Name0
HAVING max(apps.LastUsedTime0) < dateadd(month, - (@Monthold), dateadd(day, 0, datediff(day, 0, getdate())))
	OR max(apps.LastUsedTime0) IS NULL
ORDER BY SYS.Netbios_Name0

-- 36. All PCs with particular software inventory Exe file
SELECT DISTINCT SYS.Netbios_Name0 AS Name,
	SF.FileName,
	SF.FileDescription,
	SF.FileVersion,
	SF.FileSize,
	SF.FileModifiedDate,
	SF.FilePath,
	SYS.User_Name0 AS LOGIN,
	CSYS.Manufacturer0 AS Manufacturer,
	CSYS.Model0 AS Model,
	BIOS.SerialNumber0 AS SN,
	MAX(IPSub.IP_Subnets0) AS 'Subnet',
	sys.AD_Site_Name0 AS ADSite,
	MAX(SYSOU.System_OU_Name0) AS 'OU'
FROM v_GS_SoftwareFile SF
JOIN v_R_System SYS ON SYS.ResourceID = SF.ResourceID
LEFT JOIN v_RA_System_IPSubnets IPSub ON SYS.ResourceID = IPSub.ResourceID
LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS ON SYS.ResourceID = CSYS.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS ON SYS.ResourceID = OPSYS.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON SYS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_GS_PC_BIOS BIOS ON SYS.ResourceID = BIOS.ResourceID
LEFT JOIN v_RA_System_SystemOUName SYSOU ON SYS.ResourceID = SYSOU.ResourceID
LEFT JOIN v_R_User USR ON SYS.User_Name0 = USR.User_Name0
LEFT JOIN v_FullCollectionMembership FCM ON SYS.ResourceID = FCM.ResourceID
WHERE SF.FileName LIKE 'Microsoft.ConfigurationManagement.exe'
GROUP BY SYS.Netbios_Name0,
	SF.FileName,
	SF.FileDescription,
	SF.FileVersion,
	SF.FileSize,
	SF.FileModifiedDate,
	SF.FilePath,
	SYS.User_Name0,
	CSYS.Manufacturer0,
	CSYS.Model0,
	BIOS.SerialNumber0,
	sys.AD_Site_Name0
ORDER BY SYS.Netbios_Name0

-- 37. All PCs with Username and Email ID details
SELECT SYS.User_Name0 AS LOGIN,
	USR.Mail0 AS 'EMail ID',
	SYS.Netbios_Name0 AS Machine,
	Operating_System_Name_and0 AS OS
FROM v_R_System SYS
JOIN v_R_User USR ON USR.User_Name0 = SYS.User_Name0
WHERE SYS.User_Name0 LIKE 'Username'
ORDER BY SYS.User_Name0,
	SYS.Netbios_Name0

-- 38. All PCs with Configuration Manager Console installed details
SELECT sys.Name0 AS Name,
	sys.user_name0 AS UserName,
	arp.DisplayName0 AS DisplayName,
	arp.Publisher0 AS Publisher,
	arp.Version0 AS Version,
	max(arp.InstallDate0) AS InstallDate
FROM v_Add_Remove_Programs arp
JOIN v_R_System sys ON arp.ResourceID = sys.ResourceID
LEFT JOIN v_FullCollectionMembership fcm ON SYS.ResourceID = fcm.ResourceID
LEFT JOIN v_R_User USR ON SYS.User_Name0 = USR.User_Name0
WHERE (arp.DisplayName0 LIKE '%System Center%Configuration Manager Console%')
	AND arp.Publisher0 LIKE '%Microsoft%'
GROUP BY sys.name0,
	sys.user_name0,
	arp.displayName0,
	arp.publisher0,
	arp.Version0
ORDER BY arp.displayName0,
	arp.publisher0

-- 39. All PCs client assigned and installed site code details
SELECT v_R_System.Netbios_Name0 AS 'NetBios Name',
	v_R_System.AD_Site_Name0 AS 'AD Site',
	v_R_System.Active0 AS 'isActive',
	v_R_System.Obsolete0 AS 'isObsolete',
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 AS 'Assigned Site',
	v_RA_System_SMSInstalledSites.SMS_Installed_Sites0 AS 'Installed Site'
FROM v_R_System
INNER JOIN v_RA_System_SMSAssignedSites ON (v_R_System.ResourceID = v_RA_System_SMSAssignedSites.ResourceID)
INNER JOIN v_RA_System_SMSInstalledSites ON (v_R_System.ResourceID = v_RA_System_SMSInstalledSites.ResourceID)
WHERE SMS_Assigned_Sites0 LIKE '%'
	AND SMS_Installed_Sites0 LIKE '%'

-- 40. All PCs with No Clients based on OS Category status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalNoClientAgent AS NUMERIC(8)
DECLARE @NoClientAgentWindowsOS AS NUMERIC(8)
DECLARE @NoClientAgentWindowsOSLastLogonwithin7Days AS NUMERIC(8)
DECLARE @NoClientAgentWindowsOSNOtLastLogonwithin7Days AS NUMERIC(8)
DECLARE @NoClientAgentNonWindowsOS AS NUMERIC(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT @TotalNoClientAgent = (
		SELECT count(Vrs.ResourceID) AS 'Count'
		FROM v_R_System Vrs
		INNER JOIN v_FullCollectionMembership Vf ON Vrs.ResourceID = Vf.ResourceID
		WHERE (
				Vrs.Client0 = 0
				OR Vrs.Client0 IS NULL
				)
			AND Vf.CollectionID = @CollectionID
		)

SELECT @NoClientAgentWindowsOS = (
		SELECT count(Vrs.ResourceID) AS 'Count'
		FROM v_R_System Vrs
		INNER JOIN v_FullCollectionMembership Vf ON Vrs.ResourceID = Vf.ResourceID
		WHERE (
				Vrs.Client0 = 0
				OR Vrs.Client0 IS NULL
				)
			AND Vrs.Unknown0 IS NULL
			AND Vrs.Operating_System_Name_and0 LIKE '%windows%'
			AND Vf.CollectionID = @CollectionID
		)

SELECT @NoClientAgentWindowsOSLastLogonwithin7Days = (
		SELECT count(Vrs.ResourceID) AS 'Count'
		FROM v_R_System Vrs
		INNER JOIN v_FullCollectionMembership Vf ON Vrs.ResourceID = Vf.ResourceID
		WHERE (
				Vrs.Client0 = 0
				OR Vrs.Client0 IS NULL
				)
			AND Vrs.Unknown0 IS NULL
			AND Vrs.Operating_System_Name_and0 LIKE '%windows%'
			AND (DATEDIFF(day, Last_Logon_Timestamp0, GetDate())) < 7
			AND Vf.CollectionID = @CollectionID
		)

SELECT @NoClientAgentWindowsOSNOtLastLogonwithin7Days = (
		SELECT count(Vrs.ResourceID) AS 'Count'
		FROM v_R_System Vrs
		INNER JOIN v_FullCollectionMembership Vf ON Vrs.ResourceID = Vf.ResourceID
		WHERE (
				Vrs.Client0 = 0
				OR Vrs.Client0 IS NULL
				)
			AND Vrs.Unknown0 IS NULL
			AND Vrs.Operating_System_Name_and0 LIKE '%windows%'
			AND (DATEDIFF(day, Last_Logon_Timestamp0, GetDate())) >= 7
			AND Vf.CollectionID = @CollectionID
		)

SELECT @NoClientAgentNonWindowsOS = (
		SELECT count(Vrs.ResourceID) AS 'Count'
		FROM v_R_System Vrs
		INNER JOIN v_FullCollectionMembership Vf ON Vrs.ResourceID = Vf.ResourceID
		WHERE (
				Vrs.Client0 = 0
				OR Vrs.Client0 IS NULL
				)
			AND Vrs.Unknown0 IS NULL
			AND Vrs.Operating_System_Name_and0 NOT LIKE '%windows%'
			AND Vf.CollectionID = @CollectionID
		)

SELECT @TotalNoClientAgent AS 'TotalNoClientAgent',
	@NoClientAgentWindowsOS AS 'NoClientAgentWindowsOS',
	@NoClientAgentNonWindowsOS AS 'NoClientAgentNonWindowsOS',
	@NoClientAgentWindowsOSLastLogonwithin7Days AS 'NoClientAgentWindowsOSLastLogonwithin7Days',
	@NoClientAgentWindowsOSNOtLastLogonwithin7Days AS 'NoClientAgentWindowsOSNOtLastLogonwithin7Days',
	CASE 
		WHEN (@NoClientAgentWindowsOS = 0)
			OR (@NoClientAgentWindowsOS IS NULL)
			THEN '100'
		ELSE (round(@NoClientAgentWindowsOSLastLogonwithin7Days / convert(FLOAT, @NoClientAgentWindowsOS) * 100, 2))
		END AS 'NoClientAgentWindowsOSLastLogonwithin7Days'

-- 41. All Workstations Client version status
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT sys.Client_Version0 AS 'Client Agent Version',
	count(sys.ResourceID) AS 'Count'
FROM v_R_System sys
INNER JOIN v_CH_ClientSummary ch ON sys.ResourceID = ch.ResourceID
INNER JOIN v_FullCollectionMembership Vf ON sys.ResourceID = Vf.ResourceID
WHERE (
		Ch.ClientActiveStatus = 1
		AND Sys.Operating_System_Name_and0 LIKE '%Workstation%'
		)
	AND Vf.CollectionID = @CollectionID
GROUP BY sys.Client_Version0
ORDER BY sys.Client_Version0 DESC

-- 42. All PCs with chassis type information
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT DISTINCT (v_R_System.ResourceID),
	v_R_System.Name0 AS 'Machine Name',
	AD_Site_Name0 AS 'AD Site',
	v_R_System.Operating_System_Name_and0 AS 'Operating System',
	v_RA_System_SMSInstalledSites.SMS_Installed_Sites0 AS 'Installed Site',
	'Chassis Type' = CASE 
		WHEN ChassisTypes0 = 1
			THEN 'Virtual Machine'
		WHEN ChassisTypes0 = 2
			THEN 'Unknown'
		WHEN ChassisTypes0 = 3
			THEN 'Desktop'
		WHEN ChassisTypes0 = 4
			THEN 'Low-profile Desktop'
		WHEN ChassisTypes0 = 5
			THEN 'Pizza Box'
		WHEN ChassisTypes0 = 6
			THEN 'Mini Tower'
		WHEN ChassisTypes0 = 7
			THEN 'Tower'
		WHEN ChassisTypes0 = 8
			THEN 'Portable'
		WHEN ChassisTypes0 = 9
			THEN 'Laptop'
		WHEN ChassisTypes0 = 10
			THEN 'Notebook'
		WHEN ChassisTypes0 = 11
			THEN 'Handheld'
		WHEN ChassisTypes0 = 12
			THEN 'Docking Station'
		WHEN ChassisTypes0 = 13
			THEN 'All-in-One'
		WHEN ChassisTypes0 = 14
			THEN 'Subnotebook'
		WHEN ChassisTypes0 = 15
			THEN 'Space-Saving'
		WHEN ChassisTypes0 = 16
			THEN 'Lunch Box'
		WHEN ChassisTypes0 = 17
			THEN 'Main System chassis'
		WHEN ChassisTypes0 = 18
			THEN 'Expansion chassis'
		WHEN ChassisTypes0 = 19
			THEN 'Sub-Chassis'
		WHEN ChassisTypes0 = 20
			THEN 'Bus-expansion chassis'
		WHEN ChassisTypes0 = 21
			THEN 'Peripheral chassis'
		WHEN ChassisTypes0 = 22
			THEN 'Storage chassis'
		WHEN ChassisTypes0 = 23
			THEN 'Rack-mount chassis'
		WHEN ChassisTypes0 = 24
			THEN 'Sealed-case computer'
		END
FROM v_R_System
INNER JOIN v_GS_SYSTEM_ENCLOSURE ON (v_GS_SYSTEM_ENCLOSURE.ResourceID = v_R_System.ResourceID)
INNER JOIN v_RA_System_SMSInstalledSites ON (v_RA_System_SMSInstalledSites.ResourceID = v_R_System.ResourceID)
INNER JOIN v_FullCollectionMembership ON (v_FullCollectionMembership.ResourceID = v_R_System.ResourceID)
WHERE v_FullCollectionMembership.CollectionID = @CollectionID

-- 43. All Workstations Client Installation Failure status
SELECT count(cdr.MachineID) AS 'Count',
	cdr.CP_LastInstallationError AS 'Error Code'
FROM v_CombinedDeviceResources cdr
WHERE cdr.IsClient = 0
	AND cdr.DeviceOS LIKE '%Windows%'
GROUP BY cdr.CP_LastInstallationError

-- 44. All Workstations with Last Boot up time status
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' --Specify the collection ID

SELECT 'Last Reboot within 7 days' AS TimePeriod,
	Count(sys.Name0) AS 'Count',
	1 SortOrder
FROM v_R_System sys
INNER JOIN v_GS_OPERATING_SYSTEM os ON os.ResourceId = sys.ResourceId
INNER JOIN v_FullCollectionMembership Vf ON sys.ResourceID = Vf.ResourceID
INNER JOIN v_CH_ClientSummary ch ON ch.ResourceID = sys.ResourceID
WHERE os.LastBootUpTime0 < DATEADD(day, - 7, GETDATE())
	AND ch.ClientActiveStatus = 1
	AND sys.Operating_System_Name_and0 LIKE '%workstation%'
	AND Vf.CollectionID = @CollectionID

UNION

SELECT 'Last Reboot within 14 days' AS TimePeriod,
	Count(sys.Name0) AS 'Count',
	2
FROM v_R_System sys
INNER JOIN v_GS_OPERATING_SYSTEM os ON os.ResourceId = sys.ResourceId
INNER JOIN v_FullCollectionMembership Vf ON sys.ResourceID = Vf.ResourceID
INNER JOIN v_CH_ClientSummary ch ON ch.ResourceID = sys.ResourceID
WHERE os.LastBootUpTime0 < DATEADD(day, - 14, GETDATE())
	AND ch.ClientActiveStatus = 1
	AND sys.Operating_System_Name_and0 LIKE '%workstation%'
	AND Vf.CollectionID = @CollectionID

UNION

SELECT 'Last Reboot within 1 month' AS TimePeriod,
	Count(sys.Name0) AS 'Count',
	3
FROM v_R_System sys
INNER JOIN v_GS_OPERATING_SYSTEM os ON os.ResourceId = sys.ResourceId
INNER JOIN v_FullCollectionMembership Vf ON sys.ResourceID = Vf.ResourceID
INNER JOIN v_CH_ClientSummary ch ON ch.ResourceID = sys.ResourceID
WHERE os.LastBootUpTime0 < DATEADD(month, - 1, GETDATE())
	AND ch.ClientActiveStatus = 1
	AND sys.Operating_System_Name_and0 LIKE '%workstation%'
	AND Vf.CollectionID = @CollectionID

UNION

SELECT 'Last Reboot within 3 months' AS TimePeriod,
	Count(sys.Name0) AS 'Count',
	4
FROM v_R_System sys
INNER JOIN v_GS_OPERATING_SYSTEM os ON os.ResourceId = sys.ResourceId
INNER JOIN v_FullCollectionMembership Vf ON sys.ResourceID = Vf.ResourceID
INNER JOIN v_CH_ClientSummary ch ON ch.ResourceID = sys.ResourceID
WHERE os.LastBootUpTime0 < DATEADD(month, - 3, GETDATE())
	AND ch.ClientActiveStatus = 1
	AND sys.Operating_System_Name_and0 LIKE '%workstation%'
	AND Vf.CollectionID = @CollectionID

UNION

SELECT 'Last Reboot within 6 months' AS TimePeriod,
	Count(sys.Name0) AS 'Count',
	5
FROM v_R_System sys
INNER JOIN v_GS_OPERATING_SYSTEM os ON os.ResourceId = sys.ResourceId
INNER JOIN v_FullCollectionMembership Vf ON sys.ResourceID = Vf.ResourceID
INNER JOIN v_CH_ClientSummary ch ON ch.ResourceID = sys.ResourceID
WHERE os.LastBootUpTime0 < DATEADD(month, - 6, GETDATE())
	AND ch.ClientActiveStatus = 1
	AND sys.Operating_System_Name_and0 LIKE '%workstation%'
	AND Vf.CollectionID = @CollectionID

UNION

SELECT 'Last Reboot within 12 months' AS TimePeriod,
	Count(sys.Name0) AS 'Count',
	6
FROM v_R_System sys
INNER JOIN v_GS_OPERATING_SYSTEM os ON os.ResourceId = sys.ResourceId
INNER JOIN v_FullCollectionMembership Vf ON sys.ResourceID = Vf.ResourceID
INNER JOIN v_CH_ClientSummary ch ON ch.ResourceID = sys.ResourceID
WHERE os.LastBootUpTime0 < DATEADD(month, - 12, GETDATE())
	AND ch.ClientActiveStatus = 1
	AND sys.Operating_System_Name_and0 LIKE '%workstation%'
	AND Vf.CollectionID = @CollectionID

UNION

SELECT 'Total Machines Count' AS TimePeriod,
	Count(sys.Name0) AS 'Count',
	7
FROM v_R_System sys
INNER JOIN v_GS_OPERATING_SYSTEM os ON os.ResourceId = sys.ResourceId
INNER JOIN v_FullCollectionMembership Vf ON sys.ResourceID = Vf.ResourceID
INNER JOIN v_CH_ClientSummary ch ON ch.ResourceID = sys.ResourceID
WHERE ch.ClientActiveStatus = 1
	AND sys.Operating_System_Name_and0 LIKE '%workstation%'
	AND Vf.CollectionID = @CollectionID
ORDER BY SortOrder

-- 45. All ConfigMgr Roles Status
SELECT DISTINCT (
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Site System'
		) AS 'SiteSys',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Component Server'
		) AS 'CompSer',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Site Server'
		) AS 'SiteSer',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Management Point'
		) AS 'MP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Distribution Point'
		) AS 'DP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS SQL Server'
		) AS 'SQL',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Software Update Point'
		) AS 'SUP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS SRS Reporting Point'
		) AS 'SSRS',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Reporting Point'
		) AS 'RPT',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Fallback Status Point'
		) AS 'FSP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Server Locator Point'
		) AS 'SLP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS PXE Service Point'
		) AS 'PXE',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS System Health Validator'
		) AS 'SysVal',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS State Migration Point'
		) AS 'SMP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Notification Server'
		) AS 'NotiSer',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Provider'
		) AS 'SMSPro',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Application Web Service'
		) AS 'WebSer',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Portal Web Site'
		) AS 'WebSite',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Branch distribution point'
		) AS 'BranDP'
FROM v_SystemResourceList

-- 46. All IE Version using Software Inventory
SELECT DISTINCT Vrs.Netbios_Name0,
	Vrs.User_Name0,
	Vrs.AD_Site_Name0,
	CASE 
		WHEN Sf.FileVersion LIKE '5.%'
			THEN 'Internet Explorer 5'
		WHEN Sf.FileVersion LIKE '6.%'
			THEN 'Internet Explorer 6'
		WHEN Sf.FileVersion LIKE '7.%'
			THEN 'Internet Explorer 7'
		WHEN Sf.FileVersion LIKE '8.%'
			THEN 'Internet Explorer 8'
		WHEN Sf.FileVersion LIKE '9.%'
			THEN 'Internet Explorer 9'
		WHEN Sf.FileVersion LIKE '10.%'
			THEN 'Internet Explorer 10'
		WHEN Sf.FileVersion LIKE '11.%'
			THEN 'Internet Explorer 11'
		ELSE 'Other Version'
		END AS 'IE Version',
	Sf.FileName,
	Sf.FileVersion
FROM v_R_System Vrs
INNER JOIN v_GS_SoftwareFile Sf ON Vrs.ResourceID = Sf.ResourceID
WHERE Sf.FileName = 'iexplore.exe'
	AND Sf.FilePath LIKE '_:\Program%Internet Explorer%'
GROUP BY Vrs.Netbios_Name0,
	Vrs.User_Name0,
	Vrs.AD_Site_Name0,
	Sf.FileName,
	Sf.FileVersion
ORDER BY Vrs.Netbios_Name0

-- 47. All Packages which are waiting to distribute content to DPs
SELECT SubString(dp.ServerNALPath, CHARINDEX('\\', dp.ServerNALPath) + 2, (CHARINDEX('"]', dp.ServerNALPath) - CHARINDEX('\\', dp.ServerNALPath)) - 3) AS ServerName,
	dp.SiteCode AS 'SiteCode',
	dp.PackageID AS 'PackageID',
	p.Name AS 'PackageName',
	P.SourceVersion AS 'SourceVersion',
	P.LastRefreshTime AS 'LastRefreshTime',
	stat.InstallStatus AS 'InstallStatus'
FROM v_DistributionPoint dp
LEFT JOIN v_PackageStatusDistPointsSumm stat ON dp.ServerNALPath = stat.ServerNALPath
	AND dp.PackageID = stat.PackageID
LEFT JOIN v_PackageStatus pstat ON dp.ServerNALPath = pstat.PkgServer
	AND dp.PackageID = pstat.PackageID
LEFT OUTER JOIN v_Package p ON dp.packageid = p.packageid
WHERE stat.InstallStatus NOT IN ('Package Installation complete')
ORDER BY 1

-- 48. All Packages Content Distribution Status
SELECT v_SystemResourceList.ServerName AS 'ServerName',
	v_SystemResourceList.SiteCode,
	(
		SELECT count(*)
		FROM v_PackageStatusDistPointsSumm
		WHERE servernalpath = nalpath
		) AS 'Targetted',
	(
		SELECT count(*)
		FROM v_PackageStatusDistPointsSumm
		WHERE installstatus = 'Package Installation complete'
			AND servernalpath = nalpath
		) AS 'Installed',
	(
		SELECT count(*)
		FROM v_PackageStatusDistPointsSumm
		WHERE (
				installstatus = 'Content updating'
				OR installstatus = 'Waiting to install package'
				OR installstatus = 'Content monitoring'
				)
			AND servernalpath = nalpath
		) AS 'Waiting',
	(
		SELECT count(*)
		FROM v_PackageStatusDistPointsSumm
		WHERE installstatus LIKE '%Retry%'
			AND servernalpath = nalpath
		) AS 'Retrying',
	(
		SELECT count(*)
		FROM v_PackageStatusDistPointsSumm
		WHERE installstatus = 'Waiting to remove package'
			AND servernalpath = nalpath
		) AS 'Removing',
	(
		SELECT count(*)
		FROM v_PackageStatusDistPointsSumm
		WHERE installstatus LIKE '%Fail%'
			AND servernalpath = nalpath
		) AS 'Failed',
	(
		SELECT ROUND((
					100 * (
						SELECT count(*)
						FROM v_PackageStatusDistPointsSumm
						WHERE installstatus = 'Package Installation complete'
							AND servernalpath = nalpath
						) / (
						SELECT count(*)
						FROM v_PackageStatusDistPointsSumm
						WHERE servernalpath = nalpath
						)
					), 2)
		) AS 'Compliance %'
FROM v_SystemResourceList
JOIN v_PackageStatusDistPointsSumm ON v_SystemResourceList.nalpath = v_PackageStatusDistPointsSumm.servernalpath
WHERE v_SystemResourceList.RoleName = 'SMS Distribution Point'
GROUP BY v_SystemResourceList.SiteCode,
	v_SystemResourceList.servername,
	v_SystemResourceList.nalpath
ORDER BY 1

-- 49. All ConfigMgr Issue Servers Status
SELECT SiteStatus.SiteCode,
	SiteInfo.ServerName,
	SiteInfo.SiteName,
	SiteStatus.Updated 'TimeStamp',
	CASE SiteInfo.STATUS
		WHEN 1
			THEN 'Active'
		WHEN 2
			THEN 'Pending'
		WHEN 3
			THEN 'Failed'
		WHEN 4
			THEN 'Deleted'
		WHEN 5
			THEN 'Upgrade'
		ELSE ' '
		END AS 'SiteState',
	CASE SiteStatus.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM V_SummarizerSiteStatus SiteStatus
JOIN v_Site SiteInfo ON SiteStatus.SiteCode = SiteInfo.SiteCode
WHERE SiteInfo.STATUS <> 1
	OR SiteStatus.STATUS = 2
ORDER BY SiteCode

-- 50. All Software applications required deployments status within 30 days
DECLARE @SoftwareAppDeploymentsReportNeededDays AS INTEGER

SET @SoftwareAppDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Vaa.ApplicationName AS 'ApplicationName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays'
FROM v_DeploymentSummary Ds
LEFT JOIN v_ApplicationAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 1
	AND Ds.DeploymentIntent = 1
	AND Ds.CreationTime > GETDATE() - @SoftwareAppDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 51. All Software applications available deployments status within 30 days
DECLARE @SoftwareAppDeploymentsReportNeededDays AS INTEGER

SET @SoftwareAppDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Vaa.ApplicationName AS 'ApplicationName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays'
FROM v_DeploymentSummary Ds
LEFT JOIN v_ApplicationAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 1
	AND Ds.DeploymentIntent = 2
	AND Ds.CreationTime > GETDATE() - @SoftwareAppDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 52. All Software applications simulate deployments status within 30 days
DECLARE @SoftwareAppDeploymentsReportNeededDays AS INTEGER

SET @SoftwareAppDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Vaa.ApplicationName AS 'ApplicationName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		WHEN Ds.DeploymentIntent = 3
			THEN 'Simulate'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays'
FROM v_DeploymentSummary Ds
LEFT JOIN v_ApplicationAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 1
	AND Ds.DeploymentIntent = 3
	AND Ds.CreationTime > GETDATE() - @SoftwareAppDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 53. All Software packages required deployments status within 30 days
DECLARE @SoftwarePkgDeploymentsReportNeededDays AS INTEGER

SET @SoftwarePkgDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Left(Ds.SoftwareName, CharIndex('(', (Ds.SoftwareName)) - 1) AS 'ApplicationName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 2
	AND Ds.DeploymentIntent = 1
	AND Ds.ModificationTime > GETDATE() - @SoftwarePkgDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 54. All Software packages available deployments status within 30 days
DECLARE @SoftwarePkgDeploymentsReportNeededDays AS INTEGER

SET @SoftwarePkgDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Left(Ds.SoftwareName, CharIndex('(', (Ds.SoftwareName)) - 1) AS 'ApplicationName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 2
	AND Ds.DeploymentIntent = 2
	AND Ds.ModificationTime > GETDATE() - @SoftwarePkgDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 55. All Software updates required deployments status within 30 days
DECLARE @PatchDeploymentsReportNeededDays AS INTEGER

SET @PatchDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	'Software Update' AS 'PackageName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'Others',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberSuccess = 0)
			OR (Ds.NumberSuccess IS NULL)
			THEN '0'
		ELSE (round(Ds.NumberSuccess / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_CIAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 5
	AND Ds.DeploymentIntent = 1
	AND Vaa.LastModificationTime > GETDATE() - @PatchDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 56. All Software updates available deployments status within 30 days
DECLARE @PatchDeploymentsReportNeededDays AS INTEGER

SET @PatchDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	'Software Update' AS 'PackageName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'Others',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberSuccess = 0)
			OR (Ds.NumberSuccess IS NULL)
			THEN '0'
		ELSE (round(Ds.NumberSuccess / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_CIAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 5
	AND Ds.DeploymentIntent = 2
	AND Vaa.LastModificationTime > GETDATE() - @PatchDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 57. All OSD required deployments status within 30 days
DECLARE @SoftwareOSDeploymentsReportNeededDays AS INTEGER

SET @SoftwareOSDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Ds.SoftwareName AS 'TaskSequenceName',
	Ds.ProgramName AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 7
	AND Ds.DeploymentIntent = 1
	AND Ds.ModificationTime > GETDATE() - @SoftwareOSDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 58. All OSD available deployments status within 30 days
DECLARE @SoftwareOSDeploymentsReportNeededDays AS INTEGER

SET @SoftwareOSDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Ds.SoftwareName AS 'TaskSequenceName',
	Ds.ProgramName AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 7
	AND Ds.DeploymentIntent = 2
	AND Ds.ModificationTime > GETDATE() - @SoftwareOSDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 59. All ConfigMgr Roles Detailed status
SELECT srl.ServerName,
	srl.SiteCode,
	vs.SiteName,
	vrs.AD_Site_Name0 AS ADSite,
	vs.ReportingSiteCode AS Parent,
	vs.Installdir,
	MAX(CASE srl.rolename
			WHEN 'SMS Site System'
				THEN 'Yes'
			ELSE ' '
			END) AS SiteSys,
	MAX(CASE srl.rolename
			WHEN 'SMS Component Server'
				THEN 'Yes'
			ELSE ' '
			END) AS CompSer,
	MAX(CASE srl.rolename
			WHEN 'SMS Site Server'
				THEN 'Yes'
			ELSE ' '
			END) AS SiteSer,
	MAX(CASE srl.rolename
			WHEN 'SMS Management Point'
				THEN 'Yes'
			ELSE ' '
			END) AS MP,
	MAX(CASE srl.rolename
			WHEN 'SMS Distribution Point'
				THEN 'Yes'
			ELSE ' '
			END) AS DP,
	MAX(CASE srl.rolename
			WHEN 'SMS SQL Server'
				THEN 'Yes'
			ELSE ' '
			END) AS 'SQL',
	MAX(CASE srl.rolename
			WHEN 'SMS Software Update Point'
				THEN 'Yes'
			ELSE ' '
			END) AS SUP,
	MAX(CASE srl.rolename
			WHEN 'SMS SRS Reporting Point'
				THEN 'Yes'
			ELSE ' '
			END) AS SSRS,
	MAX(CASE srl.RoleName
			WHEN 'SMS Reporting Point'
				THEN 'Yes'
			ELSE ' '
			END) AS RPT,
	MAX(CASE srl.rolename
			WHEN 'SMS Fallback Status Point'
				THEN 'Yes'
			ELSE ' '
			END) AS FSP,
	MAX(CASE srl.rolename
			WHEN 'SMS ServerName Locator Point'
				THEN 'Yes'
			ELSE ' '
			END) AS SLP,
	MAX(CASE srl.rolename
			WHEN 'SMS PXE Service Point'
				THEN 'Yes'
			ELSE ' '
			END) AS PXE,
	MAX(CASE srl.rolename
			WHEN 'AI Update Service Point'
				THEN 'Yes'
			ELSE ' '
			END) AS AssI,
	MAX(CASE srl.rolename
			WHEN 'SMS State Migration Point'
				THEN 'Yes'
			ELSE ' '
			END) AS SMP,
	MAX(CASE srl.rolename
			WHEN 'SMS System Health Validator'
				THEN 'Yes'
			ELSE ' '
			END) AS SysVal,
	MAX(CASE srl.rolename
			WHEN 'SMS Notification Server'
				THEN 'Yes'
			ELSE ' '
			END) AS NotiSer,
	MAX(CASE srl.rolename
			WHEN 'SMS Provider'
				THEN 'Yes'
			ELSE ' '
			END) AS SMSPro,
	MAX(CASE srl.rolename
			WHEN 'SMS Application Web Service'
				THEN 'Yes'
			ELSE ' '
			END) AS WebSer,
	MAX(CASE srl.rolename
			WHEN 'SMS Portal Web Site'
				THEN 'Yes'
			ELSE ' '
			END) AS WebSite,
	MAX(CASE srl.rolename
			WHEN 'SMS Branch distribution point'
				THEN 'Yes'
			ELSE ' '
			END) AS BranDP
FROM v_SystemResourceList AS srl
LEFT JOIN v_site vs ON srl.ServerName = vs.ServerName
LEFT JOIN v_R_System_Valid vrs ON LEFT(srl.ServerName, CHARINDEX('.', srl.ServerName) - 1) = vrs.Netbios_Name0
GROUP BY srl.ServerName,
	srl.SiteCode,
	vs.SiteName,
	vs.ReportingSiteCode,
	vrs.AD_Site_Name0,
	vs.InstallDir
ORDER BY srl.sitecode,
	srl.ServerName

-- 60. All SCCM Server Software Update Sync status
SELECT US.SiteCode,
	S.ServerName,
	S.SiteName,
	US.ContentVersion,
	US.SyncTime,
	US.LastSyncState,
	US.LastSyncStateTime,
	US.LastErrorCode
FROM update_syncstatus US,
	v_Site S
WHERE US.SiteCode = S.SiteCode
ORDER BY SyncTime

-- 61. All Software applications required deployments status within 5 days
DECLARE @CurrentDeploymentsReportNeededDays AS INTEGER

SET @CurrentDeploymentsReportNeededDays = 5 --Specify the Days

SELECT CONVERT(VARCHAR(11), GETDATE(), 106) AS 'Date',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Vaa.ApplicationName AS 'ApplicationName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'ReqDays'
FROM v_DeploymentSummary Ds
LEFT JOIN v_ApplicationAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 1
	AND Ds.DeploymentIntent = 1
	AND DateDiff(D, Ds.EnforcementDeadline, GetDate()) BETWEEN 0
		AND @CurrentDeploymentsReportNeededDays
	AND Ds.NumberTotal > 0
ORDER BY Ds.EnforcementDeadline DESC

-- 62. All Software packages required deployments status within 5 days
DECLARE @CurrentDeploymentsReportNeededDays AS INTEGER

SET @CurrentDeploymentsReportNeededDays = 5 --Specify the Days

SELECT CONVERT(VARCHAR(11), GETDATE(), 106) AS 'Date',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Left(Ds.SoftwareName, CharIndex('(', (Ds.SoftwareName)) - 1) AS 'ApplicationName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailDays'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 2
	AND Ds.DeploymentIntent = 1
	AND DateDiff(D, Ds.DeploymentTime, GetDate()) BETWEEN 0
		AND @CurrentDeploymentsReportNeededDays
	AND Ds.NumberTotal > 0
ORDER BY Ds.DeploymentTime DESC

-- 63. All Software updates required deployments status within 5 days
DECLARE @CurrentDeploymentsReportNeededDays AS INTEGER

SET @CurrentDeploymentsReportNeededDays = 500 --Specify the Days

SELECT CONVERT(VARCHAR(11), GETDATE(), 106) AS 'Date',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Vaa.AssignmentName AS 'DeploymentName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'Others',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberSuccess = 0)
			OR (Ds.NumberSuccess IS NULL)
			THEN '0'
		ELSE (round(Ds.NumberSuccess / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'ReqDays'
FROM v_DeploymentSummary Ds
LEFT JOIN v_CIAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 5
	AND Ds.DeploymentIntent = 1
	AND DateDiff(D, Ds.EnforcementDeadline, GetDate()) BETWEEN 0
		AND @CurrentDeploymentsReportNeededDays
	AND Ds.NumberTotal > 0
ORDER BY Ds.EnforcementDeadline DESC

-- 64. All Software applications deployments status within 30 days
DECLARE @AppDeploymentsReportNeededDays AS INTEGER

SET @AppDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Vaa.ApplicationName AS 'ApplicationName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		WHEN Ds.DeploymentIntent = 3
			THEN 'Simulate'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_ApplicationAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 1
	AND Ds.CreationTime > GETDATE() - @AppDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 65. All Software packages deployments status within 30 days
DECLARE @PKGDeploymentsReportNeededDays AS INTEGER

SET @PKGDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Left(Ds.SoftwareName, CharIndex('(', (Ds.SoftwareName)) - 1) AS 'ApplicationName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.ModificationTime, GetDate()) AS 'CreatedDays',
	Ds.CreationTime AS 'CreationTime',
	Ds.ModificationTime AS 'LastModifiedTime',
	'Administrator' AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 2
	AND Ds.ModificationTime > GETDATE() - @PKGDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 66. All Software updates deployments status within 30 days
DECLARE @PatchDeploymentsReportNeededDays AS INTEGER

SET @PatchDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	'Software Update' AS 'PackageName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'Others',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberSuccess = 0)
			OR (Ds.NumberSuccess IS NULL)
			THEN '0'
		ELSE (round(Ds.NumberSuccess / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_CIAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 5
	AND Vaa.LastModificationTime > GETDATE() - @PatchDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 67. All OS deployments status within 30 days
DECLARE @OSDeploymentsReportNeededDays AS INTEGER

SET @OSDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Ds.SoftwareName AS 'TaskSequenceName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.ModificationTime, GetDate()) AS 'CreatedDays',
	Ds.CreationTime AS 'CreationTime',
	Ds.ModificationTime AS 'LastModifiedTime',
	'Administrator' AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 7
	AND Ds.ModificationTime > GETDATE() - @OSDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 68. All Software updates deployments status within 30 days
DECLARE @PatchDeploymentsReportNeededDays AS INTEGER

SET @PatchDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'Others',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberSuccess = 0)
			OR (Ds.NumberSuccess IS NULL)
			THEN '0'
		ELSE (round(Ds.NumberSuccess / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_CIAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 5
	AND Vaa.LastModificationTime > GETDATE() - @PatchDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 69. All OS deployments status within 30 days
DECLARE @OSDeploymentsReportNeededDays AS INTEGER

SET @OSDeploymentsReportNeededDays = 30 --Specify the Days

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Ds.SoftwareName AS 'TaskSequenceName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.ModificationTime, GetDate()) AS 'CreatedDays',
	Ds.CreationTime AS 'CreationTime',
	Ds.ModificationTime AS 'LastModifiedTime',
	'Administrator' AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 7
	AND Ds.ModificationTime > GETDATE() - @OSDeploymentsReportNeededDays
ORDER BY Ds.DeploymentTime DESC

-- 70. All Site Servers Issue MP components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName = 'SMS_MP_CONTROL_MANAGER'
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 71. All Site Servers Issue DP components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName = 'SMS_DISTRIBUTION_MANAGER'
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 72. All Site Servers Issue DDR components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName = 'SMS_DISCOVERY_DATA_MANAGER'
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 73. All Site Servers Issue CCR components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName = 'SMS_CLIENT_CONFIG_MANAGER'
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 74. All Site Servers Issue WSUS components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND (
		ComponentName = 'SMS_WSUS_CONFIGURATION_MANAGER'
		OR ComponentName = 'SMS_WSUS_SYNC_MANAGER'
		)
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 75. All Site Servers Issue Discovery components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND (
		ComponentName = 'SMS_AD_SYSTEM_GROUP_DISCOVERY_AGENT'
		OR ComponentName = 'SMS_AD_SYSTEM_DISCOVERY_AGENT'
		OR ComponentName = 'SMS_NETWORK_DISCOVERY'
		OR ComponentName = 'SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'
		)
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 76. All Site Servers Issue Collection Evaluator components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName = 'SMS_COLLECTION_EVALUATOR'
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 77. All Site Servers Issue Hardware Inventory components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName = 'SMS_INVENTORY_DATA_LOADER'
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 78. All Site Servers Issue Despooler components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName = 'SMS_DESPOOLER'
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 79. All Site Servers Issue Inbox Monitor components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName = 'SMS_INBOX_MONITOR'
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 80. All Site Servers Issue Component Monitor components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName = 'SMS_COMPONENT_MONITOR'
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 81. All Site Servers Issue Others components status
SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND ComponentName NOT IN ('SMS_MP_CONTROL_MANAGER', 'SMS_DISTRIBUTION_MANAGER', 'SMS_DISCOVERY_DATA_MANAGER', 'SMS_CLIENT_CONFIG_MANAGER', 'SMS_WSUS_CONFIGURATION_MANAGER', 'SMS_WSUS_SYNC_MANAGER', 'SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT', 'SMS_AD_SYSTEM_GROUP_DISCOVERY_AGENT', 'SMS_AD_SYSTEM_DISCOVERY_AGENT', 'SMS_NETWORK_DISCOVERY', 'SMS_COLLECTION_EVALUATOR', 'SMS_INVENTORY_DATA_LOADER', 'SMS_DESPOOLER', 'SMS_INBOX_MONITOR', 'SMS_COMPONENT_MONITOR')
	AND v_ComponentSummarizer.STATUS = 2
ORDER BY SiteCode

-- 82. All Workstations Not Assigned Clients detailed status
DECLARE @SCCMManagedWorkstationsScopeCollectionID AS VARCHAR(8)

SET @SCCMManagedWorkstationsScopeCollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT (VRS.Netbios_Name0) AS 'Name',
	CASE 
		WHEN VRS.Client0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Client',
	CASE 
		WHEN VRS.Active0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Active',
	CASE 
		WHEN v_CH_ClientSummary.ClientActiveStatus = 1
			THEN 'Yes'
		ELSE 'No'
		END 'ClientHealthActive',
	v_CH_ClientSummary.ClientStateDescription AS 'ClientHealthDescription',
	System_Disc.AD_Site_Name0 AS 'ADSiteName',
	Vrs.Operating_System_Name_and0 AS 'OSType',
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 AS 'AssignedSite',
	v_CH_ClientSummary.LastActiveTime AS 'LastCommunicated',
	DateDiff(D, v_CH_ClientSummary.LastActiveTime, GetDate()) 'LastCommunicatedDays',
	Vrs.Creation_Date0 AS 'ClientCreation',
	DateDiff(D, Vrs.Creation_Date0, GetDate()) 'ClientCreationDays',
	System_Disc.Last_Logon_Timestamp0 AS 'LastLogon',
	DateDiff(D, System_Disc.Last_Logon_Timestamp0, GetDate()) 'LastLogonDays',
	System_Disc.Distinguished_Name0 AS 'OUName'
FROM V_R_System Vrs
LEFT OUTER JOIN v_RA_System_SMSAssignedSites ON v_RA_System_SMSAssignedSites.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_Gs_Operating_System ON v_Gs_Operating_System.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_CH_ClientSummary ON v_CH_ClientSummary.ResourceID = VRS.ResourceId
LEFT OUTER JOIN System_Disc ON System_Disc.ItemKey = VRS.ResourceId
WHERE (
		Vrs.Client0 = 0
		OR Vrs.Client0 IS NULL
		)
	AND (
		VRS.Obsolete0 = 0
		OR VRS.Obsolete0 IS NULL
		)
	AND v_FullCollectionMembership.CollectionID = @SCCMManagedWorkstationsScopeCollectionID
	AND v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 IS NULL
	AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
ORDER BY System_Disc.Last_Logon_Timestamp0 DESC

-- 83. All Workstations Unhealthy Clients detailed status
DECLARE @SCCMManagedWorkstationsScopeCollectionID AS VARCHAR(8)

SET @SCCMManagedWorkstationsScopeCollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT (VRS.Netbios_Name0) AS 'Name',
	CASE 
		WHEN VRS.Client0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Client',
	CASE 
		WHEN VRS.Active0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Active',
	CASE 
		WHEN v_CH_ClientSummary.ClientActiveStatus = 1
			THEN 'Yes'
		ELSE 'No'
		END 'ClientHealthActive',
	v_CH_ClientSummary.ClientStateDescription AS 'ClientHealthDescription',
	System_Disc.AD_Site_Name0 AS 'ADSiteName',
	Vrs.Operating_System_Name_and0 AS 'OSType',
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 AS 'AssignedSite',
	v_CH_ClientSummary.LastActiveTime AS 'LastCommunicated',
	DateDiff(D, v_CH_ClientSummary.LastActiveTime, GetDate()) 'LastCommunicatedDays',
	Vrs.Creation_Date0 AS 'ClientCreation',
	DateDiff(D, Vrs.Creation_Date0, GetDate()) 'ClientCreationDays',
	System_Disc.Last_Logon_Timestamp0 AS 'LastLogon',
	DateDiff(D, System_Disc.Last_Logon_Timestamp0, GetDate()) 'LastLogonDays',
	System_Disc.Distinguished_Name0 AS 'OUName'
FROM V_R_System Vrs
LEFT OUTER JOIN v_RA_System_SMSAssignedSites ON v_RA_System_SMSAssignedSites.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_Gs_Operating_System ON v_Gs_Operating_System.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_CH_ClientSummary ON v_CH_ClientSummary.ResourceID = VRS.ResourceId
LEFT OUTER JOIN System_Disc ON System_Disc.ItemKey = VRS.ResourceId
WHERE (
		Vrs.Client0 = 0
		OR Vrs.Client0 IS NULL
		)
	AND (
		VRS.Obsolete0 = 0
		OR VRS.Obsolete0 IS NULL
		)
	AND v_FullCollectionMembership.CollectionID = @SCCMManagedWorkstationsScopeCollectionID
	AND v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 IS NOT NULL
	AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
ORDER BY System_Disc.Last_Logon_Timestamp0 DESC

-- 84. All Workstations Inactive Clients detailed status
DECLARE @SCCMManagedWorkstationsScopeCollectionID AS VARCHAR(8)

SET @SCCMManagedWorkstationsScopeCollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT (VRS.Netbios_Name0) AS 'Name',
	CASE 
		WHEN VRS.Client0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Client',
	CASE 
		WHEN VRS.Active0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Active',
	CASE 
		WHEN v_CH_ClientSummary.ClientActiveStatus = 1
			THEN 'Yes'
		ELSE 'No'
		END 'ClientHealthActive',
	v_CH_ClientSummary.ClientStateDescription AS 'ClientHealthDescription',
	System_Disc.AD_Site_Name0 AS 'ADSiteName',
	Vrs.Operating_System_Name_and0 AS 'OSType',
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 AS 'AssignedSite',
	v_CH_ClientSummary.LastActiveTime AS 'LastCommunicated',
	DateDiff(D, v_CH_ClientSummary.LastActiveTime, GetDate()) 'LastCommunicatedDays',
	Vrs.Creation_Date0 AS 'ClientCreation',
	DateDiff(D, Vrs.Creation_Date0, GetDate()) 'ClientCreationDays',
	System_Disc.Last_Logon_Timestamp0 AS 'LastLogon',
	DateDiff(D, System_Disc.Last_Logon_Timestamp0, GetDate()) 'LastLogonDays',
	System_Disc.Distinguished_Name0 AS 'OUName'
FROM V_R_System Vrs
LEFT OUTER JOIN v_RA_System_SMSAssignedSites ON v_RA_System_SMSAssignedSites.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_Gs_Operating_System ON v_Gs_Operating_System.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_CH_ClientSummary ON v_CH_ClientSummary.ResourceID = VRS.ResourceId
LEFT OUTER JOIN System_Disc ON System_Disc.ItemKey = VRS.ResourceId
WHERE (
		Vrs.Client0 = 1
		AND v_CH_ClientSummary.ClientActiveStatus <> 1
		)
	AND (
		VRS.Obsolete0 = 0
		OR VRS.Obsolete0 IS NULL
		)
	AND v_FullCollectionMembership.CollectionID = @SCCMManagedWorkstationsScopeCollectionID
	AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
ORDER BY System_Disc.Last_Logon_Timestamp0 DESC

-- 85. All Obsolete Clients detailed status
SELECT ResourceID AS 'ResourceID',
	Name0 AS 'MachineName',
	User_Name0 AS 'LogonUserName',
	CASE 
		WHEN Client0 = 1
			THEN 'Yes'
		ELSE 'No'
		END AS 'Client',
	CASE 
		WHEN Obsolete0 = 1
			THEN 'Yes'
		ELSE 'No'
		END AS 'Obsolete',
	CASE 
		WHEN Active0 = 1
			THEN 'Yes'
		ELSE 'No'
		END AS 'Active',
	AD_Site_Name0 AS 'ADSiteName',
	Operating_System_Name_and0 AS 'OSType',
	Client_Version0 AS 'ClientVersion',
	Creation_Date0 AS 'CreationDateinSCCM'
FROM v_R_system
WHERE (
		Obsolete0 = 1
		AND Active0 = 0
		)
	AND Name0 NOT LIKE '%Unknown%'

-- 86. All Packages available in SCCM
SELECT DISTINCT p.PackageID,
	p.Name,
	p.Version,
	p.LANGUAGE,
	p.Manufacturer,
	PackageType = CASE Packagetype
		WHEN 0
			THEN 'Software Distribution Package'
		WHEN 3
			THEN 'Driver Package'
		WHEN 4
			THEN 'Task Sequence Package'
		WHEN 5
			THEN 'Software Update Package'
		WHEN 6
			THEN 'Device Settings Package'
		WHEN 7
			THEN 'Virtual Package'
		WHEN 8
			THEN 'Software Distribution Application'
		WHEN 257
			THEN 'Image Package'
		WHEN 258
			THEN 'Boot Image Package'
		WHEN 259
			THEN 'OS Install Package'
		END,
	p.PkgSourcePath,
	p.SourceDate,
	p.LastRefreshTime,
	p.SourceVersion,
	p.SourceSite,
	n.Targeted,
	n.Installed,
	n.Retrying,
	n.Failed,
	(n.SourceSize / 1024) AS 'SourceSize(MB)',
	(n.SourceCompressedSize / 1024) AS 'SourceCompressedSize(MB)'
FROM v_Package p
LEFT JOIN v_PackageStatusRootSummarizer n ON p.PackageID = n.PackageID
WHERE p.PackageType <> '4'
	AND p.PackageType <> '258'
ORDER BY 1 DESC

-- 87. All Collections available in SCCM
SELECT dbo.v_Collection.CollectionID AS 'CollectionID',
	dbo.v_Collections_G.LimitToCollectionID AS 'LimitToCollectionID',
	dbo.v_Collection.Name AS 'CollectionName',
	dbo.Collections.LimitToCollectionName AS 'LimitingCollectionName',
	CASE 
		WHEN dbo.v_Collections_G.CollectionType = 1
			THEN 'User'
		WHEN dbo.v_Collections_G.CollectionType = 2
			THEN 'Device'
		ELSE 'Others'
		END AS 'CollectionType',
	dbo.v_Collection.MemberCount AS 'MembersCount',
	dbo.v_Collections_G.CollectionComment AS 'CollectionComment',
	dbo.Collections.BeginDate AS 'CreatedDate',
	dbo.Collections.LastMemberChangeTime AS 'LastMemberChangeDate',
	dbo.v_CollectionRuleQuery.RuleName AS 'CollectionRuleName',
	dbo.v_CollectionRuleQuery.QueryID AS 'QueryID',
	dbo.v_CollectionRuleQuery.QueryExpression AS 'QueryExpression'
FROM dbo.v_Collection
LEFT JOIN dbo.v_CollectionRuleQuery ON dbo.v_Collection.CollectionID = dbo.v_CollectionRuleQuery.CollectionID
LEFT JOIN dbo.Collections ON dbo.v_Collection.CollectionID = dbo.Collections.SiteID
LEFT JOIN dbo.v_Collections_G ON dbo.v_Collection.CollectionID = dbo.v_Collections_G.SiteID
ORDER BY dbo.v_Collection.Name,
	dbo.v_Collections_G.CollectionType

-- 88. All Managed Workstations details status
DECLARE @ProjectName AS VARCHAR(25)

SET @ProjectName = 'LAB' -- specify Project Name

SELECT DISTINCT Vrs.resourceid AS 'ResourceID',
	Vrs.Name0 AS 'MachineName',
	'SCCM' AS 'SourceName',
	getdate() AS 'ReportingDate',
	bios.SerialNumber0 AS 'SerialNumber',
	cs.Manufacturer0 AS 'Manufacturer',
	encl.PartNumber0 AS 'ManufacturerPartNumber',
	cs.model0 AS 'DeviceModel',
	CASE 
		WHEN p.caption0 IS NULL
			THEN p.name0
		ELSE p.caption0
		END AS 'ProcessorType',
	(mem.TotalPhysicalMemory0 / 1024 / 1000) AS 'MemorySize(GB)',
	DISK.Size0 / 1024 AS 'HDDSize',
	bios.Version0 AS 'BIOSVersion',
	@ProjectName AS 'AccountCode',
	encl.chassistypes0 AS 'EquipmentType',
	os.caption0 AS 'OperatingSystem',
	os.csdversion0 AS 'ServicePackVersion',
	os.InstallDate0 AS 'InstallationDate',
	Vrs.Creation_Date0 AS 'CreationDateinSCCM'
FROM v_r_system Vrs
LEFT OUTER JOIN v_gs_pc_bios bios ON Vrs.resourceid = bios.resourceid
LEFT OUTER JOIN v_gs_computer_system cs ON Vrs.resourceid = cs.resourceid
LEFT OUTER JOIN v_gs_system_enclosure encl ON Vrs.resourceid = encl.resourceid
LEFT OUTER JOIN v_gs_processor p ON Vrs.resourceid = p.resourceid
LEFT OUTER JOIN v_gs_x86_pc_memory mem ON Vrs.resourceid = mem.resourceid
LEFT OUTER JOIN v_gs_logical_disk DISK ON Vrs.resourceid = DISK.resourceid
LEFT OUTER JOIN v_gs_operating_system os ON Vrs.resourceid = os.resourceid
WHERE DISK.name0 = 'C:'
	AND encl.tag0 = 'System Enclosure 0'
	AND os.caption0 NOT LIKE '%server%'
	AND Vrs.Active0 = 1
	AND Vrs.Client0 = 1
	AND Vrs.Obsolete0 = 0

-- 89. All Workstations Assets Inventory details status
Declare @CollectionID as varchar(8)
Declare @ProjectName as varchar(25)
Set @CollectionID = 'SMS00001' -- specify scope collection ID
Set @ProjectName = 'LAB' -- specify Project Name
Select
Distinct (VRS.Netbios_Name0) as 'Name',
Case when VRS.Client0 = 1 Then 'Yes' Else 'No' End 'Client',
Case when VRS.Active0 = 1 Then 'Yes' Else 'No' End 'Active',
Case when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 1 Then 'VMWare'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 IN('3','4')Then 'Desktop'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 IN('8','9','10','11','12','14') Then 'Laptop'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 6 Then 'Mini Tower'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 7 Then 'Tower'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 13 Then 'All in One'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 15 Then 'Space-Saving'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 17 Then 'Main System Chassis'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 21 Then 'Peripheral Chassis'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 22 Then 'Storage Chassis'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 23 Then 'Rack Mount Chassis'
when v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 24 Then 'Sealed-Case PC'
Else 'Others' End 'CaseType',
LEFT(MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0), ISNULL(NULLIF(CHARINDEX(',',MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0)) - 1, -1),LEN(MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0))))as 'IPAddress',
MAX (v_GS_NETWORK_ADAPTER_CONFIGUR.MACAddress0) as 'MACAddress',
v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 as 'AssignedSite',
VRS.Client_Version0 as 'ClientVersion',
VRS.Creation_Date0 as 'ClientCreationDate',
VRS.AD_Site_Name0 as 'ADSiteName',
dbo.v_GS_OPERATING_SYSTEM.InstallDate0 AS 'OSInstallDate',
DateDiff(D, dbo.v_GS_OPERATING_SYSTEM.InstallDate0, GetDate()) 'OSInstallDateAge',
Convert(VarChar, v_Gs_Operating_System.LastBootUpTime0,100) as 'LastBootDate',
DateDiff(D, Convert(VarChar, v_Gs_Operating_System.LastBootUpTime0,100), GetDate()) as 'LastBootDateAge',
PC_BIOS_DATA.SerialNumber00 as 'SerialNumber',
v_GS_SYSTEM_ENCLOSURE.SMBIOSAssetTag0 as 'AssetTag',
PC_BIOS_DATA.ReleaseDate00 as 'ReleaseDate',
PC_BIOS_DATA.Name00 as 'BiosName',
PC_BIOS_DATA.SMBIOSBIOSVersion00 as 'BiosVersion',
v_GS_PROCESSOR.Name0 as 'ProcessorName',
case when Computer_System_DATA.Manufacturer00 like 'VMware%' Then 'VMWare'
when Computer_System_DATA.Manufacturer00 like 'Gigabyte%' Then 'Gigabyte'
when Computer_System_DATA.Manufacturer00 like 'VIA Technologies%' Then 'VIA Technologies'
when Computer_System_DATA.Manufacturer00 like 'MICRO-STAR%' Then 'MICRO-STAR'
Else Computer_System_DATA.Manufacturer00 End 'Manufacturer',
Computer_System_DATA.Model00 as 'Model',
Computer_System_DATA.SystemType00 as 'OSType',
v_GS_COMPUTER_SYSTEM.Domain0 as 'DomainName',
VRS.User_Domain0+'\'+ VRS.User_Name0 as 'UserName',
v_R_User.Mail0 as 'EMailID',
Case when v_GS_COMPUTER_SYSTEM.domainrole0 = 0 then 'Standalone Workstation'
when v_GS_COMPUTER_SYSTEM.domainrole0 = 1 Then 'Member Workstation'
when v_GS_COMPUTER_SYSTEM.domainrole0 = 2 Then 'Standalone Server'
when v_GS_COMPUTER_SYSTEM.domainrole0 = 3 Then 'Member Server'
when v_GS_COMPUTER_SYSTEM.domainrole0 = 4 Then 'Backup Domain Controller'
when v_GS_COMPUTER_SYSTEM.domainrole0 = 5 Then 'Primary Domain Controller'
End 'Role',
case when Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Enterprise Edition' Then 'Microsoft(R) Windows(R) Server 2003 Enterprise Edition'
when Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Standard Edition' Then 'Microsoft(R) Windows(R) Server 2003 Standard Edition'
when Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Web Edition' Then 'Microsoft(R) Windows(R) Server 2003 Web Edition'
Else Operating_System_DATA.Caption00 End 'OSName',
Operating_System_DATA.CSDVersion00 as 'ServicePack',
Operating_System_DATA.Version00 as 'Version',
((v_GS_X86_PC_MEMORY.TotalPhysicalMemory0/1024)/1000) as 'TotalRAMSize(GB)',
max(v_GS_LOGICAL_DISK.Size0 / 1024) AS 'TotalHDDSize(GB)',
v_GS_WORKSTATION_STATUS.LastHWScan as 'LastHWScan',
DateDiff(D, v_GS_WORKSTATION_STATUS.LastHwScan, GetDate()) as 'LastHWScanAge',
@ProjectName as 'AccountName'
from V_R_System VRS
Left Outer join PC_BIOS_DATA on PC_BIOS_DATA.MachineID = VRS.ResourceId
Left Outer join Operating_System_DATA on Operating_System_DATA.MachineID = VRS.ResourceId
Left Outer join v_GS_WORKSTATION_STATUS on v_GS_WORKSTATION_STATUS.ResourceID = VRS.ResourceId
Left Outer join Computer_System_DATA on Computer_System_DATA.MachineID = VRS.ResourceId
Left Outer join v_GS_X86_PC_MEMORY on v_GS_X86_PC_MEMORY.ResourceID = VRS.ResourceId
Left Outer join v_GS_PROCESSOR on v_GS_PROCESSOR.ResourceID = VRS.ResourceId
Left Outer join v_GS_SYSTEM_ENCLOSURE on v_GS_SYSTEM_ENCLOSURE.ResourceID = VRS.ResourceId
Left Outer join v_Gs_Operating_System on v_Gs_Operating_System .ResourceID = VRS.ResourceId
Left Outer join v_RA_System_SMSAssignedSites on v_RA_System_SMSAssignedSites.ResourceID = VRS.ResourceId
Left Outer join v_GS_COMPUTER_SYSTEM on v_GS_COMPUTER_SYSTEM.ResourceID = VRS.ResourceId
Left Outer join v_FullCollectionMembership on v_FullCollectionMembership.ResourceID = VRS.ResourceId
Left Outer join v_GS_NETWORK_ADAPTER_CONFIGUR on v_GS_NETWORK_ADAPTER_CONFIGUR.ResourceID = VRS.ResourceId
left outer join v_GS_LOGICAL_DISK on v_GS_LOGICAL_DISK.ResourceID = Vrs.ResourceId AND v_GS_LOGICAL_DISK.DriveType0 = 3
Left Outer join v_R_User on VRS.User_Name0 = v_R_User.User_Name0
where VRS.Operating_System_Name_and0 like '%Workstation%'
and (VRS.Obsolete0 = 0 or VRS.Obsolete0 is null)
and VRS.Client0 = 1
and v_FullCollectionMembership.CollectionID = @CollectionID
and VRS.Netbios_Name0 = 'CLIENT01' --< Edit
GROUP BY VRS.Netbios_Name0,VRS.Client0,VRS.Active0,v_GS_SYSTEM_ENCLOSURE.ChassisTypes0,
v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0,VRS.Client_Version0,Vrs.Creation_Date0,
Vrs.AD_Site_Name0,v_Gs_Operating_System.InstallDate0,v_Gs_Operating_System.LastBootUpTime0,
PC_BIOS_DATA.SerialNumber00,v_GS_SYSTEM_ENCLOSURE.SMBIOSAssetTag0,PC_BIOS_DATA.ReleaseDate00,
PC_BIOS_DATA.Name00,PC_BIOS_DATA.SMBIOSBIOSVersion00,v_GS_PROCESSOR.Name0,Computer_System_DATA.Manufacturer00,
Computer_System_DATA.Model00,Computer_System_DATA.SystemType00,v_GS_COMPUTER_SYSTEM.Domain0,
Vrs.User_Domain0,Vrs.User_Name0,v_R_User.Mail0,v_GS_COMPUTER_SYSTEM.DomainRole0,Operating_System_DATA.Caption00,Operating_System_DATA.CSDVersion00, Operating_System_DATA.Version00, v_GS_X86_PC_MEMORY.TotalPhysicalMemory0, v_GS_WORKSTATION_STATUS.LastHWScan
order by VRS.Netbios_Name0
-- 90. All Workstations Assets Inventory details status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @ProjectName AS VARCHAR(25)

SET @CollectionID = 'SMS00001' -- specify scope collection ID Set @ProjectName = 'LAB' -- specify Project Name

SELECT DISTINCT (VRS.Netbios_Name0) AS 'Name',
	CASE 
		WHEN VRS.Client0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Client',
	CASE 
		WHEN VRS.Active0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Active',
	CASE 
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 1
			THEN 'VMWare'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 IN ('3', '4')
			THEN 'Desktop'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 IN ('8', '9', '10', '11', '12', '14')
			THEN 'Laptop'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 6
			THEN 'Mini Tower'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 7
			THEN 'Tower'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 13
			THEN 'All in One'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 15
			THEN 'Space-Saving'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 17
			THEN 'Main System Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 21
			THEN 'Peripheral Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 22
			THEN 'Storage Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 23
			THEN 'Rack Mount Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 24
			THEN 'Sealed-Case PC'
		ELSE 'Others'
		END 'CaseType',
	LEFT(MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0), ISNULL(NULLIF(CHARINDEX(',', MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0)) - 1, - 1), LEN(MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0)))) AS 'IPAddress',
	MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.MACAddress0) AS 'MACAddress',
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 AS 'AssignedSite',
	VRS.Client_Version0 AS 'ClientVersion',
	VRS.Creation_Date0 AS 'ClientCreationDate',
	VRS.AD_Site_Name0 AS 'ADSiteName',
	dbo.v_GS_OPERATING_SYSTEM.InstallDate0 AS 'OSInstallDate',
	DateDiff(D, dbo.v_GS_OPERATING_SYSTEM.InstallDate0, GetDate()) 'OSInstallDateAge',
	Convert(VARCHAR, v_Gs_Operating_System.LastBootUpTime0, 100) AS 'LastBootDate',
	DateDiff(D, Convert(VARCHAR, v_Gs_Operating_System.LastBootUpTime0, 100), GetDate()) AS 'LastBootDateAge',
	PC_BIOS_DATA.SerialNumber00 AS 'SerialNumber',
	v_GS_SYSTEM_ENCLOSURE.SMBIOSAssetTag0 AS 'AssetTag',
	PC_BIOS_DATA.ReleaseDate00 AS 'ReleaseDate',
	PC_BIOS_DATA.Name00 AS 'BiosName',
	PC_BIOS_DATA.SMBIOSBIOSVersion00 AS 'BiosVersion',
	v_GS_PROCESSOR.Name0 AS 'ProcessorName',
	CASE 
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'VMware%'
			THEN 'VMWare'
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'Gigabyte%'
			THEN 'Gigabyte'
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'VIA Technologies%'
			THEN 'VIA Technologies'
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'MICRO-STAR%'
			THEN 'MICRO-STAR'
		ELSE Computer_System_DATA.Manufacturer00
		END 'Manufacturer',
	Computer_System_DATA.Model00 AS 'Model',
	Computer_System_DATA.SystemType00 AS 'OSType',
	v_GS_COMPUTER_SYSTEM.Domain0 AS 'DomainName',
	VRS.User_Domain0 + '\' + VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	CASE 
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 0
			THEN 'Standalone Workstation'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 1
			THEN 'Member Workstation'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 2
			THEN 'Standalone Server'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 3
			THEN 'Member Server'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 4
			THEN 'Backup Domain Controller'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 5
			THEN 'Primary Domain Controller'
		END 'Role',
	CASE 
		WHEN Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Enterprise Edition'
			THEN 'Microsoft(R) Windows(R) Server 2003 Enterprise Edition'
		WHEN Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Standard Edition'
			THEN 'Microsoft(R) Windows(R) Server 2003 Standard Edition'
		WHEN Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Web Edition'
			THEN 'Microsoft(R) Windows(R) Server 2003 Web Edition'
		ELSE Operating_System_DATA.Caption00
		END 'OSName',
	Operating_System_DATA.CSDVersion00 AS 'ServicePack',
	Operating_System_DATA.Version00 AS 'Version',
	((v_GS_X86_PC_MEMORY.TotalPhysicalMemory0 / 1024) / 1000) AS 'TotalRAMSize(GB)',
	max(v_GS_LOGICAL_DISK.Size0 / 1024) AS 'TotalHDDSize(GB)',
	v_GS_WORKSTATION_STATUS.LastHWScan AS 'LastHWScan',
	DateDiff(D, v_GS_WORKSTATION_STATUS.LastHwScan, GetDate()) AS 'LastHWScanAge',
	@ProjectName AS 'AccountName'
FROM V_R_System VRS
LEFT OUTER JOIN PC_BIOS_DATA ON PC_BIOS_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN Operating_System_DATA ON Operating_System_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN v_GS_WORKSTATION_STATUS ON v_GS_WORKSTATION_STATUS.ResourceID = VRS.ResourceId
LEFT OUTER JOIN Computer_System_DATA ON Computer_System_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN v_GS_X86_PC_MEMORY ON v_GS_X86_PC_MEMORY.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_PROCESSOR ON v_GS_PROCESSOR.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_SYSTEM_ENCLOSURE ON v_GS_SYSTEM_ENCLOSURE.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_Gs_Operating_System ON v_Gs_Operating_System.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_RA_System_SMSAssignedSites ON v_RA_System_SMSAssignedSites.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_COMPUTER_SYSTEM ON v_GS_COMPUTER_SYSTEM.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_NETWORK_ADAPTER_CONFIGUR ON v_GS_NETWORK_ADAPTER_CONFIGUR.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_LOGICAL_DISK ON v_GS_LOGICAL_DISK.ResourceID = Vrs.ResourceId
	AND v_GS_LOGICAL_DISK.DriveType0 = 3
LEFT OUTER JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE VRS.Operating_System_Name_and0 LIKE '%Server%'
	AND (
		VRS.Obsolete0 = 0
		OR VRS.Obsolete0 IS NULL
		)
	AND VRS.Client0 = 1
	AND v_FullCollectionMembership.CollectionID = @CollectionID
	AND VRS.Netbios_Name0 = 'CLIENT01' --<
GROUP BY VRS.Netbios_Name0,
	VRS.Client0,
	VRS.Active0,
	v_GS_SYSTEM_ENCLOSURE.ChassisTypes0,
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0,
	VRS.Client_Version0,
	Vrs.Creation_Date0,
	Vrs.AD_Site_Name0,
	v_Gs_Operating_System.InstallDate0,
	v_Gs_Operating_System.LastBootUpTime0,
	PC_BIOS_DATA.SerialNumber00,
	v_GS_SYSTEM_ENCLOSURE.SMBIOSAssetTag0,
	PC_BIOS_DATA.ReleaseDate00,
	PC_BIOS_DATA.Name00,
	PC_BIOS_DATA.SMBIOSBIOSVersion00,
	v_GS_PROCESSOR.Name0,
	Computer_System_DATA.Manufacturer00,
	Computer_System_DATA.Model00,
	Computer_System_DATA.SystemType00,
	v_GS_COMPUTER_SYSTEM.Domain0,
	Vrs.User_Domain0,
	Vrs.User_Name0,
	v_R_User.Mail0,
	v_GS_COMPUTER_SYSTEM.DomainRole0,
	Operating_System_DATA.Caption00,
	Operating_System_DATA.CSDVersion00,
	Operating_System_DATA.Version00,
	v_GS_X86_PC_MEMORY.TotalPhysicalMemory0,
	v_GS_WORKSTATION_STATUS.LastHWScan
ORDER BY VRS.Netbios_Name0

-- 91. All PCs with Office 365 Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.AD_Site_Name0 AS 'ADSite',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	App.ARPDisplayName0 AS 'DisplayName',
	App.InstallDate0 AS 'InstalledDate',
	App.ProductVersion0 AS 'Version'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership AS Col ON VRS.ResourceID = Col.ResourceID
LEFT JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE App.ARPDisplayName0 LIKE 'Microsoft Office 365%'
	AND App.ProductVersion0 LIKE '15.%'
	AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND Col.CollectionID = @Collection
	AND VRS.Client0 = 1
	AND VRS.Obsolete0 = 0
ORDER BY VRS.Name0,
	App.ProductVersion0

-- 92. All PCs without Office 365 Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT (vs.Name0) AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	Vs.AD_Site_Name0 AS 'ADSite',
	vs.Full_Domain_Name0 AS 'Domain',
	vs.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	HWSCAN.LastHWScan AS 'LastHWScan',
	DateDiff(D, HWSCAN.LastHwScan, GetDate()) AS 'LastHWScanAge'
FROM v_R_System vs
LEFT JOIN v_GS_SYSTEM_ENCLOSURE ON v_GS_SYSTEM_ENCLOSURE.ResourceID = vs.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON Vs.ResourceID = Os.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = vs.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON vs.ResourceID = HWSCAN.ResourceID
LEFT JOIN Computer_System_DATA St ON vs.ResourceID = st.MachineID
LEFT JOIN v_R_User ON vs.User_Name0 = v_R_User.User_Name0
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON vs.ResourceID = App.ResourceID
WHERE Vs.Operating_System_Name_and0 LIKE '%Workstation%'
	AND v_FullCollectionMembership.CollectionID = @Collection
	AND Vs.Client0 = 1
	AND Vs.Obsolete0 = 0
	AND vs.ResourceID NOT IN (
		SELECT Vrs.ResourceID
		FROM V_R_System VRS
		LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
		LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
		LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
		LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
		WHERE App.ARPDisplayName0 LIKE 'Microsoft Office 365%'
			AND App.ProductVersion0 LIKE '15.%'
		)

-- 93. All PCs with SEP Antivirus Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.AD_Site_Name0 AS 'ADSite',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	App.ARPDisplayName0 AS 'DisplayName',
	App.InstallDate0 AS 'InstalledDate',
	App.ProductVersion0 AS 'Version'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership AS Col ON VRS.ResourceID = Col.ResourceID
LEFT JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE App.ARPDisplayName0 LIKE 'Symantec%Endpoint%Protection%'
	AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND Col.CollectionID = @Collection
	AND VRS.Client0 = 1
	AND VRS.Obsolete0 = 0
ORDER BY VRS.Name0,
	App.ProductVersion0

-- 94. All PCs without SEP Antivirus Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT (vs.Name0) AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	Vs.AD_Site_Name0 AS 'ADSite',
	vs.Full_Domain_Name0 AS 'Domain',
	vs.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	HWSCAN.LastHWScan AS 'LastHWScan',
	DateDiff(D, HWSCAN.LastHwScan, GetDate()) AS 'LastHWScanAge'
FROM v_R_System vs
LEFT JOIN v_GS_SYSTEM_ENCLOSURE ON v_GS_SYSTEM_ENCLOSURE.ResourceID = vs.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON Vs.ResourceID = Os.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = vs.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON vs.ResourceID = HWSCAN.ResourceID
LEFT JOIN Computer_System_DATA St ON vs.ResourceID = st.MachineID
LEFT JOIN v_R_User ON vs.User_Name0 = v_R_User.User_Name0
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON vs.ResourceID = App.ResourceID
WHERE Vs.Operating_System_Name_and0 LIKE '%Workstation%'
	AND v_FullCollectionMembership.CollectionID = @Collection
	AND Vs.Client0 = 1
	AND Vs.Obsolete0 = 0
	AND vs.ResourceID NOT IN (
		SELECT Vrs.ResourceID
		FROM V_R_System VRS
		LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
		LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
		LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
		LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
		WHERE App.ARPDisplayName0 LIKE 'Symantec%Endpoint%Protection%'
		)

-- 95. All Workstations Client Agent Detailed Report
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT (Name),
	CASE 
		WHEN IsClient = 1
			THEN 'Healthy'
		ELSE 'UnHealthy'
		END AS 'AgentStatus',
	(
		SELECT CASE 
				WHEN count(v_GS_WORKSTATION_STATUS.ResourceID) = 1
					THEN 'Healthy'
				ELSE 'UnHealthy'
				END
		FROM v_GS_WORKSTATION_STATUS
		WHERE DATEDIFF(day, LastHWScan, GetDate()) < 30
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'HWScanStatus',
	(
		SELECT CASE 
				WHEN count(v_GS_LastSoftwareScan.ResourceID) = 1
					THEN 'Healthy'
				ELSE 'UnHealthy'
				END
		FROM v_GS_LastSoftwareScan
		WHERE DATEDIFF(day, LastScanDate, GetDate()) < 30
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'SWScanStatus',
	(
		SELECT CASE 
				WHEN count(v_UpdateScanStatus.ResourceID) = 1
					THEN 'Healthy'
				ELSE 'UnHealthy'
				END
		FROM v_UpdateScanStatus
		WHERE DATEDIFF(day, LastScanTime, GetDate()) < 30
			AND LastErrorCode = 0
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'WSUSScanStatus',
	(
		SELECT DATEDIFF(day, LastHWScan, GetDate())
		FROM v_GS_WORKSTATION_STATUS
		WHERE ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'LastHWScanDays',
	(
		SELECT DATEDIFF(day, LastScanDate, GetDate())
		FROM v_GS_LastSoftwareScan
		WHERE ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'LastSWScanDays',
	(
		SELECT DATEDIFF(day, LastScanTime, GetDate())
		FROM v_UpdateScanStatus
		WHERE LastErrorCode = 0
			AND ResourceID = v_FullCollectionMembership.ResourceID
		) AS 'LastWSUSScanDays'
FROM v_FullCollectionMembership
WHERE CollectionID = @CollectionID
	AND ResourceID IN (
		SELECT ResourceID
		FROM v_R_System
		WHERE Operating_System_Name_and0 LIKE '%Workstation%'
		)
ORDER BY 2 DESC

-- 96. All Workstations Low Free Disk Space Report
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @FreeSpace AS INTEGER

SET @CollectionID = 'SMS00001' -- specify scope collection ID
SET @FreeSpace = '5000' -- specify MB Size

SELECT DISTINCT (Vrs.Name0) AS 'Machine',
	Vrs.AD_Site_Name0 AS 'ADSiteName',
	Vrs.User_Name0 AS 'UserName',
	USR.Mail0 AS 'EMailID',
	Os.Caption00 AS 'OSName',
	Csd.SystemType00 AS 'OSType',
	LD.DeviceID00 AS 'Drive',
	LD.FileSystem00 AS 'FileSystem',
	LD.Size00 / 1024 AS 'TotalSpace (GB)',
	LD.FreeSpace00 / 1024 AS 'FreeSpace (GB)',
	Ws.LastHWScan AS 'LastHWScan',
	DateDiff(D, Ws.LastHwScan, GetDate()) AS 'LastHWScanAge'
FROM v_R_System Vrs
JOIN v_R_User USR ON USR.User_Name0 = Vrs.User_Name0
JOIN v_FullCollectionMembership Fc ON Fc.ResourceID = Vrs.ResourceID
JOIN Operating_System_DATA Os ON Os.MachineID = Vrs.ResourceID
JOIN Computer_System_DATA Csd ON Csd.MachineID = Vrs.ResourceID
JOIN Logical_Disk_Data Ld ON Ld.MachineID = Vrs.ResourceID
JOIN v_GS_WORKSTATION_STATUS Ws ON Ws.ResourceID = Vrs.ResourceId
WHERE CollectionID = @CollectionID
	AND LD.Description00 = 'Local Fixed Disk'
	AND LD.FreeSpace00 < @FreeSpace
	AND Vrs.Operating_System_Name_and0 LIKE '%Workstation%'
ORDER BY Vrs.Name0 ASC

-- 97. All Servers Low Free Disk Space Report
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @FreeSpace AS INTEGER

SET @CollectionID = 'SMS00001' -- specify scope collection ID Set @FreeSpace = '5000' -- specify MB Size

SELECT DISTINCT (Vrs.Name0) AS 'Machine',
	Vrs.AD_Site_Name0 AS 'ADSiteName',
	Vrs.User_Name0 AS 'UserName',
	USR.Mail0 AS 'EMailID',
	Os.Caption00 AS 'OSName',
	Csd.SystemType00 AS 'OSType',
	LD.DeviceID00 AS 'Drive',
	LD.FileSystem00 AS 'FileSystem',
	LD.Size00 / 1024 AS 'TotalSpace (GB)',
	LD.FreeSpace00 / 1024 AS 'FreeSpace (GB)',
	Ws.LastHWScan AS 'LastHWScan',
	DateDiff(D, Ws.LastHwScan, GetDate()) AS 'LastHWScanAge'
FROM v_R_System Vrs
JOIN v_R_User USR ON USR.User_Name0 = Vrs.User_Name0
JOIN v_FullCollectionMembership Fc ON Fc.ResourceID = Vrs.ResourceID
JOIN Operating_System_DATA Os ON Os.MachineID = Vrs.ResourceID
JOIN Computer_System_DATA Csd ON Csd.MachineID = Vrs.ResourceID
JOIN Logical_Disk_Data Ld ON Ld.MachineID = Vrs.ResourceID
JOIN v_GS_WORKSTATION_STATUS Ws ON Ws.ResourceID = Vrs.ResourceId
WHERE CollectionID = @CollectionID
	AND LD.Description00 = 'Local Fixed Disk'
	AND LD.FreeSpace00 < @FreeSpace
	AND Vrs.Operating_System_Name_and0 LIKE '%Server%'
ORDER BY Vrs.Name0 ASC

-- 98. All Workstations Machines Names Last Logon with Serial No Report
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT (VRS.Netbios_Name0) AS 'Name',
	PC_BIOS_DATA.SerialNumber00 AS 'SerialNumber',
	VRS.User_Domain0 + '\' + VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID'
FROM V_R_System VRS
LEFT OUTER JOIN PC_BIOS_DATA ON PC_BIOS_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN Operating_System_DATA ON Operating_System_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN v_Gs_Operating_System ON v_Gs_Operating_System.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND (
		VRS.Obsolete0 = 0
		OR VRS.Obsolete0 IS NULL
		)
	AND VRS.Client0 = 1
	AND v_FullCollectionMembership.CollectionID = @CollectionID
GROUP BY VRS.Netbios_Name0,
	VRS.Client0,
	PC_BIOS_DATA.SerialNumber00,
	Vrs.User_Domain0,
	Vrs.User_Name0,
	v_R_User.Mail0
ORDER BY VRS.Netbios_Name0

-- 99. All Workstations with Adobe Acrobat Reader Installed Machines Report
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'Name',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	Vru.Mail0 AS 'EMailID',
	VRS.AD_Site_Name0 AS 'ADSite',
	ARP.Publisher0 AS 'Publisher',
	ARP.ARPDisplayName0 AS 'DisplayName',
	ARP.PackageCode0 AS 'ProductID',
	ARP.InstallDate0 AS 'InstalledDate',
	ARP.ProductVersion0 AS 'Version'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE ARP ON VRS.ResourceID = ARP.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT JOIN v_R_User Vru ON VRS.User_Name0 = Vru.User_Name0
WHERE ARP.Publisher0 LIKE '%Adobe%'
	AND ARP.ARPDisplayName0 LIKE '%Acrobat%Reader%'
	AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND v_FullCollectionMembership.CollectionID = @CollectionID
	AND VRS.Obsolete0 = 0
ORDER BY 12

-- 100. All Workstations with Adobe Acrobat Reader Last Usage Machines Report
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

DECLARE @days FLOAT
DECLARE @__timezoneoffset INT

SELECT @__timezoneoffset = DateDiff(ss, GetUTCDate(), Getdate())

SELECT @days = DATEDIFF(day, IntervalStart, DATEADD(month, 1, IntervalStart))
FROM v_SummarizationInterval

IF IsNULL(@days, 0) > 0
	SELECT DISTINCT VRS.Name0 AS 'Name',
		Os.Caption0 AS 'OperatingSystem',
		St.SystemType00 AS 'OSType',
		Vrs.Full_Domain_Name0 AS 'Domain',
		Vrs.User_Name0 AS 'UserName',
		Vrs.AD_Site_Name0 AS 'ADSite',
		ARP.Publisher0 AS 'Publisher',
		ARP.DisplayName0 AS 'DisplayName',
		ARP.ProdID0 AS 'ProductID',
		ARP.InstallDate0 AS 'InstalledDate',
		ARP.Version0 AS 'Version',
		DATEADD(ss, @__timezoneoffset, MAX(mus.LastUsage)) AS 'LastUsage',
		DateDiff(D, DATEADD(ss, @__timezoneoffset, MAX(mus.LastUsage)), GetDate()) AS 'LastUsageDays'
	FROM V_R_System Vrs
	LEFT JOIN v_GS_ADD_REMOVE_PROGRAMS ARP ON VRS.ResourceID = ARP.ResourceID
	LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
	LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
	LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
	LEFT JOIN v_MonthlyUsageSummary mus ON Vrs.ResourceID = mus.ResourceID
	LEFT JOIN v_MeteredFiles mf ON mus.FileID = mf.MeteredFileID
	LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
	WHERE ARP.Publisher0 LIKE '%Adobe%'
		AND ARP.DisplayName0 LIKE '%Acrobat%Reader%'
		AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
		AND v_FullCollectionMembership.CollectionID = @CollectionID
		AND Vrs.Obsolete0 = 0
		AND Vrs.Client0 = 1
	GROUP BY Vrs.Name0,
		Os.Caption0,
		St.SystemType00,
		Vrs.Full_Domain_Name0,
		Vrs.User_Name0,
		Vrs.AD_Site_Name0,
		ARP.Publisher0,
		ARP.InstallDate0,
		ARP.DisplayName0,
		ARP.ProdID0,
		ARP.Version0
	HAVING SUM(UsageCount) + SUM(TSUsageCount) > 0
	ORDER BY Vrs.Name0

-- 101. All Workstations with Adobe Products Not Used More Than 90 Days Machines Report
DECLARE @RequirdDays AS INTEGER
DECLARE @days FLOAT
DECLARE @__timezoneoffset INT

SELECT @__timezoneoffset = DateDiff(ss, GetUTCDate(), Getdate())

SELECT @days = DATEDIFF(day, IntervalStart, DATEADD(month, 1, IntervalStart))
FROM v_SummarizationInterval

SET @RequirdDays = 90 -- specify Days

IF IsNULL(@days, 0) > 0
	SELECT DISTINCT VRS.Name0 AS 'Name',
		Os.Caption0 AS 'OperatingSystem',
		St.SystemType00 AS 'OSType',
		Vrs.Full_Domain_Name0 AS 'Domain',
		Vrs.User_Name0 AS 'UserName',
		Vrs.AD_Site_Name0 AS 'ADSite',
		ARP.Publisher0 AS 'Publisher',
		ARP.DisplayName0 AS 'DisplayName',
		ARP.ProdID0 AS 'ProductID',
		ARP.InstallDate0 AS 'InstalledDate',
		ARP.Version0 AS 'Version',
		DATEADD(ss, @__timezoneoffset, MAX(mus.LastUsage)) AS 'LastUsage',
		DateDiff(D, DATEADD(ss, @__timezoneoffset, MAX(mus.LastUsage)), GetDate()) AS 'LastUsageDays'
	FROM V_R_System Vrs
	LEFT JOIN v_GS_ADD_REMOVE_PROGRAMS ARP ON VRS.ResourceID = ARP.ResourceID
	LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
	LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
	LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
	LEFT JOIN v_MonthlyUsageSummary mus ON Vrs.ResourceID = mus.ResourceID
	LEFT JOIN v_MeteredFiles mf ON mus.FileID = mf.MeteredFileID
	WHERE ARP.Publisher0 LIKE '%Adobe%'
		AND (DATEDIFF(d, LastUsage, GETDATE()) > @RequirdDays)
		AND (
			ARP.DisplayName0 LIKE '%Adobe%Acrobat%Pro%'
			OR ARP.DisplayName0 LIKE '%Adobe%InDesign%'
			OR ARP.DisplayName0 LIKE '%Adobe%Illustrator%'
			OR ARP.DisplayName0 LIKE '%Adobe%Illustrator%'
			OR ARP.DisplayName0 LIKE '%Adobe%Photoshop%'
			)
		AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
		AND Vrs.Obsolete0 = 0
		AND Vrs.Client0 = 1
	GROUP BY Vrs.Name0,
		Os.Caption0,
		St.SystemType00,
		Vrs.Full_Domain_Name0,
		Vrs.User_Name0,
		Vrs.AD_Site_Name0,
		ARP.Publisher0,
		ARP.InstallDate0,
		ARP.DisplayName0,
		ARP.ProdID0,
		ARP.Version0
	HAVING SUM(UsageCount) + SUM(TSUsageCount) > 0
	ORDER BY DateDiff(D, DATEADD(ss, @__timezoneoffset, MAX(mus.LastUsage)), GetDate())

-- 102. All Client and Inventory Health Report
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalMachines AS NUMERIC(5)
DECLARE @Healthy AS NUMERIC(5)
DECLARE @UnHealthy AS NUMERIC(5)
DECLARE @HWInventorySuccess AS NUMERIC(5)
DECLARE @HWInventoryNotRun AS NUMERIC(5)
DECLARE @SWInventorySuccess AS NUMERIC(5)
DECLARE @SWInventoryNotRun AS NUMERIC(5)
DECLARE @WSUSScanSuccess AS NUMERIC(5)
DECLARE @WSUSScanNotRun AS NUMERIC(5)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT @TotalMachines = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
		)

SELECT @Healthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND IsClient = 1
		)

SELECT @UnHealthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND IsClient = 1
				)
		)

SELECT @HWInventorySuccess = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_WORKSTATION_STATUS
				WHERE (DATEDIFF(day, LastHWScan, GetDate()) < 30)
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_AgentDiscoveries
						WHERE AgentName IN ('Heartbeat Discovery')
							AND DATEDIFF(day, AgentTime, GetDate()) < 30
						)
				)
		)

SELECT @HWInventoryNotRun = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsClient = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_GS_WORKSTATION_STATUS
						WHERE (DATEDIFF(day, LastHWScan, GetDate()) < 30)
							AND ResourceID IN (
								SELECT ResourceID
								FROM v_AgentDiscoveries
								WHERE AgentName IN ('Heartbeat Discovery')
									AND DATEDIFF(day, AgentTime, GetDate()) < 30
								)
						)
				)
		)

SELECT @SWInventorySuccess = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_LastSoftwareScan
				WHERE (DATEDIFF(day, LastScanDate, GetDate()) < 30)
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_AgentDiscoveries
						WHERE AgentName IN ('Heartbeat Discovery')
							AND DATEDIFF(day, AgentTime, GetDate()) < 30
						)
				)
		)

SELECT @SWInventoryNotRun = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsClient = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_GS_LastSoftwareScan
						WHERE (DATEDIFF(day, LastScanDate, GetDate()) < 30)
							AND ResourceID IN (
								SELECT ResourceID
								FROM v_AgentDiscoveries
								WHERE AgentName IN ('Heartbeat Discovery')
									AND DATEDIFF(day, AgentTime, GetDate()) < 30
								)
						)
				)
		)

SELECT @WSUSScanSuccess = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_UpdateScanStatus
				WHERE lastErrorCode = 0
					AND (DATEDIFF(day, LastScanTime, GetDate()) < 30)
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_AgentDiscoveries
						WHERE AgentName IN ('Heartbeat Discovery')
							AND DATEDIFF(day, AgentTime, GetDate()) < 30
						)
				)
		)

SELECT @WSUSScanNotRun = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsClient = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_UpdateScanStatus
						WHERE lastErrorCode = 0
							AND (DATEDIFF(day, LastScanTime, GetDate()) < 30)
							AND ResourceID IN (
								SELECT ResourceID
								FROM v_AgentDiscoveries
								WHERE AgentName IN ('Heartbeat Discovery')
									AND DATEDIFF(day, AgentTime, GetDate()) < 30
								)
						)
				)
		)

SELECT @TotalMachines AS 'TotalMachines',
	@Healthy AS 'Healthy',
	@UnHealthy AS 'UnHealthy',
	(
		SELECT (@Healthy / @TotalMachines) * 100
		) AS 'Healthy%',
	@HWInventorySuccess AS 'HWInventorySuccess',
	@HWInventoryNotRun AS 'HWInventoryNotRun',
	(
		SELECT (@HWInventorySuccess / @Healthy) * 100
		) AS 'HWInventorySuccess%',
	@SWInventorySuccess AS 'SWInventorySuccess',
	@SWInventoryNotRun AS 'SWInventoryNotRun',
	(
		SELECT (@SWInventorySuccess / @Healthy) * 100
		) AS 'SWInventorySuccess%',
	@WSUSScanSuccess AS 'WSUSScanSuccess',
	@WSUSScanNotRun AS 'WSUSScanNotRun',
	(
		SELECT (@WSUSScanSuccess / @Healthy) * 100
		) AS 'WSUSScanSuccess%'

-- 103. All Total Scope machines details
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT Name0 AS 'MachineName'
FROM v_R_system
WHERE V_R_System.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
		)

-- 104. All Total Healthy machines details
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT Name0 AS 'MachineName'
FROM v_R_system
WHERE V_R_System.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND IsClient = 1
		)

-- 105. All Total Unhealthy machines details
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT Name0 AS 'MachineName'
FROM v_R_system
WHERE V_R_System.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND IsClient = 1
				)
		)

-- 106. All Total Hardware Inventory within 30 Days machines details
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT Name0 AS 'MachineName'
FROM v_R_system
WHERE V_R_System.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_WORKSTATION_STATUS
				WHERE (DATEDIFF(day, LastHWScan, GetDate()) < 30)
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_AgentDiscoveries
						WHERE AgentName IN ('Heartbeat Discovery')
							AND DATEDIFF(day, AgentTime, GetDate()) < 30
						)
				)
		)

-- 107. All Total Hardware Inventory not within 30 Days machines details
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT Name0 AS 'MachineName'
FROM v_R_system
WHERE V_R_System.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsClient = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_GS_WORKSTATION_STATUS
						WHERE (DATEDIFF(day, LastHWScan, GetDate()) < 30)
							AND ResourceID IN (
								SELECT ResourceID
								FROM v_AgentDiscoveries
								WHERE AgentName IN ('Heartbeat Discovery')
									AND DATEDIFF(day, AgentTime, GetDate()) < 30
								)
						)
				)
		)

-- 108. All Total Software Inventory within 30 Days machines details
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT Name0 AS 'MachineName'
FROM v_R_system
WHERE V_R_System.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_LastSoftwareScan
				WHERE (DATEDIFF(day, LastScanDate, GetDate()) < 30)
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_AgentDiscoveries
						WHERE AgentName IN ('Heartbeat Discovery')
							AND DATEDIFF(day, AgentTime, GetDate()) < 30
						)
				)
		)

-- 109. All Total Software Inventory not within 30 Days machines details
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT Name0 AS 'MachineName'
FROM v_R_system
WHERE V_R_System.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsClient = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_GS_LastSoftwareScan
						WHERE (DATEDIFF(day, LastScanDate, GetDate()) < 30)
							AND ResourceID IN (
								SELECT ResourceID
								FROM v_AgentDiscoveries
								WHERE AgentName IN ('Heartbeat Discovery')
									AND DATEDIFF(day, AgentTime, GetDate()) < 30
								)
						)
				)
		)

-- 110. All Total WSUS Scan within 30 Days machines details
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT Name0 AS 'MachineName'
FROM v_R_system
WHERE V_R_System.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_UpdateScanStatus
				WHERE lastErrorCode = 0
					AND (DATEDIFF(day, LastScanTime, GetDate()) < 30)
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_AgentDiscoveries
						WHERE AgentName IN ('Heartbeat Discovery')
							AND DATEDIFF(day, AgentTime, GetDate()) < 30
						)
				)
		)

-- 111. All Total WSUS Scan not within 30 Days machines details
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- Specify Scope Collection ID

SELECT Name0 AS 'MachineName'
FROM v_R_system
WHERE V_R_System.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsClient = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_UpdateScanStatus
						WHERE lastErrorCode = 0
							AND (DATEDIFF(day, LastScanTime, GetDate()) < 30)
							AND ResourceID IN (
								SELECT ResourceID
								FROM v_AgentDiscoveries
								WHERE AgentName IN ('Heartbeat Discovery')
									AND DATEDIFF(day, AgentTime, GetDate()) < 30
								)
						)
				)
		)

-- 112. All Deployments status for Specific Application
DECLARE @ApplicationName AS VARCHAR(255)

SET @ApplicationName = 'Adobe DIO Illustrator Extension 3.0.13.2' --Specify Application Name

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Vaa.ApplicationName AS 'ApplicationName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		WHEN Ds.DeploymentIntent = 3
			THEN 'Simulate'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_ApplicationAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 1
	AND Vaa.ApplicationName = @ApplicationName
ORDER BY Ds.DeploymentTime DESC

-- 113. All Deployments status for Specific Package
DECLARE @PackageName AS VARCHAR(255)

SET @PackageName = 'SAP Client GUI 7.30' --Specify Package Name

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Left(Ds.SoftwareName, CharIndex('(', (Ds.SoftwareName)) - 1) AS 'PackageName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.ModificationTime, GetDate()) AS 'CreatedDays',
	Ds.CreationTime AS 'CreationTime',
	Ds.ModificationTime AS 'LastModifiedTime',
	'Administrator' AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 2
	AND Ds.SoftwareName LIKE @PackageName + '%'
ORDER BY Ds.DeploymentTime DESC

-- 114. All Deployments status for Specific Software Update Group 
DECLARE @SoftwareUpdateGroupName AS VARCHAR(255)

SET @SoftwareUpdateGroupName = 'All Updates SRWP2' --Specify Software Update Group Name

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Li.Title AS 'SUGroupName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'Others',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberSuccess = 0)
			OR (Ds.NumberSuccess IS NULL)
			THEN '0'
		ELSE (round(Ds.NumberSuccess / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_CIAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
LEFT JOIN v_AuthListInfo LI ON LI.ModelID = Ds.ModelID
WHERE Ds.FeatureType = 5
	AND Li.Title LIKE @SoftwareUpdateGroupName
ORDER BY Ds.DeploymentTime DESC

-- 115. All Deployments status for Specific Task Sequence
DECLARE @TaskSequenceName AS VARCHAR(255)

SET @TaskSequenceName = 'Windows 7 x64-CoreImage' --Specify TaskSequenceName

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Ds.SoftwareName AS 'TaskSequenceName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.ModificationTime, GetDate()) AS 'CreatedDays',
	Ds.CreationTime AS 'CreationTime',
	Ds.ModificationTime AS 'LastModifiedTime',
	'Administrator' AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 7
	AND Ds.SoftwareName = @TaskSequenceName
ORDER BY Ds.DeploymentTime DESC

-- 116. Deployment Detailed status for specific application with specific collection
DECLARE @ApplicationName AS VARCHAR(255)
DECLARE @CollectionName AS VARCHAR(255)

SET @ApplicationName = 'Adobe Creative-Cloud Design-Standard 2015 (64-bit)' -- Specify Application name
SET @CollectionName = '%Adobe Creative-Cloud Design-Standard 2015%' -- Specify Application name

SELECT aa.ApplicationName AS 'Application Name',
	aa.CollectionName AS 'Target Collection',
	ae.descript AS 'DeploymentTypeName',
	s1.netbios_name0 AS 'ComputerName',
	s1.AD_Site_Name0 AS 'ADSiteName',
	CASE 
		WHEN ae.AppEnforcementState = 1000
			THEN 'Success'
		WHEN ae.AppEnforcementState = 1001
			THEN 'Already Compliant'
		WHEN ae.AppEnforcementState = 1002
			THEN 'Simulate Success'
		WHEN ae.AppEnforcementState = 2000
			THEN 'In Progress'
		WHEN ae.AppEnforcementState = 2001
			THEN 'Waiting for Content'
		WHEN ae.AppEnforcementState = 2002
			THEN 'Installing'
		WHEN ae.AppEnforcementState = 2003
			THEN 'Restart to Continue'
		WHEN ae.AppEnforcementState = 2004
			THEN 'Waiting for maintenance window'
		WHEN ae.AppEnforcementState = 2005
			THEN 'Waiting for schedule'
		WHEN ae.AppEnforcementState = 2006
			THEN 'Downloading dependent content'
		WHEN ae.AppEnforcementState = 2007
			THEN 'Installing dependent content'
		WHEN ae.AppEnforcementState = 2008
			THEN 'Restart to complete'
		WHEN ae.AppEnforcementState = 2009
			THEN 'Content downloaded'
		WHEN ae.AppEnforcementState = 2010
			THEN 'Waiting for update'
		WHEN ae.AppEnforcementState = 2011
			THEN 'Waiting for user session reconnect'
		WHEN ae.AppEnforcementState = 2012
			THEN 'Waiting for user logoff'
		WHEN ae.AppEnforcementState = 2013
			THEN 'Waiting for user logon'
		WHEN ae.AppEnforcementState = 2014
			THEN 'Waiting to install'
		WHEN ae.AppEnforcementState = 2015
			THEN 'Waiting retry'
		WHEN ae.AppEnforcementState = 2016
			THEN 'Waiting for presentation mode'
		WHEN ae.AppEnforcementState = 2017
			THEN 'Waiting for Orchestration'
		WHEN ae.AppEnforcementState = 2018
			THEN 'Waiting for network'
		WHEN ae.AppEnforcementState = 2019
			THEN 'Pending App-V Virtual Environment'
		WHEN ae.AppEnforcementState = 2020
			THEN 'Updating App-V Virtual Environment'
		WHEN ae.AppEnforcementState = 3000
			THEN 'Requirements not met'
		WHEN ae.AppEnforcementState = 3001
			THEN 'Host platform not applicable'
		WHEN ae.AppEnforcementState = 4000
			THEN 'Unknown'
		WHEN ae.AppEnforcementState = 5000
			THEN 'Deployment failed'
		WHEN ae.AppEnforcementState = 5001
			THEN 'Evaluation failed'
		WHEN ae.AppEnforcementState = 5002
			THEN 'Deployment failed'
		WHEN ae.AppEnforcementState = 5003
			THEN 'Failed to locate content'
		WHEN ae.AppEnforcementState = 5004
			THEN 'Dependency installation failed'
		WHEN ae.AppEnforcementState = 5005
			THEN 'Failed to download dependent content'
		WHEN ae.AppEnforcementState = 5006
			THEN 'Conflicts with another application deployment'
		WHEN ae.AppEnforcementState = 5007
			THEN 'Waiting retry'
		WHEN ae.AppEnforcementState = 5008
			THEN 'Failed to uninstall superseded deployment type'
		WHEN ae.AppEnforcementState = 5009
			THEN 'Failed to download superseded deployment type'
		WHEN ae.AppEnforcementState = 5010
			THEN 'Failed to updating App-V Virtual Environment'
		END AS 'State Message',
	CASE 
		WHEN ae.AppEnforcementState LIKE '10%'
			THEN 'Success'
		WHEN ae.AppEnforcementState LIKE '20%'
			THEN 'Progress'
		WHEN ae.AppEnforcementState LIKE '30%'
			THEN 'ReqNotMet'
		WHEN ae.AppEnforcementState LIKE '40%'
			THEN 'Unknown'
		WHEN ae.AppEnforcementState LIKE '50%'
			THEN 'Failed'
		END AS 'Status',
	LastComplianceMessageTime AS 'LastMessageTime'
FROM v_R_System_Valid s1
JOIN vAppDTDeploymentResultsPerClient ae ON ae.ResourceID = s1.ResourceID
JOIN v_CICurrentComplianceStatus ci2 ON ci2.CI_ID = ae.CI_ID
	AND ci2.ResourceID = s1.ResourceID
JOIN v_ApplicationAssignment aa ON ae.AssignmentID = aa.AssignmentID
WHERE ae.AppEnforcementState IS NOT NULL
	AND (
		aa.ApplicationName = @ApplicationName
		AND aa.CollectionName LIKE @CollectionName
		)
ORDER BY ae.AppEnforcementState,
	LastComplianceMessageTime DESC

-- 117. Deployment Detailed status for specific application
DECLARE @ApplicationName AS VARCHAR(255)

SET @ApplicationName = 'Adobe Creative-Cloud Design-Standard 2015 (64-bit)' -- Specify Application name

SELECT aa.ApplicationName AS 'Application Name',
	aa.CollectionName AS 'Target Collection',
	ae.descript AS 'DeploymentTypeName',
	s1.netbios_name0 AS 'ComputerName',
	s1.AD_Site_Name0 AS 'ADSiteName',
	CASE 
		WHEN ae.AppEnforcementState = 1000
			THEN 'Success'
		WHEN ae.AppEnforcementState = 1001
			THEN 'Already Compliant'
		WHEN ae.AppEnforcementState = 1002
			THEN 'Simulate Success'
		WHEN ae.AppEnforcementState = 2000
			THEN 'In Progress'
		WHEN ae.AppEnforcementState = 2001
			THEN 'Waiting for Content'
		WHEN ae.AppEnforcementState = 2002
			THEN 'Installing'
		WHEN ae.AppEnforcementState = 2003
			THEN 'Restart to Continue'
		WHEN ae.AppEnforcementState = 2004
			THEN 'Waiting for maintenance window'
		WHEN ae.AppEnforcementState = 2005
			THEN 'Waiting for schedule'
		WHEN ae.AppEnforcementState = 2006
			THEN 'Downloading dependent content'
		WHEN ae.AppEnforcementState = 2007
			THEN 'Installing dependent content'
		WHEN ae.AppEnforcementState = 2008
			THEN 'Restart to complete'
		WHEN ae.AppEnforcementState = 2009
			THEN 'Content downloaded'
		WHEN ae.AppEnforcementState = 2010
			THEN 'Waiting for update'
		WHEN ae.AppEnforcementState = 2011
			THEN 'Waiting for user session reconnect'
		WHEN ae.AppEnforcementState = 2012
			THEN 'Waiting for user logoff'
		WHEN ae.AppEnforcementState = 2013
			THEN 'Waiting for user logon'
		WHEN ae.AppEnforcementState = 2014
			THEN 'Waiting to install'
		WHEN ae.AppEnforcementState = 2015
			THEN 'Waiting retry'
		WHEN ae.AppEnforcementState = 2016
			THEN 'Waiting for presentation mode'
		WHEN ae.AppEnforcementState = 2017
			THEN 'Waiting for Orchestration'
		WHEN ae.AppEnforcementState = 2018
			THEN 'Waiting for network'
		WHEN ae.AppEnforcementState = 2019
			THEN 'Pending App-V Virtual Environment'
		WHEN ae.AppEnforcementState = 2020
			THEN 'Updating App-V Virtual Environment'
		WHEN ae.AppEnforcementState = 3000
			THEN 'Requirements not met'
		WHEN ae.AppEnforcementState = 3001
			THEN 'Host platform not applicable'
		WHEN ae.AppEnforcementState = 4000
			THEN 'Unknown'
		WHEN ae.AppEnforcementState = 5000
			THEN 'Deployment failed'
		WHEN ae.AppEnforcementState = 5001
			THEN 'Evaluation failed'
		WHEN ae.AppEnforcementState = 5002
			THEN 'Deployment failed'
		WHEN ae.AppEnforcementState = 5003
			THEN 'Failed to locate content'
		WHEN ae.AppEnforcementState = 5004
			THEN 'Dependency installation failed'
		WHEN ae.AppEnforcementState = 5005
			THEN 'Failed to download dependent content'
		WHEN ae.AppEnforcementState = 5006
			THEN 'Conflicts with another application deployment'
		WHEN ae.AppEnforcementState = 5007
			THEN 'Waiting retry'
		WHEN ae.AppEnforcementState = 5008
			THEN 'Failed to uninstall superseded deployment type'
		WHEN ae.AppEnforcementState = 5009
			THEN 'Failed to download superseded deployment type'
		WHEN ae.AppEnforcementState = 5010
			THEN 'Failed to updating App-V Virtual Environment'
		END AS 'State Message',
	CASE 
		WHEN ae.AppEnforcementState LIKE '10%'
			THEN 'Success'
		WHEN ae.AppEnforcementState LIKE '20%'
			THEN 'Progress'
		WHEN ae.AppEnforcementState LIKE '30%'
			THEN 'ReqNotMet'
		WHEN ae.AppEnforcementState LIKE '40%'
			THEN 'Unknown'
		WHEN ae.AppEnforcementState LIKE '50%'
			THEN 'Failed'
		END AS 'Status',
	LastComplianceMessageTime AS 'LastMessageTime'
FROM v_R_System_Valid s1
JOIN vAppDTDeploymentResultsPerClient ae ON ae.ResourceID = s1.ResourceID
JOIN v_CICurrentComplianceStatus ci2 ON ci2.CI_ID = ae.CI_ID
	AND ci2.ResourceID = s1.ResourceID
JOIN v_ApplicationAssignment aa ON ae.AssignmentID = aa.AssignmentID
WHERE ae.AppEnforcementState IS NOT NULL
	AND aa.ApplicationName = @ApplicationName
ORDER BY ae.AppEnforcementState,
	LastComplianceMessageTime DESC

-- 118. Deployment Detailed status for specific package with specific collection
DECLARE @PackageName AS VARCHAR(255)
DECLARE @CollectionName AS VARCHAR(255)

SET @PackageName = 'Lync 2013' -- Specify Application name
SET @CollectionName = '%Lync%' -- Specify Collection name

SELECT DISTINCT pack.Name AS 'Package Name',
	COLL.CollectionName AS 'Target Collection',
	adv.ProgramName AS 'DeploymentTypeName',
	Vrs.Name0 AS 'ComputerName',
	Vrs.AD_Site_Name0 AS 'ADSiteName',
	ADV.AdvertisementID AS 'AdvertisementID',
	ADVS.LastStateName AS 'Status',
	ADVS.LastStatusTime AS 'Status Time'
FROM v_R_System Vrs
INNER JOIN vSMS_ClientAdvertisementStatus ADVS ON Vrs.ResourceID = ADVS.ResourceID
INNER JOIN v_Advertisement ADV ON ADV.AdvertisementID = ADVS.AdvertisementID
INNER JOIN v_FullCollectionMembership CM ON Vrs.ResourceID = CM.ResourceID
LEFT JOIN v_Package Pack ON adv.PackageID = pack.PackageID
LEFT JOIN v_Collections COLL ON ADV.CollectionID = COLL.SiteID
WHERE pack.Name = @PackageName
	AND COLL.CollectionName LIKE @CollectionName
ORDER BY Vrs.Name0

-- 119. Deployment Detailed status for specific package
DECLARE @PackageName AS VARCHAR(255)

SET @PackageName = 'Lync 2013' -- Specify Application name

SELECT DISTINCT pack.Name AS 'Package Name',
	COLL.CollectionName AS 'Target Collection',
	adv.ProgramName AS 'DeploymentTypeName',
	Vrs.Name0 AS 'ComputerName',
	Vrs.AD_Site_Name0 AS 'ADSiteName',
	ADV.AdvertisementID AS 'AdvertisementID',
	ADVS.LastStateName AS 'Status',
	ADVS.LastStatusTime AS 'Status Time'
FROM v_R_System Vrs
INNER JOIN vSMS_ClientAdvertisementStatus ADVS ON Vrs.ResourceID = ADVS.ResourceID
INNER JOIN v_Advertisement ADV ON ADV.AdvertisementID = ADVS.AdvertisementID
INNER JOIN v_FullCollectionMembership CM ON Vrs.ResourceID = CM.ResourceID
LEFT JOIN v_Package Pack ON adv.PackageID = pack.PackageID
LEFT JOIN v_Collections COLL ON ADV.CollectionID = COLL.SiteID
WHERE pack.Name = @PackageName
ORDER BY Vrs.Name0

-- 120. Deployment Detailed status for specific software Update deployment
DECLARE @DeploymentName AS VARCHAR(255)

SET @DeploymentName = 'SU WKS-All Production Computers' -- Specify Software update deployment name

SELECT vrs.Name0,
	vrs.Active0,
	vrs.AD_Site_Name0,
	vrs.User_Name0,
	vrs.Operating_System_Name_and0,
	a.Assignment_UniqueID AS DeploymentID,
	a.AssignmentName AS DeploymentName,
	a.StartTime AS Available,
	a.EnforcementDeadline AS Deadline,
	sn.StateName AS LastEnforcementState,
	wsus.LastErrorCode AS 'LasErrorCode',
	wsus.LastScanTime AS 'LastWSUSScan',
	DateDiff(D, wsus.LastScanTime, GetDate()) AS 'LastWSUSScan Age',
	wks.LastHWScan,
	DateDiff(D, wks.LastHwScan, GetDate()) AS 'LastHWScan Age'
FROM v_CIAssignment a
JOIN v_AssignmentState_Combined assc ON a.AssignmentID = assc.AssignmentID
JOIN v_StateNames sn ON assc.StateType = sn.TopicType
	AND sn.StateID = isnull(assc.StateID, 0)
JOIN v_R_System vrs ON vrs.ResourceID = assc.ResourceID
JOIN v_GS_WORKSTATION_STATUS wks ON wks.ResourceID = assc.ResourceID
JOIN v_UpdateScanStatus wsus ON wsus.ResourceID = assc.ResourceID
WHERE a.AssignmentName = @DeploymentName
	AND assc.StateType IN (300, 301)
ORDER BY 11 DESC

-- 121. All Collections with RefreshType
SELECT CollectionID AS 'ColletionID',
	Name AS 'ColletionName',
	CASE Refreshtype
		WHEN 1
			THEN 'NoScheduled Update'
		WHEN 2
			THEN 'Full Scheduled Update'
		WHEN 4
			THEN 'Incremental Update Update(Only)'
		WHEN 6
			THEN 'Incremental and Full Scheduled Update'
		END AS 'Refreshtype'
FROM v_Collection
ORDER BY refreshtype

-- 122. All Software Inventory Report for Specific Computer Based on Installed Software Class
SELECT sys.Netbios_Name0,
	vos.Caption0 AS [Operating System],
	varp.ARPDisplayName0 AS [Software Name],
	varp.Publisher0,
	varp.ProductVersion0,
	varp.TIMESTAMP,
	varp.InstallDate0,
	Varp.ProductID0,
	fcm.SiteCode,
	sys.User_Name0,
	sys.User_Domain0
FROM v_R_System sys
JOIN v_GS_INSTALLED_SOFTWARE varp ON sys.ResourceID = varp.ResourceID
JOIN v_FullCollectionMembership fcm ON sys.ResourceID = fcm.ResourceID
JOIN v_GS_OPERATING_SYSTEM vos ON sys.ResourceID = vos.ResourceID
WHERE ARPDisplayName0 LIKE '%'
	AND sys.Name0 IN ('Client01')

-- 123. All Applications Deployments Status for Specific Computers
SELECT s1.netbios_name0 AS 'ComputerName',
	aa.ApplicationName AS 'ApplicationName',
	'Application' AS 'ApplicationType',
	CASE 
		WHEN ae.AppEnforcementState LIKE '10%'
			THEN 'Success'
		WHEN ae.AppEnforcementState LIKE '20%'
			THEN 'Progress'
		WHEN ae.AppEnforcementState LIKE '30%'
			THEN 'ReqNotMet'
		WHEN ae.AppEnforcementState LIKE '40%'
			THEN 'Unknown'
		WHEN ae.AppEnforcementState LIKE '50%'
			THEN 'Failed'
		END AS 'Status',
	LastComplianceMessageTime AS 'LastMessageTime'
FROM v_R_System_Valid s1
JOIN vAppDTDeploymentResultsPerClient ae ON ae.ResourceID = s1.ResourceID
JOIN v_CICurrentComplianceStatus ci2 ON ci2.CI_ID = ae.CI_ID
	AND ci2.ResourceID = s1.ResourceID
JOIN v_ApplicationAssignment aa ON ae.AssignmentID = aa.AssignmentID
WHERE ae.AppEnforcementState IS NOT NULL
	AND (s1.netbios_name0 IN ('Client01', ' Client02'))
ORDER BY ae.AppEnforcementState,
	LastComplianceMessageTime DESC

-- 124. Specific Software Update Deployment Failed Errors with Description
DECLARE @DeploymentName AS VARCHAR(255)

SET @DeploymentName = 'SU WKS-All Production Computers'

SELECT Vrs.Name0 AS 'MachineName',
	Vrs.User_Name0 AS 'UserName',
	assc.LastEnforcementMessageTime AS 'LastEnforcementTime',
	assc.LastEnforcementErrorID & 0x0000FFFF AS 'ErrorStatusID',
	isnull(master.dbo.fn_varbintohexstr(CONVERT(VARBINARY(8), CONVERT(INT, assc.LastEnforcementErrorCode))), 0) AS 'ErrorCode',
	assc.LastEnforcementErrorCode AS 'ErrorCodeInt',
	Asi.MessageName AS 'MessageName'
FROM V_CIAssignment cia
JOIN V_UpdateAssignmentStatus_Live assc ON assc.AssignmentID = cia.AssignmentID
INNER JOIN v_AssignmentState_Combined Ac ON Ac.ResourceID = assc.ResourceID
INNER JOIN V_AdvertisementStatusInformation Asi ON Asi.MessageID = Ac.LastStatusMessageID
	AND isnull(assc.IsCompliant, 0) = 0
	AND assc.LastEnforcementMessageID IN (6, 9)
	AND assc.LastEnforcementErrorCode NOT IN (0)
JOIN v_R_System Vrs ON assc.ResourceID = Vrs.ResourceID
	AND isnull(Vrs.Obsolete0, 0) = 0
WHERE cia.AssignmentName = @DeploymentName

-- 125. AL_Designer Exe File and Path with version - Based on Software Inventory
DECLARE @EXEName AS VARCHAR(255)

SET @EXEName = 'AL_Designer.exe'

SELECT DISTINCT Vr.Netbios_Name0 AS 'Name',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	Vr.Full_Domain_Name0 AS 'Domain',
	Vr.User_Name0 AS 'UserName',
	USR.Mail0 AS 'EMail ID',
	Vr.AD_Site_Name0 AS 'ADSite',
	SWSCAN.LastScanDate AS 'LastSWScan',
	DateDiff(D, SWSCAN.LastScanDate, GetDate()) AS 'LastSWScanAge',
	Sw.FileName AS 'FileName',
	Sw.FilePath AS 'FilePath',
	Sw.FileDescription AS 'FileDescription',
	Sw.FileModifiedDate AS 'FileModified',
	Sw.FileVersion AS 'FileVersion'
FROM v_R_System Vr
LEFT JOIN v_R_User Usr ON Vr.User_Name0 = Usr.User_Name0
LEFT JOIN v_GS_SoftwareFile Sw ON Vr.ResourceID = Sw.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON Vr.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_GS_LastSoftwareScan SWSCAN ON Vr.ResourceID = SWSCAN.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON Vr.ResourceID = Os.ResourceID
LEFT JOIN Computer_System_DATA St ON Vr.ResourceID = st.MachineID
LEFT JOIN v_FullCollectionMembership AS Col ON Vr.ResourceID = Col.ResourceID
WHERE FileName LIKE @EXEName
	AND Col.CollectionID = '01A0023D'
	AND VR.Operating_System_Name_and0 LIKE '%Workstation%'
GROUP BY Vr.Netbios_Name0,
	Os.Caption0,
	St.SystemType00,
	Vr.Full_Domain_Name0,
	Vr.User_Name0,
	USR.Mail0,
	Vr.AD_Site_Name0,
	SWSCAN.LastScanDate,
	Sw.FileName,
	Sw.FilePath,
	Sw.FileDescription,
	Sw.FileModifiedDate,
	Sw.FileVersion
ORDER BY Sw.FileName,
	Vr.Netbios_Name0

-- 126. Lync Exe File and Path with version - Based on Software Inventory
DECLARE @EXEName AS VARCHAR(255)

SET @EXEName = 'lync.exe'

SELECT DISTINCT Vr.Netbios_Name0 AS 'Name',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	Vr.Full_Domain_Name0 AS 'Domain',
	Vr.User_Name0 AS 'UserName',
	USR.Mail0 AS 'EMail ID',
	Vr.AD_Site_Name0 AS 'ADSite',
	SWSCAN.LastScanDate AS 'LastSWScan',
	DateDiff(D, SWSCAN.LastScanDate, GetDate()) AS 'LastSWScanAge',
	Sw.FileName AS 'FileName',
	Sw.FilePath AS 'FilePath',
	Sw.FileDescription AS 'FileDescription',
	Sw.FileModifiedDate AS 'FileModified',
	Sw.FileVersion AS 'FileVersion'
FROM v_R_System Vr
LEFT JOIN v_R_User Usr ON Vr.User_Name0 = Usr.User_Name0
LEFT JOIN v_GS_SoftwareFile Sw ON Vr.ResourceID = Sw.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON Vr.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_GS_LastSoftwareScan SWSCAN ON Vr.ResourceID = SWSCAN.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON Vr.ResourceID = Os.ResourceID
LEFT JOIN Computer_System_DATA St ON Vr.ResourceID = st.MachineID
LEFT JOIN v_FullCollectionMembership AS Col ON Vr.ResourceID = Col.ResourceID
WHERE FileName LIKE @EXEName
	AND Col.CollectionID = '01A0023D' --<
	AND VR.Operating_System_Name_and0 LIKE '%Workstation%'
GROUP BY Vr.Netbios_Name0,
	Os.Caption0,
	St.SystemType00,
	Vr.Full_Domain_Name0,
	Vr.User_Name0,
	USR.Mail0,
	Vr.AD_Site_Name0,
	SWSCAN.LastScanDate,
	Sw.FileName,
	Sw.FilePath,
	Sw.FileDescription,
	Sw.FileModifiedDate,
	Sw.FileVersion
ORDER BY Sw.FileName,
	Vr.Netbios_Name0

-- 127. All PCs with McAfee Antivirus Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.AD_Site_Name0 AS 'ADSite',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	App.ARPDisplayName0 AS 'DisplayName',
	App.InstallDate0 AS 'InstalledDate',
	App.ProductVersion0 AS 'Version'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership AS Col ON VRS.ResourceID = Col.ResourceID
LEFT JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE App.ARPDisplayName0 LIKE '%McAfee%VirusScan%Enterprise%'
	AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND Col.CollectionID = @Collection
	AND VRS.Client0 = 1
	AND VRS.Obsolete0 = 0
ORDER BY VRS.Name0,
	App.ProductVersion0

-- 128. All PCs without McAfee Antivirus Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT (vs.Name0) AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	Vs.AD_Site_Name0 AS 'ADSite',
	vs.Full_Domain_Name0 AS 'Domain',
	vs.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	HWSCAN.LastHWScan AS 'LastHWScan',
	DateDiff(D, HWSCAN.LastHwScan, GetDate()) AS 'LastHWScanAge'
FROM v_R_System vs
LEFT JOIN v_GS_SYSTEM_ENCLOSURE ON v_GS_SYSTEM_ENCLOSURE.ResourceID = vs.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON Vs.ResourceID = Os.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = vs.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON vs.ResourceID = HWSCAN.ResourceID
LEFT JOIN Computer_System_DATA St ON vs.ResourceID = st.MachineID
LEFT JOIN v_R_User ON vs.User_Name0 = v_R_User.User_Name0
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON vs.ResourceID = App.ResourceID
WHERE Vs.Operating_System_Name_and0 LIKE '%Workstation%'
	AND v_FullCollectionMembership.CollectionID = @Collection
	AND Vs.Client0 = 1
	AND Vs.Obsolete0 = 0
	AND vs.ResourceID NOT IN (
		SELECT Vrs.ResourceID
		FROM V_R_System VRS
		LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
		LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
		LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
		LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
		WHERE App.ARPDisplayName0 LIKE '%McAfee%VirusScan%Enterprise%'
		)

-- 129. All PCs with McAfee DLP Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.AD_Site_Name0 AS 'ADSite',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	App.ARPDisplayName0 AS 'DisplayName',
	App.InstallDate0 AS 'InstalledDate',
	App.ProductVersion0 AS 'Version'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership AS Col ON VRS.ResourceID = Col.ResourceID
LEFT JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE App.ARPDisplayName0 LIKE '%McAfee%VirusScan%Enterprise%'
	AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND Col.CollectionID = @Collection
	AND VRS.Client0 = 1
	AND VRS.Obsolete0 = 0
ORDER BY VRS.Name0,
	App.ProductVersion0

-- 130. All PCs without McAfee DLP Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT (vs.Name0) AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	Vs.AD_Site_Name0 AS 'ADSite',
	vs.Full_Domain_Name0 AS 'Domain',
	vs.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	HWSCAN.LastHWScan AS 'LastHWScan',
	DateDiff(D, HWSCAN.LastHwScan, GetDate()) AS 'LastHWScanAge'
FROM v_R_System vs
LEFT JOIN v_GS_SYSTEM_ENCLOSURE ON v_GS_SYSTEM_ENCLOSURE.ResourceID = vs.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON Vs.ResourceID = Os.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = vs.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON vs.ResourceID = HWSCAN.ResourceID
LEFT JOIN Computer_System_DATA St ON vs.ResourceID = st.MachineID
LEFT JOIN v_R_User ON vs.User_Name0 = v_R_User.User_Name0
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON vs.ResourceID = App.ResourceID
WHERE Vs.Operating_System_Name_and0 LIKE '%Workstation%'
	AND v_FullCollectionMembership.CollectionID = @Collection
	AND Vs.Client0 = 1
	AND Vs.Obsolete0 = 0
	AND vs.ResourceID NOT IN (
		SELECT Vrs.ResourceID
		FROM V_R_System VRS
		LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
		LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
		LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
		LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
		WHERE App.ARPDisplayName0 LIKE '%McAfee%VirusScan%Enterprise%'
		)

-- 131. All Workstations Adobe Products Installed Machines Report
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'Name',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	Vru.Mail0 AS 'EMailID',
	VRS.AD_Site_Name0 AS 'ADSite',
	ARP.Publisher0 AS 'Publisher',
	ARP.ARPDisplayName0 AS 'DisplayName',
	ARP.PackageCode0 AS 'ProductID',
	ARP.InstallDate0 AS 'InstalledDate',
	ARP.ProductVersion0 AS 'Version',
	CASE 
		WHEN ARP.ARPDisplayName0 LIKE '%Acrobat%Reader%'
			THEN 'Acrobat Reader Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Acrobat%Pro%'
			THEN 'Acrobat Pro Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%After%Effect%'
			THEN 'After Effect Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%AIR%'
			THEN 'Air Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Bridge%'
			THEN 'Bridge Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Design%Standard%'
			THEN 'Creative Cloud Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Dreamweaver%'
			THEN 'Dreamweaver Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Flash%Professional%'
			THEN 'Flash Professional Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Illustrator%'
			THEN 'Illustrator Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%InDesign%'
			THEN 'InDesign Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Lightroom%'
			THEN 'Lightroom Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Photoshop%'
			THEN 'Photoshop Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Premiere%'
			THEN 'Premiere Installed'
		ELSE 'Others'
		END 'AdobeProductName'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE ARP ON VRS.ResourceID = ARP.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT JOIN v_R_User Vru ON VRS.User_Name0 = Vru.User_Name0
WHERE ARP.Publisher0 LIKE '%Adobe%'
	AND (
		ARP.ARPDisplayName0 LIKE '%Acrobat%Reader%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Acrobat%Pro%'
		OR ARP.ARPDisplayName0 LIKE '%After%Effect%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%AIR%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Bridge%'
		OR ARP.ARPDisplayName0 LIKE '%Design%Standard%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Dreamweaver%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Flash%Professional%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Illustrator%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%InDesign%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Lightroom%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Photoshop%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Premiere%'
		)
	AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND v_FullCollectionMembership.CollectionID = @CollectionID
	AND VRS.Obsolete0 = 0
ORDER BY 13

-- 132. All Servers Adobe Products Installed Machines Report
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'Name',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	Vru.Mail0 AS 'EMailID',
	VRS.AD_Site_Name0 AS 'ADSite',
	ARP.Publisher0 AS 'Publisher',
	ARP.ARPDisplayName0 AS 'DisplayName',
	ARP.PackageCode0 AS 'ProductID',
	ARP.InstallDate0 AS 'InstalledDate',
	ARP.ProductVersion0 AS 'Version',
	CASE 
		WHEN ARP.ARPDisplayName0 LIKE '%Acrobat%Reader%'
			THEN 'Acrobat Reader Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Acrobat%Pro%'
			THEN 'Acrobat Pro Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%After%Effect%'
			THEN 'After Effect Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%AIR%'
			THEN 'Air Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Bridge%'
			THEN 'Bridge Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Design%Standard%'
			THEN 'Creative Cloud Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Dreamweaver%'
			THEN 'Dreamweaver Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Flash%Professional%'
			THEN 'Flash Professional Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Illustrator%'
			THEN 'Illustrator Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%InDesign%'
			THEN 'InDesign Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Lightroom%'
			THEN 'Lightroom Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Photoshop%'
			THEN 'Photoshop Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Premiere%'
			THEN 'Premiere Installed'
		ELSE 'Others'
		END 'AdobeProductName'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE ARP ON VRS.ResourceID = ARP.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT JOIN v_R_User Vru ON VRS.User_Name0 = Vru.User_Name0
WHERE ARP.Publisher0 LIKE '%Adobe%'
	AND (
		ARP.ARPDisplayName0 LIKE '%Acrobat%Reader%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Acrobat%Pro%'
		OR ARP.ARPDisplayName0 LIKE '%After%Effect%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%AIR%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Bridge%'
		OR ARP.ARPDisplayName0 LIKE '%Design%Standard%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Dreamweaver%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Flash%Professional%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Illustrator%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%InDesign%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Lightroom%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Photoshop%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Premiere%'
		)
	AND VRS.Operating_System_Name_and0 LIKE '%Server%'
	AND v_FullCollectionMembership.CollectionID = @CollectionID
	AND VRS.Obsolete0 = 0
ORDER BY 13

-- 133. All Workstations Adobe Products Installed Machines with Disk Space Report
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'Name',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	Vru.Mail0 AS 'EMailID',
	VRS.AD_Site_Name0 AS 'ADSite',
	LD.DeviceID00 AS 'Drive',
	LD.FileSystem00 AS 'FileSystem',
	LD.Size00 / 1024 AS 'TotalSpace (GB)',
	LD.FreeSpace00 / 1024 AS 'FreeSpace (GB)',
	HWSCAN.LastHWScan AS 'LastHWScan',
	DateDiff(D, HWSCAN.LastHwScan, GetDate()) AS 'LastHWScanAge',
	ARP.Publisher0 AS 'Publisher',
	ARP.ARPDisplayName0 AS 'DisplayName',
	ARP.PackageCode0 AS 'ProductID',
	ARP.InstallDate0 AS 'InstalledDate',
	ARP.ProductVersion0 AS 'Version',
	CASE 
		WHEN ARP.ARPDisplayName0 LIKE '%Acrobat%Reader%'
			THEN 'Acrobat Reader Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Acrobat%Pro%'
			THEN 'Acrobat Pro Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%After%Effect%'
			THEN 'After Effect Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%AIR%'
			THEN 'Air Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Bridge%'
			THEN 'Bridge Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Design%Standard%'
			THEN 'Creative Cloud Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Dreamweaver%'
			THEN 'Dreamweaver Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Flash%Professional%'
			THEN 'Flash Professional Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Illustrator%'
			THEN 'Illustrator Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%InDesign%'
			THEN 'InDesign Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Lightroom%'
			THEN 'Lightroom Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Photoshop%'
			THEN 'Photoshop Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Premiere%'
			THEN 'Premiere Installed'
		ELSE 'Others'
		END 'AdobeProductName'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE ARP ON VRS.ResourceID = ARP.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN Logical_Disk_Data Ld ON Ld.MachineID = Vrs.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT JOIN v_R_User Vru ON VRS.User_Name0 = Vru.User_Name0
WHERE ARP.Publisher0 LIKE '%Adobe%'
	AND (
		ARP.ARPDisplayName0 LIKE '%Acrobat%Reader%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Acrobat%Pro%'
		OR ARP.ARPDisplayName0 LIKE '%After%Effect%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%AIR%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Bridge%'
		OR ARP.ARPDisplayName0 LIKE '%Design%Standard%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Dreamweaver%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Flash%Professional%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Illustrator%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%InDesign%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Lightroom%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Photoshop%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Premiere%'
		)
	AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND v_FullCollectionMembership.CollectionID = @CollectionID
	AND LD.Description00 = 'Local Fixed Disk'
	AND VRS.Obsolete0 = 0
ORDER BY 13

-- 134. All Servers Adobe Products Installed Machines with Disk Space Report
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'Name',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	Vru.Mail0 AS 'EMailID',
	VRS.AD_Site_Name0 AS 'ADSite',
	LD.DeviceID00 AS 'Drive',
	LD.FileSystem00 AS 'FileSystem',
	LD.Size00 / 1024 AS 'TotalSpace (GB)',
	LD.FreeSpace00 / 1024 AS 'FreeSpace (GB)',
	HWSCAN.LastHWScan AS 'LastHWScan',
	DateDiff(D, HWSCAN.LastHwScan, GetDate()) AS 'LastHWScanAge',
	ARP.Publisher0 AS 'Publisher',
	ARP.ARPDisplayName0 AS 'DisplayName',
	ARP.PackageCode0 AS 'ProductID',
	ARP.InstallDate0 AS 'InstalledDate',
	ARP.ProductVersion0 AS 'Version',
	CASE 
		WHEN ARP.ARPDisplayName0 LIKE '%Acrobat%Reader%'
			THEN 'Acrobat Reader Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Acrobat%Pro%'
			THEN 'Acrobat Pro Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%After%Effect%'
			THEN 'After Effect Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%AIR%'
			THEN 'Air Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Bridge%'
			THEN 'Bridge Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Design%Standard%'
			THEN 'Creative Cloud Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Dreamweaver%'
			THEN 'Dreamweaver Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Flash%Professional%'
			THEN 'Flash Professional Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Illustrator%'
			THEN 'Illustrator Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%InDesign%'
			THEN 'InDesign Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Lightroom%'
			THEN 'Lightroom Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Photoshop%'
			THEN 'Photoshop Installed'
		WHEN ARP.ARPDisplayName0 LIKE '%Adobe%Premiere%'
			THEN 'Premiere Installed'
		ELSE 'Others'
		END 'AdobeProductName'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE ARP ON VRS.ResourceID = ARP.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN Logical_Disk_Data Ld ON Ld.MachineID = Vrs.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT JOIN v_R_User Vru ON VRS.User_Name0 = Vru.User_Name0
WHERE ARP.Publisher0 LIKE '%Adobe%'
	AND (
		ARP.ARPDisplayName0 LIKE '%Acrobat%Reader%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Acrobat%Pro%'
		OR ARP.ARPDisplayName0 LIKE '%After%Effect%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%AIR%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Bridge%'
		OR ARP.ARPDisplayName0 LIKE '%Design%Standard%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Dreamweaver%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Flash%Professional%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Illustrator%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%InDesign%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Lightroom%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Photoshop%'
		OR ARP.ARPDisplayName0 LIKE '%Adobe%Premiere%'
		)
	AND VRS.Operating_System_Name_and0 LIKE '%Server%'
	AND v_FullCollectionMembership.CollectionID = @CollectionID
	AND LD.Description00 = 'Local Fixed Disk'
	AND VRS.Obsolete0 = 0
ORDER BY 13

-- 135. Deployments status for specific applications
SELECT aa.ApplicationName AS 'Application Name',
	aa.CollectionName AS 'Target Collection',
	ae.descript AS 'DeploymentTypeName',
	s1.netbios_name0 AS 'ComputerName',
	s1.AD_Site_Name0 AS 'ADSiteName',
	CASE 
		WHEN ae.AppEnforcementState = 1000
			THEN 'Success'
		WHEN ae.AppEnforcementState = 1001
			THEN 'Already Compliant'
		WHEN ae.AppEnforcementState = 1002
			THEN 'Simulate Success'
		WHEN ae.AppEnforcementState = 2000
			THEN 'In Progress'
		WHEN ae.AppEnforcementState = 2001
			THEN 'Waiting for Content'
		WHEN ae.AppEnforcementState = 2002
			THEN 'Installing'
		WHEN ae.AppEnforcementState = 2003
			THEN 'Restart to Continue'
		WHEN ae.AppEnforcementState = 2004
			THEN 'Waiting for maintenance window'
		WHEN ae.AppEnforcementState = 2005
			THEN 'Waiting for schedule'
		WHEN ae.AppEnforcementState = 2006
			THEN 'Downloading dependent content'
		WHEN ae.AppEnforcementState = 2007
			THEN 'Installing dependent content'
		WHEN ae.AppEnforcementState = 2008
			THEN 'Restart to complete'
		WHEN ae.AppEnforcementState = 2009
			THEN 'Content downloaded'
		WHEN ae.AppEnforcementState = 2010
			THEN 'Waiting for update'
		WHEN ae.AppEnforcementState = 2011
			THEN 'Waiting for user session reconnect'
		WHEN ae.AppEnforcementState = 2012
			THEN 'Waiting for user logoff'
		WHEN ae.AppEnforcementState = 2013
			THEN 'Waiting for user logon'
		WHEN ae.AppEnforcementState = 2014
			THEN 'Waiting to install'
		WHEN ae.AppEnforcementState = 2015
			THEN 'Waiting retry'
		WHEN ae.AppEnforcementState = 2016
			THEN 'Waiting for presentation mode'
		WHEN ae.AppEnforcementState = 2017
			THEN 'Waiting for Orchestration'
		WHEN ae.AppEnforcementState = 2018
			THEN 'Waiting for network'
		WHEN ae.AppEnforcementState = 2019
			THEN 'Pending App-V Virtual Environment'
		WHEN ae.AppEnforcementState = 2020
			THEN 'Updating App-V Virtual Environment'
		WHEN ae.AppEnforcementState = 3000
			THEN 'Requirements not met'
		WHEN ae.AppEnforcementState = 3001
			THEN 'Host platform not applicable'
		WHEN ae.AppEnforcementState = 4000
			THEN 'Unknown'
		WHEN ae.AppEnforcementState = 5000
			THEN 'Deployment failed'
		WHEN ae.AppEnforcementState = 5001
			THEN 'Evaluation failed'
		WHEN ae.AppEnforcementState = 5002
			THEN 'Deployment failed'
		WHEN ae.AppEnforcementState = 5003
			THEN 'Failed to locate content'
		WHEN ae.AppEnforcementState = 5004
			THEN 'Dependency installation failed'
		WHEN ae.AppEnforcementState = 5005
			THEN 'Failed to download dependent content'
		WHEN ae.AppEnforcementState = 5006
			THEN 'Conflicts with another application deployment'
		WHEN ae.AppEnforcementState = 5007
			THEN 'Waiting retry'
		WHEN ae.AppEnforcementState = 5008
			THEN 'Failed to uninstall superseded deployment type'
		WHEN ae.AppEnforcementState = 5009
			THEN 'Failed to download superseded deployment type'
		WHEN ae.AppEnforcementState = 5010
			THEN 'Failed to updating App-V Virtual Environment'
		END AS 'State Message',
	CASE 
		WHEN ae.AppEnforcementState LIKE '10%'
			THEN 'Success'
		WHEN ae.AppEnforcementState LIKE '20%'
			THEN 'Progress'
		WHEN ae.AppEnforcementState LIKE '30%'
			THEN 'ReqNotMet'
		WHEN ae.AppEnforcementState LIKE '40%'
			THEN 'Unknown'
		WHEN ae.AppEnforcementState LIKE '50%'
			THEN 'Failed'
		END AS 'Status',
	LastComplianceMessageTime AS 'LastMessageTime'
FROM v_R_System_Valid s1
JOIN vAppDTDeploymentResultsPerClient ae ON ae.ResourceID = s1.ResourceID
JOIN v_CICurrentComplianceStatus ci2 ON ci2.CI_ID = ae.CI_ID
	AND ci2.ResourceID = s1.ResourceID
JOIN v_ApplicationAssignment aa ON ae.AssignmentID = aa.AssignmentID
WHERE ae.AppEnforcementState IS NOT NULL
	AND aa.ApplicationName IN ('ApplicationName1', 'ApplicationName2', 'ApplicationName3')
ORDER BY ae.AppEnforcementState,
	LastComplianceMessageTime DESC

-- 136. Deployments status for specific packages
SELECT DISTINCT pack.Name AS 'Package Name',
	COLL.CollectionName AS 'Target Collection',
	adv.ProgramName AS 'DeploymentTypeName',
	Vrs.Name0 AS 'ComputerName',
	Vrs.AD_Site_Name0 AS 'ADSiteName',
	ADV.AdvertisementID AS 'AdvertisementID',
	ADVS.LastStateName AS 'Status',
	ADVS.LastStatusTime AS 'Status Time'
FROM v_R_System Vrs
INNER JOIN vSMS_ClientAdvertisementStatus ADVS ON Vrs.ResourceID = ADVS.ResourceID
INNER JOIN v_Advertisement ADV ON ADV.AdvertisementID = ADVS.AdvertisementID
INNER JOIN v_FullCollectionMembership CM ON Vrs.ResourceID = CM.ResourceID
LEFT JOIN v_Package Pack ON adv.PackageID = pack.PackageID
LEFT JOIN v_Collections COLL ON ADV.CollectionID = COLL.SiteID
WHERE pack.Name IN ('PackageName1', 'PackageName2', 'PackageName3')
ORDER BY Vrs.Name0

-- 137. Deployment status for specific software Update deployments
SELECT vrs.Name0,
	vrs.Active0,
	vrs.AD_Site_Name0,
	vrs.User_Name0,
	vrs.Operating_System_Name_and0,
	a.Assignment_UniqueID AS DeploymentID,
	a.AssignmentName AS DeploymentName,
	a.StartTime AS Available,
	a.EnforcementDeadline AS Deadline,
	sn.StateName AS LastEnforcementState,
	wsus.LastErrorCode AS 'LasErrorCode',
	wsus.LastScanTime AS 'LastWSUSScan',
	DateDiff(D, wsus.LastScanTime, GetDate()) AS 'LastWSUSScan Age',
	wks.LastHWScan,
	DateDiff(D, wks.LastHwScan, GetDate()) AS 'LastHWScan Age'
FROM v_CIAssignment a
JOIN v_AssignmentState_Combined assc ON a.AssignmentID = assc.AssignmentID
JOIN v_StateNames sn ON assc.StateType = sn.TopicType
	AND sn.StateID = isnull(assc.StateID, 0)
JOIN v_R_System vrs ON vrs.ResourceID = assc.ResourceID
JOIN v_GS_WORKSTATION_STATUS wks ON wks.ResourceID = assc.ResourceID
JOIN v_UpdateScanStatus wsus ON wsus.ResourceID = assc.ResourceID
WHERE a.AssignmentName IN ('UpdateGroupDeploymentName1', ' UpdateGroupDeploymentName 2', ' UpdateGroupDeploymentName 3')
	AND assc.StateType IN (300, 301)
ORDER BY 11 DESC

-- 138. Find SQL Server Installed Version
SELECT @@VERSION AS 'SQL Server Installed Version'

-- 139. Find SCCM SQL Database Size with Database File Path
SELECT Sys.FILEID AS 'FileID',
	left(Sys.NAME, 15) AS 'DBName',
	left(Sys.FILENAME, 60) AS 'DBFilePath',
	convert(DECIMAL(12, 2), round(Sys.size / 128.000, 2)) AS 'Filesize (MB)',
	convert(DECIMAL(12, 2), round(fileproperty(Sys.name, 'SpaceUsed') / 128.000, 2)) AS 'UsedSpace (MB)',
	convert(DECIMAL(12, 2), round((Sys.size - fileproperty(Sys.name, 'SpaceUsed')) / 128.000, 2)) AS 'FreeSpace (MB)',
	convert(DECIMAL(12, 2), round(Sys.growth / 128.000, 2)) AS 'GrowthSpace (MB)'
FROM dbo.sysfiles Sys

-- 140. Find Overall SCCM Site Hierarchy Information
SELECT DISTINCT (
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Site System'
		) AS 'SCCM SVR Counts',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Site Server'
		) AS 'SCCM Site Counts',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList Vrl
		INNER JOIN V_site Vs ON Vs.ServerName = Vrl.ServerName
		WHERE Vrl.RoleName = 'SMS Site Server'
			AND Vs.Type = 3
			AND Vs.ReportingSiteCode IS NOT NULL
		) AS 'CAS Site Counts',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList Vrl
		INNER JOIN V_site Vs ON Vs.ServerName = Vrl.ServerName
		WHERE Vrl.RoleName = 'SMS Site Server'
			AND Vs.Type = 2
			AND Vs.ReportingSiteCode IS NOT NULL
		) AS 'PRI Site Counts',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList Vrl
		INNER JOIN V_site Vs ON Vs.ServerName = Vrl.ServerName
		WHERE Vrl.RoleName = 'SMS Site Server'
			AND Vs.Type = 1
			AND Vs.ReportingSiteCode IS NOT NULL
		) AS 'SEC Site Counts',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Management Point'
		) AS 'MP SVR Counts',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Distribution Point'
		) AS 'DP SVR Counts',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Software Update Point'
		) AS 'SUP SVR Counts',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS SRS Reporting Point'
		) AS 'SSRS SVR Counts',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Provider'
		) AS 'SMSPro SVR Counts'
FROM v_SystemResourceList

-- 141. Find SCCM Site Hierarchy Detailed Information
SELECT V_Site.SiteCode AS 'SiteCode',
	V_Site.ReportingSiteCode AS 'ReportTo',
	V_Site.ServerName AS 'ServerName',
	V_Site.SiteName AS 'SiteName',
	CASE 
		WHEN V_Site.Type = 3
			AND V_Site.ReportingSiteCode IS NOT NULL
			THEN 'CAS Site Server'
		WHEN V_Site.Type = 2
			AND V_Site.ReportingSiteCode = ''
			THEN 'Standalone Primary Site Server'
		WHEN V_Site.Type = 2
			AND V_Site.ReportingSiteCode IS NOT NULL
			THEN 'Primary Site Server'
		WHEN V_Site.Type = 1
			AND V_Site.ReportingSiteCode IS NOT NULL
			THEN 'Secondary Site Server'
		ELSE 'Others'
		END AS 'Site Server Detail',
	V_Site.InstallDir AS 'Installed Directory',
	CASE 
		WHEN V_Site.BuildNumber = '7711'
			THEN '2012 RTM'
		WHEN V_Site.BuildNumber = '7804'
			THEN '2012 SP1'
		WHEN V_Site.BuildNumber = '7958'
			THEN '2012 R2'
		WHEN V_Site.BuildNumber = '8239'
			THEN '2012 R2 SP1'
		WHEN V_Site.BuildNumber = '8325'
			THEN '1511'
		WHEN V_Site.BuildNumber = '8355'
			THEN '1602'
		WHEN V_Site.BuildNumber = '8412'
			THEN '1606'
		WHEN V_Site.BuildNumber = '8458'
			THEN '1610'
		ELSE 'Others'
		END AS 'SCCM Version',
	V_Site.Version AS 'Build Version'
FROM V_Site

-- 142. Find Overall Windows Workstations Client Machines OS category with counts
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT Os.Caption0 AS 'Operating System',
	COUNT(*) AS 'Total'
FROM v_FullCollectionMembership Vf
INNER JOIN v_GS_OPERATING_SYSTEM Os ON Os.ResourceID = Vf.ResourceID
WHERE Vf.CollectionID = @CollectionID
	AND Vf.ResourceID IN (
		SELECT ResourceID
		FROM v_R_System
		WHERE Operating_System_Name_and0 LIKE '%Workstation%'
		)
GROUP BY Os.Caption0
ORDER BY Os.Caption0 DESC

-- 143. Find Overall Windows Servers Client Machines OS category with counts
DECLARE @CollectionID AS VARCHAR(8)

SET @CollectionID = 'SMS00001' -- specify scope collection ID

SELECT Os.Caption0 AS 'Operating System',
	COUNT(*) AS 'Total'
FROM v_FullCollectionMembership Vf
INNER JOIN v_GS_OPERATING_SYSTEM Os ON Os.ResourceID = Vf.ResourceID
WHERE Vf.CollectionID = @CollectionID
	AND Vf.ResourceID IN (
		SELECT ResourceID
		FROM v_R_System
		WHERE Operating_System_Name_and0 LIKE '%Server%'
		)
GROUP BY Os.Caption0
ORDER BY Os.Caption0 DESC

-- 144. Find Overall WSUS Server Configurations and Ports 
SELECT *
FROM wsusserverlocations

-- 145. SEP Antivirus with Specific Version Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.AD_Site_Name0 AS 'ADSite',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	App.ARPDisplayName0 AS 'DisplayName',
	App.InstallDate0 AS 'InstalledDate',
	App.ProductVersion0 AS 'Version'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership AS Col ON VRS.ResourceID = Col.ResourceID
LEFT JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE App.ARPDisplayName0 LIKE 'Symantec%Endpoint%Protection%'
	AND App.ProductVersion0 LIKE '%14.0%'
	AND VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND Col.CollectionID = @Collection
	AND VRS.Client0 = 1
	AND VRS.Obsolete0 = 0
ORDER BY VRS.Name0,
	App.ProductVersion0

-- 146. SEP Antivirus without Specific Version Installed Machines Report Based on Installed Software
DECLARE @Collection VARCHAR(8)
DECLARE @ApplicationName VARCHAR(255)
DECLARE @ApplicationVersion VARCHAR(255)

SET @Collection = 'SMS00001' -- specify scope collection ID Set @ApplicationName = 'Symantec%Endpoint%Protection%' -- specify Application Name Set @ApplicationVersion = '%14.0%' -- specify Application Version

SELECT DISTINCT (vs.Name0) AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	Vs.AD_Site_Name0 AS 'ADSite',
	vs.Full_Domain_Name0 AS 'Domain',
	vs.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	HWSCAN.LastHWScan AS 'LastHWScan',
	DateDiff(D, HWSCAN.LastHwScan, GetDate()) AS 'LastHWScanAge'
FROM v_R_System vs
LEFT JOIN v_GS_SYSTEM_ENCLOSURE ON v_GS_SYSTEM_ENCLOSURE.ResourceID = vs.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON Vs.ResourceID = Os.ResourceID
LEFT JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = vs.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON vs.ResourceID = HWSCAN.ResourceID
LEFT JOIN Computer_System_DATA St ON vs.ResourceID = st.MachineID
LEFT JOIN v_R_User ON vs.User_Name0 = v_R_User.User_Name0
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON vs.ResourceID = App.ResourceID
WHERE Vs.Operating_System_Name_and0 LIKE '%Workstation%'
	AND v_FullCollectionMembership.CollectionID = @Collection
	AND Vs.Client0 = 1
	AND Vs.Obsolete0 = 0
	AND vs.ResourceID NOT IN (
		SELECT Vrs.ResourceID
		FROM V_R_System VRS
		LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
		LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
		LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
		LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
		WHERE App.ARPDisplayName0 LIKE @ApplicationName
			AND App.ProductVersion0 LIKE @ApplicationVersion
		)

-- 147. All Application Installed on Specific Collection
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.AD_Site_Name0 AS 'ADSite',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	App.ARPDisplayName0 AS 'DisplayName',
	App.InstallDate0 AS 'InstalledDate',
	App.ProductVersion0 AS 'Version'
FROM V_R_System VRS
LEFT JOIN v_GS_INSTALLED_SOFTWARE App ON VRS.ResourceID = App.ResourceID
LEFT JOIN Computer_System_DATA St ON VRS.ResourceID = st.MachineID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON VRS.ResourceID = Os.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN ON VRS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_FullCollectionMembership AS Col ON VRS.ResourceID = Col.ResourceID
LEFT JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE Col.CollectionID = @Collection
	AND VRS.Client0 = 1
	AND VRS.Obsolete0 = 0
ORDER BY VRS.Name0,
	App.ProductVersion0

-- 148. All Client Health Last Month SLA and KPI Data status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @TotalMachines AS NUMERIC(8)
DECLARE @Healthy AS NUMERIC(8)
DECLARE @UnHealthy AS NUMERIC(8)
DECLARE @HWInventorySuccess AS NUMERIC(8)
DECLARE @HWInventoryNotRun AS NUMERIC(8)
DECLARE @WSUSScanSuccess AS NUMERIC(8)
DECLARE @WSUSScanNotRun AS NUMERIC(8)

SET @CollectionID = 'SMS00001'

SELECT @TotalMachines = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
		)

SELECT @Healthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND IsClient = 1
		)

SELECT @UnHealthy = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND IsClient = 1
				)
		)

SELECT @HWInventorySuccess = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_GS_WORKSTATION_STATUS
				WHERE (DATEDIFF(day, LastHWScan, GetDate()) < 30)
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_AgentDiscoveries
						WHERE AgentName IN ('Heartbeat Discovery')
							AND DATEDIFF(day, AgentTime, GetDate()) < 30
						)
				)
		)

SELECT @HWInventoryNotRun = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsClient = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_GS_WORKSTATION_STATUS
						WHERE (DATEDIFF(day, LastHWScan, GetDate()) < 30)
							AND ResourceID IN (
								SELECT ResourceID
								FROM v_AgentDiscoveries
								WHERE AgentName IN ('Heartbeat Discovery')
									AND DATEDIFF(day, AgentTime, GetDate()) < 30
								)
						)
				)
		)

SELECT @WSUSScanSuccess = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID IN (
				SELECT ResourceID
				FROM v_UpdateScanStatus
				WHERE lastErrorCode = 0
					AND (DATEDIFF(day, LastScanTime, GetDate()) < 30)
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_AgentDiscoveries
						WHERE AgentName IN ('Heartbeat Discovery')
							AND DATEDIFF(day, AgentTime, GetDate()) < 30
						)
				)
		)

SELECT @WSUSScanNotRun = (
		SELECT COUNT(*)
		FROM v_FullCollectionMembership
		WHERE CollectionID = @CollectionID
			AND IsAssigned = 1
			AND IsClient = 1
			AND IsActive = 1
			AND IsObsolete != 1
			AND ResourceID NOT IN (
				SELECT ResourceID
				FROM v_FullCollectionMembership
				WHERE CollectionID = @CollectionID
					AND IsAssigned = 1
					AND IsClient = 1
					AND IsActive = 1
					AND IsObsolete != 1
					AND ResourceID IN (
						SELECT ResourceID
						FROM v_UpdateScanStatus
						WHERE lastErrorCode = 0
							AND (DATEDIFF(day, LastScanTime, GetDate()) < 30)
							AND ResourceID IN (
								SELECT ResourceID
								FROM v_AgentDiscoveries
								WHERE AgentName IN ('Heartbeat Discovery')
									AND DATEDIFF(day, AgentTime, GetDate()) < 30
								)
						)
				)
		)

SELECT @TotalMachines AS 'TotalMachines',
	@Healthy AS 'Healthy',
	@UnHealthy AS 'UnHealthy',
	(
		SELECT (@Healthy / @TotalMachines) * 100
		) AS 'Healthy%',
	@HWInventorySuccess AS 'HWInventorySuccess',
	@HWInventoryNotRun AS 'HWInventoryNotRun',
	(
		SELECT (@HWInventorySuccess / @Healthy) * 100
		) AS 'HWInventorySuccess%',
	@WSUSScanSuccess AS 'WSUSScanSuccess',
	@WSUSScanNotRun AS 'WSUSScanNotRun',
	(
		SELECT (@WSUSScanSuccess / @Healthy) * 100
		) AS 'WSUSScanSuccess%'

-- 149. All Software Applications Last Month deployments SLA and KPI Data status
DECLARE @AppDeploymentsReportNeededMonths AS INTEGER

SET @AppDeploymentsReportNeededMonths = 1 --Specify the no of Months

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Vaa.ApplicationName AS 'ApplicationName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		WHEN Ds.DeploymentIntent = 3
			THEN 'Simulate'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_ApplicationAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 1
	AND (DATEDIFF(m, Ds.CreationTime, GETDATE()) = @AppDeploymentsReportNeededMonths)
	AND (DATEDIFF(m, Ds.DeploymentTime, GETDATE()) = @AppDeploymentsReportNeededMonths)
ORDER BY Ds.DeploymentTime DESC

-- 150. All Software Packages Last Month deployments SLA and KPI Data status
DECLARE @PKGDeploymentsReportNeededMonths AS INTEGER

SET @PKGDeploymentsReportNeededMonths = 1 --Specify the no of Months

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Left(Ds.SoftwareName, CharIndex('(', (Ds.SoftwareName)) - 1) AS 'ApplicationName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.ModificationTime, GetDate()) AS 'CreatedDays',
	Ds.CreationTime AS 'CreationTime',
	Ds.ModificationTime AS 'LastModifiedTime',
	'Administrator' AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 2
	AND (DATEDIFF(m, Ds.ModificationTime, GETDATE()) = @PKGDeploymentsReportNeededMonths)
	AND (
		(Ds.ProgramName NOT LIKE 'Shop-Install%')
		AND (Ds.ProgramName NOT LIKE 'Shop-Uninst%')
		)
ORDER BY Ds.DeploymentTime DESC

-- 151. All Software Updates Last Month deployments SLA and KPI Data status
DECLARE @PatchDeploymentsReportNeededMonths AS INTEGER

SET @PatchDeploymentsReportNeededMonths = 1 --Specify the no of Months

SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	'Software Update' AS 'PackageName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'Others',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberSuccess = 0)
			OR (Ds.NumberSuccess IS NULL)
			THEN '0'
		ELSE (round(Ds.NumberSuccess / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_CIAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 5
	AND (DATEDIFF(m, Vaa.CreationTime, GETDATE()) = @PatchDeploymentsReportNeededMonths)
ORDER BY Ds.DeploymentTime DESC

-- 152. All OS Last Month deployments SLA and KPI Data status
DECLARE @OSDeploymentsReportNeededMonths AS INTEGER

SET @OSDeploymentsReportNeededMonths = 1 --Specify the no of Months

SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Ds.SoftwareName AS 'TaskSequenceName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.ModificationTime, GetDate()) AS 'CreatedDays',
	Ds.CreationTime AS 'CreationTime',
	Ds.ModificationTime AS 'LastModifiedTime',
	'Administrator' AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 7
	AND (DATEDIFF(m, Ds.ModificationTime, GETDATE()) = @OSDeploymentsReportNeededMonths)
ORDER BY Ds.DeploymentTime DESC

-- 153. Selected KB Article ID patch required or installed status for Specific Collection ID
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.AD_Site_Name0 AS 'ADSite',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	UI.ArticleID AS 'ArticleID',
	UI.BulletinID AS 'BulletinID',
	UI.Title AS 'Title',
	CASE 
		WHEN UCS.STATUS = 2
			THEN 'Required'
		WHEN UCS.STATUS = 3
			THEN 'Installed'
		ELSE 'Unknown'
		END AS 'KBStatus',
	UI.InfoURL AS 'InformationURL'
FROM v_UpdateComplianceStatus UCS
INNER JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
INNER JOIN v_CICategories_All CIC ON UI.CI_ID = CIC.CI_ID
INNER JOIN v_CategoryInfo CI ON CIC.CategoryInstanceID = CI.CategoryInstanceID
INNER JOIN v_R_System VRS ON UCS.ResourceID = VRS.ResourceID
INNER JOIN v_GS_OPERATING_SYSTEM Os ON UCS.ResourceID = Os.ResourceID
INNER JOIN Computer_System_DATA St ON UCS.ResourceID = st.MachineID
INNER JOIN v_FullCollectionMembership Col ON UCS.ResourceID = Col.ResourceID
WHERE VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND Col.CollectionID = @Collection
	AND UI.articleid IN ('4012212', '4012213', '4012214', '4012598')
	AND UI.BulletinID IN ('ms17-010', 'ms17-008') --<
	AND active0 = 1
	AND client0 = 1
ORDER BY 10

-- 154. Selected KB Article ID patch required or installed status for Specific Collection ID
DECLARE @Collection VARCHAR(8)

SET @Collection = 'SMS00001' -- specify scope collection ID

SELECT DISTINCT VRS.Name0 AS 'MachineName',
	Os.Caption0 AS 'OperatingSystem',
	St.SystemType00 AS 'OSType',
	VRS.AD_Site_Name0 AS 'ADSite',
	VRS.Full_Domain_Name0 AS 'Domain',
	VRS.User_Name0 AS 'UserName',
	UI.ArticleID AS 'ArticleID',
	UI.BulletinID AS 'BulletinID',
	UI.Title AS 'Title',
	CASE 
		WHEN UCS.STATUS = 2
			THEN 'Required'
		WHEN UCS.STATUS = 3
			THEN 'Installed'
		ELSE 'Unknown'
		END AS 'KBStatus',
	UI.InfoURL AS 'InformationURL'
FROM v_UpdateComplianceStatus UCS
INNER JOIN v_UpdateInfo UI ON UCS.CI_ID = UI.CI_ID
INNER JOIN v_CICategories_All CIC ON UI.CI_ID = CIC.CI_ID
INNER JOIN v_CategoryInfo CI ON CIC.CategoryInstanceID = CI.CategoryInstanceID
INNER JOIN v_R_System VRS ON UCS.ResourceID = VRS.ResourceID
INNER JOIN v_GS_OPERATING_SYSTEM Os ON UCS.ResourceID = Os.ResourceID
INNER JOIN Computer_System_DATA St ON UCS.ResourceID = st.MachineID
INNER JOIN v_FullCollectionMembership Col ON UCS.ResourceID = Col.ResourceID
WHERE VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND Col.CollectionID = @Collection
	AND UI.articleid IN ('4012212', '4012213', '4012214', '4012598')
	AND UI.BulletinID IN ('ms17-010', 'ms17-008') --<
	AND active0 = 1
	AND client0 = 1
ORDER BY 10

-- 155. Site Status Overview Status 
SELECT SiteStatus.SiteCode,
	SiteInfo.SiteName,
	SiteStatus.Updated 'Time Stamp',
	CASE SiteStatus.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Site Status',
	CASE SiteInfo.STATUS
		WHEN 1
			THEN 'Active'
		WHEN 2
			THEN 'Pending'
		WHEN 3
			THEN 'Failed'
		WHEN 4
			THEN 'Deleted'
		WHEN 5
			THEN 'Upgrade'
		ELSE ' '
		END AS 'Site State'
FROM V_SummarizerSiteStatus SiteStatus
JOIN v_Site SiteInfo ON SiteStatus.SiteCode = SiteInfo.SiteCode
WHERE SiteInfo.STATUS <> 1
ORDER BY SiteCode

-- 156. Site Status Status
SELECT DISTINCT SiteCode 'Site Code',
	SUBSTRING(SiteSystem, CHARINDEX('\\', SiteSystem) + 2, CHARINDEX('"]', SiteSystem) - CHARINDEX('\\', SiteSystem) - 3) AS 'Site System',
	REPLACE(ROLE, 'SMS', 'ConfigMgr') 'Role',
	CASE ObjectType
		WHEN 0
			THEN 'Directory'
		WHEN 1
			THEN 'SQL Database'
		WHEN 2
			THEN 'SQL Transaction Log'
		ELSE ' '
		END AS 'Object Type',
	CAST(BytesTotal / 1024 AS VARCHAR(49)) + 'MB' 'Total',
	CAST(BytesFree / 1024 AS VARCHAR(49)) + 'MB' 'Free',
	CASE PercentFree
		WHEN - 1
			THEN 'Unknown'
		WHEN - 2
			THEN 'Automatically grow'
		ELSE CAST(PercentFree AS VARCHAR(49)) + '%'
		END AS '%Free',
	CASE v_SiteSystemSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_SiteSystemSummarizer --where v_SiteSystemSummarizer.Status <> 0 Order By 1
	-- 157. Site Components Status 

SELECT DISTINCT SiteCode,
	MachineName 'ServerName',
	ComponentName,
	CASE v_componentSummarizer.STATE
		WHEN 0
			THEN 'Stopped'
		WHEN 1
			THEN 'Started'
		WHEN 2
			THEN 'Paused'
		WHEN 3
			THEN 'Installing'
		WHEN 4
			THEN 'Re-Installing'
		WHEN 5
			THEN 'De-Installing'
		ELSE ' '
		END AS 'Thread State',
	Errors,
	Warnings,
	Infos,
	CASE v_componentSummarizer.Type
		WHEN 0
			THEN 'Autostarting'
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Manual'
		ELSE ' '
		END AS 'StartupType',
	CASE AvailabilityState
		WHEN 0
			THEN 'Online'
		WHEN 3
			THEN 'Offline'
		ELSE ' '
		END AS 'State',
	CASE v_ComponentSummarizer.STATUS
		WHEN 0
			THEN 'OK'
		WHEN 1
			THEN 'Warning'
		WHEN 2
			THEN 'Critical'
		ELSE ' '
		END AS 'Status'
FROM v_ComponentSummarizer
WHERE TallyInterval = '0001128000100008'
	AND (
		v_ComponentSummarizer.STATUS = 2
		OR v_ComponentSummarizer.STATUS = 1
		)
ORDER BY ComponentName,
	SiteCode

-- 158. Overall Content Distribution Status 
SELECT DPSI.Name,
	(DPSI.NumberInstalled + DPSI.NumberInProgress + DPSI.NumberErrors + DPSI.NumberUnknown) AS 'NumberTotal',
	DPSI.NumberInstalled,
	DPSI.NumberInProgress,
	DPSI.NumberErrors,
	DPSI.NumberUnknown
FROM vSMS_DPStatusInfo DPSI
ORDER BY 2 DESC

-- 159. Compare Two DP’s Packages Status
SELECT Pkg.PackageID,
	Pkg.Name
FROM v_Package Pkg
WHERE Pkg.PackageID IN (
		SELECT PackageID
		FROM v_DistributionPoint
		WHERE ServerNALPath LIKE '%DPName1%'
			AND PackageID NOT IN (
				SELECT PackageID
				FROM v_DistributionPoint
				WHERE ServerNALPath LIKE '% DPName2%'
				)
		)

-- 160. Top Users for Specific Computer Status 
SELECT DISTINCT Vrs.Name0 AS [Computer Name],
	Os.Caption0 AS [Operating System],
	Enc.SerialNumber0 AS [Service Tag],
	Vgs.Manufacturer0 AS [Make],
	Vrs.User_Name0 AS [Last Logged on User],
	Con.TopConsoleUser0 AS [Top User]
FROM v_r_system Vrs
LEFT JOIN v_gs_computer_system Vgs ON Vrs.ResourceID = Vgs.ResourceID
LEFT JOIN v_gs_system_enclosure Enc ON Vrs.ResourceID = Enc.ResourceID
LEFT JOIN v_GS_SYSTEM_CONSOLE_USAGE Con ON Vrs.ResourceID = Con.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM Os ON Vrs.ResourceID = Os.ResourceID
ORDER BY Vrs.Name0

-- 161. Software Update Group Created, Modified or Deleted Properties
SELECT rsm.Severity,
	rsm.MessageTypeString AS 'Type',
	rsm.SiteCode,
	rsm.TIMESTAMP AS 'Date/Time',
	rsm.System,
	rsm.Component,
	rsm.MessageID,
	'User "' + rsm.InsStrValue1 + '"' + CASE 
		WHEN rsm.MessageID = 30196
			THEN ' created updates assignment '
		WHEN rsm.MessageID = 30197
			THEN ' modified updates assignment '
		WHEN rsm.MessageID = 30198
			THEN ' deleted updates assignment '
		WHEN rsm.MessageID = 30219
			THEN ' created authorization list '
		WHEN rsm.MessageID = 30220
			THEN ' modified authorization list '
		WHEN rsm.MessageID = 30221
			THEN ' deleted authorization list '
		END + rsm.InsStrValue2 + ' ' + rsm.InsStrValue3 + ' ' + rsm.InsStrValue4 AS 'Description',
	cia.CollectionID,
	cia.CollectionName
FROM v_Report_StatusMessageDetail rsm
LEFT JOIN v_CIAssignment cia ON rsm.InsStrValue2 = cia.AssignmentID
WHERE rsm.MessageID >= 30196
	AND rsm.MessageID <= 30198
	OR rsm.MessageID >= 30218
	AND rsm.MessageID <= 30221
ORDER BY 4 DESC

-- 162. Software Update last month patch compliance report using Compliance Settings 
DECLARE @StartDate DATETIME,
	@EndDate DATETIME

SET @StartDate = DATEADD(mm, DATEDIFF(m, 0, GETDATE()) - 2, 0)
SET @EndDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) - 1, 0))

SELECT dbo.v_R_System.ResourceID,
	dbo.v_R_System.Name0 AS [Name],
	dbo.v_CICurrentComplianceStatus.ComplianceState,
	v_LocalizedCIProperties_SiteLoc.DisplayName AS [BaselineName],
	CAST(dbo.v_LocalizedCIProperties_SiteLoc.Description AS DATETIME) AS [BaselineDate],
	SUMMARY.LastActiveTime,
	OP.LastBootUpTime0 AS [LastBootUpTime],
	DATEDIFF(Day, OP.LastBootUpTime0, GETDATE()) AS [DaysSinceReboot]
FROM dbo.v_BaselineTargetedComputers
INNER JOIN dbo.v_R_System ON v_R_System.ResourceID = dbo.v_BaselineTargetedComputers.ResourceID
INNER JOIN dbo.v_ConfigurationItems ON dbo.v_ConfigurationItems.CI_ID = v_BaselineTargetedComputers.CI_ID
INNER JOIN dbo.v_CICurrentComplianceStatus ON dbo.v_CICurrentComplianceStatus.CI_ID = dbo.v_ConfigurationItems.CI_ID
	AND dbo.v_CICurrentComplianceStatus.ResourceID = dbo.v_BaselineTargetedComputers.ResourceID
INNER JOIN dbo.v_LocalizedCIProperties_SiteLoc ON dbo.v_LocalizedCIProperties_SiteLoc.CI_ID = dbo.v_ConfigurationItems.CI_ID
INNER JOIN dbo.v_CH_ClientSummary SUMMARY ON dbo.v_R_System.ResourceID = SUMMARY.ResourceID
LEFT JOIN dbo.v_GS_OPERATING_SYSTEM OP ON dbo.v_R_System.ResourceID = OP.ResourceID
WHERE dbo.v_LocalizedCIProperties_SiteLoc.DisplayName LIKE 'Windows Updates %'
	AND dbo.v_LocalizedCIProperties_SiteLoc.DisplayName LIKE 'Windows Updates April%'
	AND CAST(dbo.v_LocalizedCIProperties_SiteLoc.Description AS DATETIME) BETWEEN @StartDate
		AND @EndDate
ORDER BY dbo.v_R_System.Name0

-- 163. Client Health showing inactive or failed clients status
SELECT ClientstateDescription AS [ClientState],
	COUNT(ResourceID) AS [NumberofClients],
	CONVERT(VARCHAR, 100 * count(*) / tot, 1) AS 'Percent'
FROM v_CH_ClientSummary,
	(
		SELECT COUNT(*) AS tot
		FROM v_CH_ClientSummary
		) x
GROUP BY ClientstateDescription,
	tot
ORDER BY [NumberofClients] DESC

-- 164. Check if allow clients to use fallback source location for content
--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
WITH XMLNAMESPACES (
	DEFAULT 'http://schemas.microsoft.com/SystemsCenterConfigurationManager/2009/06/14/Rules',
	'http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest' AS p1
	) SELECT A.[App Name] [Application],
	max (A.[DT Name]) [DT Name],
	A.Type,
	A.ExecutionContext,
	A.RequiresLogOn,
	A.UserInteractionMode,
	CASE 
		WHEN A.FallbackToUnprotectedDP = 'true'
			THEN 'Yes'
		ELSE 'No'
		END
AS [FallbackToUnprotectedDP],
	A.OnSlowNetwork FROM (
	SELECT LPC.DisplayName [App Name],
		(LDT.SDMPackageDigest.value('(/p1:AppMgmtDigest/p1:DeploymentType/p1:Title)[1]', 'nvarchar(max)')) AS [DT Name],
		LDT.SDMPackageDigest.value('(/p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/@Technology)[1]', 'nvarchar(max)') AS [Type],
		LDT.SDMPackageDigest.value('(/p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:Contents/p1:Content/p1:Location)[1]', 'nvarchar(max)') AS [ContentLocation],
		LDT.SDMPackageDigest.value('(/p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:UninstallAction/p1:Args/p1:Arg)[1]', 'nvarchar(max)') AS [UninstallCommandLine],
		LDT.SDMPackageDigest.value('(/p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:InstallAction/p1:Args/p1:Arg)[3]', 'nvarchar(max)') AS [ExecutionContext],
		LDT.SDMPackageDigest.value('(/p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:InstallAction/p1:Args/p1:Arg)[4]', 'nvarchar(max)') AS [RequiresLogOn],
		LDT.SDMPackageDigest.value('(/p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:InstallAction/p1:Args/p1:Arg)[8]', 'nvarchar(max)') AS [UserInteractionMode],
		LDT.SDMPackageDigest.value('(/p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:Contents/p1:Content/p1:FallbackToUnprotectedDP)[1]', 'nvarchar(max)') AS [FallbackToUnprotectedDP],
		LDT.SDMPackageDigest.value('(/p1:AppMgmtDigest/p1:DeploymentType/p1:Installer/p1:Contents/p1:Content/p1:OnSlowNetwork)[1]', 'nvarchar(max)') AS [OnSlowNetwork]
	FROM dbo.fn_ListApplicationCIs(1033) LPC
	RIGHT JOIN fn_ListDeploymentTypeCIs(1033) LDT ON LDT.AppModelName = LPC.ModelName
	WHERE LDT.CIType_ID = 21
		AND LDT.IsLatest = 1
	) A GROUP BY A.[App Name],
	A.Type,
	A.ExecutionContext,
	A.RequiresLogOn,
	A.UserInteractionMode,
	A.OnSlowNetwork,
	A.FallbackToUnprotectedDP

-- 165. All Workstations Computers Name with Last Logon User and Serial No Detailed Report 
DECLARE @CollectionID VARCHAR(8)

SET @CollectionID = 'SMS00001'

SELECT DISTINCT (VRS.Netbios_Name0) AS 'Name',
	PC_BIOS_DATA.SerialNumber00 AS 'SerialNumber',
	VRS.User_Domain0 + '\' + VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID'
FROM V_R_System VRS
LEFT OUTER JOIN PC_BIOS_DATA ON PC_BIOS_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN Operating_System_DATA ON Operating_System_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN v_Gs_Operating_System ON v_Gs_Operating_System.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND (
		VRS.Obsolete0 = 0
		OR VRS.Obsolete0 IS NULL
		)
	AND VRS.Client0 = 1
	AND v_FullCollectionMembership.CollectionID = @CollectionID
GROUP BY VRS.Netbios_Name0,
	VRS.Client0,
	PC_BIOS_DATA.SerialNumber00,
	Vrs.User_Domain0,
	Vrs.User_Name0,
	v_R_User.Mail0
ORDER BY VRS.Netbios_Name0

-- 166. Check Client Versions with Percentage
DECLARE @CollectionID VARCHAR(8)

SET @CollectionID = 'SMS00001'

SELECT sys.Client_version0 AS 'Client Version',
	CASE 
		WHEN sys.client_version0 = '5.00.8325.1000'
			THEN 'ConfigMgr 1511'
		WHEN sys.client_version0 = '5.00.8355.1000'
			THEN 'ConfigMgr 1602'
		WHEN sys.client_version0 = '5.00.8355.1306'
			THEN 'ConfigMgr 1602 - Update Rollup 1'
		WHEN sys.client_version0 = '5.00.8412.1007'
			THEN 'ConfigMgr 1606'
		WHEN sys.client_version0 = '5.00.8355.1306'
			THEN 'ConfigMgr 1602 - Update Rollup 1'
		WHEN sys.client_version0 = '5.00.8412.1307'
			THEN 'ConfigMgr 1606 - Update Rollup 1'
		WHEN sys.client_version0 = '5.00.8458.1007'
			THEN 'ConfigMgr 1610'
		WHEN sys.client_version0 = '5.00.8458.1520'
			THEN 'SCCM 1610 - Update rollup (KB4010155)'
		WHEN sys.client_version0 = '5.00.8498.1008'
			THEN 'ConfigMgr 1702'
		WHEN sys.client_version0 = '5.00.8498.1711'
			THEN 'ConfigMgr 1702 - Update rollup 1 (KB4019926)'
		ELSE sys.client_version0
		END AS 'ConfigMgr Release',
	Count(DISTINCT sys.ResourceID) AS 'Client Count',
	(
		STR((
				COUNT(sys.ResourceID) * 100.0 / (
					SELECT COUNT(SYS.ResourceID)
					FROM v_FullCollectionMembership FCM
					INNER JOIN V_R_System sys ON FCM.ResourceID = SYS.ResourceID
					WHERE FCM.CollectionID = @CollectionID
						AND Sys.Client0 = '1'
					)
				), 5, 2)
		) + ' %' AS 'Percent %'
FROM v_FullCollectionMembership FCM
INNER JOIN V_R_System sys ON FCM.ResourceID = SYS.ResourceID
WHERE SYS.Client0 = '1'
	AND FCM.CollectionID = @CollectionID
GROUP BY sys.Client_version0
ORDER BY sys.Client_version0 DESC

-- 167. Microsoft Installed application counts for a specific Collection
DECLARE @CollectionID VARCHAR(8)

SET @CollectionID = 'SMS00001'

SELECT DISTINCT DisplayName0,
	Count(arp.ResourceID) AS 'Count',
	Publisher0,
	@CollectionID AS CollectionID
FROM v_Add_Remove_Programs arp
JOIN v_FullCollectionMembership fcm ON arp.ResourceID = fcm.ResourceID
WHERE fcm.CollectionID = @CollectionID
	AND (Publisher0 LIKE 'Microsoft%')
	AND DisplayName0 NOT LIKE '%Hotfix%'
	AND DisplayName0 NOT LIKE '%Security Update%'
	AND DisplayName0 NOT LIKE '%Update for%'
	AND DisplayName0 NOT LIKE '%.NET%'
	AND DisplayName0 NOT LIKE '%Viewer%'
	AND DisplayName0 NOT LIKE '%Language Pack%'
	AND DisplayName0 NOT LIKE '%Internet Explorer%'
	AND DisplayName0 NOT LIKE '%MSXML%'
	AND DisplayName0 NOT LIKE '%SDK%'
	AND DisplayName0 NOT LIKE '%C++%'
	AND DisplayName0 NOT LIKE '%Redistributable%'
	AND DisplayName0 NOT LIKE '%Search%'
	AND DisplayName0 NOT LIKE '%SMS%'
	AND DisplayName0 NOT LIKE '%Silverlight%'
	AND DisplayName0 NOT LIKE '%Live Meeting%'
	AND DisplayName0 NOT LIKE '%(KB%'
	AND DisplayName0 NOT LIKE '%Office Web%'
	AND DisplayName0 NOT LIKE '%Office %Proof%'
	AND DisplayName0 NOT LIKE '%Server %Proof%'
	AND DisplayName0 NOT LIKE '%Office %Shared%'
	AND DisplayName0 NOT LIKE '%Baseline Security Analyzer%'
	AND DisplayName0 NOT LIKE '%Compatibility Pack%'
	AND DisplayName0 NOT LIKE '%User State Migration Tools%'
GROUP BY DisplayName0,
	Publisher0
ORDER BY Publisher0

-- 168. Client Health Dashboard
DECLARE @CollectionID VARCHAR(8)

SET @CollectionID = 'SMS00001'

SELECT Vrs.Name0 AS 'Computer Name',
	Vrs.User_Name0 AS 'User Name',
	CASE 
		WHEN Vrs.client0 = 1
			THEN 'Installed'
		ELSE 'NotInstalled'
		END AS 'ClientAgentStatus',
	summ.ClientStateDescription,
	CASE 
		WHEN summ.ClientActiveStatus = 0
			THEN 'Inactive'
		WHEN summ.ClientActiveStatus = 1
			THEN 'Active'
		END AS 'ClientActiveStatus',
	summ.LastActiveTime,
	CASE 
		WHEN summ.IsActiveDDR = 0
			THEN 'Inactive'
		WHEN summ.IsActiveDDR = 1
			THEN 'Active'
		END AS 'IsActiveDDR',
	CASE 
		WHEN summ.IsActiveHW = 0
			THEN 'Inactive'
		WHEN summ.IsActiveHW = 1
			THEN 'Active'
		END AS 'IsActiveHW',
	CASE 
		WHEN summ.IsActiveSW = 0
			THEN 'Inactive'
		WHEN summ.IsActiveSW = 1
			THEN 'Active'
		END AS 'IsActiveSW',
	CASE 
		WHEN summ.ISActivePolicyRequest = 0
			THEN 'Inactive'
		WHEN summ.ISActivePolicyRequest = 1
			THEN 'Active'
		END AS 'ISActivePolicyRequest',
	CASE 
		WHEN summ.IsActiveStatusMessages = 0
			THEN 'Inactive'
		WHEN summ.IsActiveStatusMessages = 1
			THEN 'Active'
		END AS 'IsActiveStatusMessages',
	summ.LastOnline,
	summ.LastDDR,
	summ.LastHW,
	summ.LastSW,
	summ.LastPolicyRequest,
	summ.LastStatusMessage,
	summ.LastHealthEvaluation,
	CASE 
		WHEN LastHealthEvaluationResult = 1
			THEN 'Not Yet Evaluated'
		WHEN LastHealthEvaluationResult = 2
			THEN 'Not Applicable'
		WHEN LastHealthEvaluationResult = 3
			THEN 'Evaluation Failed'
		WHEN LastHealthEvaluationResult = 4
			THEN 'Evaluated Remediated Failed'
		WHEN LastHealthEvaluationResult = 5
			THEN 'Not Evaluated Dependency Failed'
		WHEN LastHealthEvaluationResult = 6
			THEN 'Evaluated Remediated Succeeded'
		WHEN LastHealthEvaluationResult = 7
			THEN 'Evaluation Succeeded'
		END AS 'Last Health Evaluation Result',
	CASE 
		WHEN LastEvaluationHealthy = 1
			THEN 'Pass'
		WHEN LastEvaluationHealthy = 2
			THEN 'Fail'
		WHEN LastEvaluationHealthy = 3
			THEN 'Unknown'
		END AS 'Last Evaluation Healthy',
	CASE 
		WHEN summ.ClientRemediationSuccess = 1
			THEN 'Pass'
		WHEN summ.ClientRemediationSuccess = 2
			THEN 'Fail'
		ELSE ''
		END AS 'ClientRemediationSuccess',
	summ.ExpectedNextPolicyRequest
FROM V_R_System Vrs
LEFT JOIN v_CH_ClientSummary summ ON Vrs.ResourceID = summ.ResourceID
WHERE Vrs.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership fcm
		WHERE fcm.CollectionID = @CollectionID
		)
ORDER BY Vrs.Name0

-- 169. Client Version with Percentage 
DECLARE @CollectionID VARCHAR(8)

SET @CollectionID = 'SMS00001'

SELECT sys.Client_version0 AS 'Client Version',
	CASE 
		WHEN sys.client_version0 = '5.00.8325.1000'
			THEN 'ConfigMgr 1511'
		WHEN sys.client_version0 = '5.00.8355.1000'
			THEN 'ConfigMgr 1602'
		WHEN sys.client_version0 = '5.00.8355.1306'
			THEN 'ConfigMgr 1602 - Update Rollup 1'
		WHEN sys.client_version0 = '5.00.8412.1007'
			THEN 'ConfigMgr 1606'
		WHEN sys.client_version0 = '5.00.8355.1306'
			THEN 'ConfigMgr 1602 - Update Rollup 1'
		WHEN sys.client_version0 = '5.00.8412.1307'
			THEN 'ConfigMgr 1606 - Update Rollup 1'
		WHEN sys.client_version0 = '5.00.8458.1007'
			THEN 'ConfigMgr 1610'
		WHEN sys.client_version0 = '5.00.8458.1520'
			THEN 'SCCM 1610 - Update rollup (KB4010155)'
		WHEN sys.client_version0 = '5.00.8498.1008'
			THEN 'ConfigMgr 1702'
		WHEN sys.client_version0 = '5.00.8498.1711'
			THEN 'ConfigMgr 1702 - Update rollup 1 (KB4019926)'
		ELSE sys.client_version0
		END AS 'ConfigMgr Release',
	Count(DISTINCT sys.ResourceID) AS 'Client Count',
	(
		STR((
				COUNT(sys.ResourceID) * 100.0 / (
					SELECT COUNT(SYS.ResourceID)
					FROM v_FullCollectionMembership FCM
					INNER JOIN V_R_System sys ON FCM.ResourceID = SYS.ResourceID
					WHERE FCM.CollectionID = @CollectionID
						AND Sys.Client0 = '1'
					)
				), 5, 2)
		) + ' %' AS 'Percent %'
FROM v_FullCollectionMembership FCM
INNER JOIN V_R_System sys ON FCM.ResourceID = SYS.ResourceID
WHERE SYS.Client0 = '1'
	AND FCM.CollectionID = @CollectionID
GROUP BY sys.Client_version0
ORDER BY sys.Client_version0 DESC

-- 170. Compare packages with Another DP
SELECT Pkg.PackageID,
	Pkg.Name,
	CASE Pkg.PackageType
		WHEN 0
			THEN 'Package'
		WHEN 3
			THEN 'Driver'
		WHEN 4
			THEN 'TaskSequence'
		WHEN 5
			THEN 'softwareUpdate'
		WHEN 7
			THEN 'Virtual'
		WHEN 8
			THEN 'Application'
		WHEN 257
			THEN 'Image'
		WHEN 258
			THEN 'BootImage'
		WHEN 259
			THEN 'OS'
		ELSE ' '
		END AS 'Type'
FROM v_Package Pkg
WHERE Pkg.PackageID IN (
		SELECT PackageID
		FROM v_DistributionPoint
		WHERE ServerNALPath LIKE '%Master DP%'
			AND PackageID NOT IN (
				SELECT PackageID
				FROM v_DistributionPoint
				WHERE ServerNALPath LIKE '%Compare DP%'
				)
		)
ORDER BY 3

-- 171. OneDrivesetup and Groove application report based on Software Inventory
DECLARE @CollectionID VARCHAR(8)

SET @CollectionID = 'SMS00001'

SELECT DISTINCT Vrs.Netbios_Name0,
	Vrs.User_Name0,
	Vrs.AD_Site_Name0,
	Sf.FileVersion,
	Sf.FileName,
	Sf.FileVersion
FROM v_R_System Vrs
INNER JOIN v_GS_SoftwareFile Sf ON Vrs.ResourceID = Sf.ResourceID
INNER JOIN v_FullCollectionMembership Fcm ON Vrs.ResourceID = Fcm.ResourceId
WHERE Sf.FileName LIKE 'OneDriveSetup.exe'
	OR Sf.FileName LIKE 'groove.exe'
	AND Fcm.CollectionID = @CollectionID
GROUP BY Vrs.Netbios_Name0,
	Vrs.User_Name0,
	Vrs.AD_Site_Name0,
	Sf.FileName,
	Sf.FileVersion
ORDER BY Vrs.Netbios_Name0

-- 172. All SCCM Servers Inventory status
SELECT DISTINCT (VRS.Netbios_Name0) AS 'Server Name',
	CASE 
		WHEN VRS.Client0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Client',
	CASE 
		WHEN VRS.Active0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Active',
	CASE 
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 1
			THEN 'VMWare'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 IN ('3', '4')
			THEN 'Desktop'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 IN ('8', '9', '10', '11', '12', '14')
			THEN 'Laptop'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 6
			THEN 'Mini Tower'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 7
			THEN 'Tower'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 13
			THEN 'All in One'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 15
			THEN 'Space-Saving'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 17
			THEN 'Main System Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 21
			THEN 'Peripheral Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 22
			THEN 'Storage Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 23
			THEN 'Rack Mount Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 24
			THEN 'Sealed-Case PC'
		ELSE 'Others'
		END 'CaseType',
	LEFT(MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0), ISNULL(NULLIF(CHARINDEX(',', MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0)) - 1, - 1), LEN(MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0)))) AS 'IPAddress',
	MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.MACAddress0) AS 'MACAddress',
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 AS 'AssignedSite',
	VRS.Client_Version0 AS 'ClientVersion',
	VRS.Creation_Date0 AS 'ClientCreationDate',
	DateDiff(D, VRS.Creation_Date0, GetDate()) 'ClientCreationDateAge',
	VRS.AD_Site_Name0 AS 'ADSiteName',
	dbo.v_GS_OPERATING_SYSTEM.InstallDate0 AS 'OSInstallDate',
	DateDiff(D, v_GS_OPERATING_SYSTEM.InstallDate0, GetDate()) 'OSInstallDateAge',
	Convert(VARCHAR, v_Gs_Operating_System.LastBootUpTime0, 100) AS 'LastBootDate',
	DateDiff(D, Convert(VARCHAR, v_Gs_Operating_System.LastBootUpTime0, 100), GetDate()) AS 'LastBootDateAge',
	PC_BIOS_DATA.SerialNumber00 AS 'SerialNumber',
	v_GS_SYSTEM_ENCLOSURE.SMBIOSAssetTag0 AS 'AssetTag',
	PC_BIOS_DATA.ReleaseDate00 AS 'ReleaseDate',
	PC_BIOS_DATA.Name00 AS 'BiosName',
	PC_BIOS_DATA.SMBIOSBIOSVersion00 AS 'BiosVersion',
	v_GS_PROCESSOR.Name0 AS 'ProcessorName',
	CASE 
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'VMware%'
			THEN 'VMWare'
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'Gigabyte%'
			THEN 'Gigabyte'
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'VIA Technologies%'
			THEN 'VIA Technologies'
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'MICRO-STAR%'
			THEN 'MICRO-STAR'
		ELSE Computer_System_DATA.Manufacturer00
		END 'Manufacturer',
	Computer_System_DATA.Model00 AS 'Model',
	Computer_System_DATA.SystemType00 AS 'OSType',
	v_GS_COMPUTER_SYSTEM.Domain0 AS 'DomainName',
	VRS.User_Domain0 + '\' + VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	CASE 
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 0
			THEN 'Standalone Workstation'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 1
			THEN 'Member Workstation'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 2
			THEN 'Standalone Server'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 3
			THEN 'Member Server'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 4
			THEN 'Backup Domain Controller'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 5
			THEN 'Primary Domain Controller'
		END 'Role',
	CASE 
		WHEN Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Enterprise Edition'
			THEN 'Microsoft(R) Windows(R) Server 2003 Enterprise Edition'
		WHEN Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Standard Edition'
			THEN 'Microsoft(R) Windows(R) Server 2003 Standard Edition'
		WHEN Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Web Edition'
			THEN 'Microsoft(R) Windows(R) Server 2003 Web Edition'
		ELSE Operating_System_DATA.Caption00
		END 'OSName',
	Operating_System_DATA.CSDVersion00 AS 'ServicePack',
	Operating_System_DATA.Version00 AS 'Version',
	((v_GS_X86_PC_MEMORY.TotalPhysicalMemory0 / 1024) / 1000) AS 'TotalRAMSize(GB)',
	max(v_GS_LOGICAL_DISK.Size0 / 1024) AS 'TotalHDDSize(GB)',
	v_GS_WORKSTATION_STATUS.LastHWScan AS 'LastHWScan',
	DateDiff(D, v_GS_WORKSTATION_STATUS.LastHwScan, GetDate()) AS 'LastHWScanAge'
FROM V_R_System VRS
LEFT OUTER JOIN PC_BIOS_DATA ON PC_BIOS_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN Operating_System_DATA ON Operating_System_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN v_GS_WORKSTATION_STATUS ON v_GS_WORKSTATION_STATUS.ResourceID = VRS.ResourceId
LEFT OUTER JOIN Computer_System_DATA ON Computer_System_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN v_GS_X86_PC_MEMORY ON v_GS_X86_PC_MEMORY.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_PROCESSOR ON v_GS_PROCESSOR.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_SYSTEM_ENCLOSURE ON v_GS_SYSTEM_ENCLOSURE.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_Gs_Operating_System ON v_Gs_Operating_System.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_RA_System_SMSAssignedSites ON v_RA_System_SMSAssignedSites.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_COMPUTER_SYSTEM ON v_GS_COMPUTER_SYSTEM.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_NETWORK_ADAPTER_CONFIGUR ON v_GS_NETWORK_ADAPTER_CONFIGUR.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_LOGICAL_DISK ON v_GS_LOGICAL_DISK.ResourceID = Vrs.ResourceId
	AND v_GS_LOGICAL_DISK.DriveType0 = 3
LEFT OUTER JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE (
		VRS.Obsolete0 = 0
		OR VRS.Obsolete0 IS NULL
		)
	AND VRS.Netbios_Name0 IN (
		SELECT LEFT(ServerName, CHARINDEX('.', ServerName) - 1)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Site System'
		)
GROUP BY VRS.Netbios_Name0,
	VRS.Client0,
	VRS.Active0,
	v_GS_SYSTEM_ENCLOSURE.ChassisTypes0,
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0,
	VRS.Client_Version0,
	Vrs.Creation_Date0,
	Vrs.AD_Site_Name0,
	v_Gs_Operating_System.InstallDate0,
	v_Gs_Operating_System.LastBootUpTime0,
	PC_BIOS_DATA.SerialNumber00,
	v_GS_SYSTEM_ENCLOSURE.SMBIOSAssetTag0,
	PC_BIOS_DATA.ReleaseDate00,
	PC_BIOS_DATA.Name00,
	PC_BIOS_DATA.SMBIOSBIOSVersion00,
	v_GS_PROCESSOR.Name0,
	Computer_System_DATA.Manufacturer00,
	Computer_System_DATA.Model00,
	Computer_System_DATA.SystemType00,
	v_GS_COMPUTER_SYSTEM.Domain0,
	Vrs.User_Domain0,
	Vrs.User_Name0,
	v_R_User.Mail0,
	v_GS_COMPUTER_SYSTEM.DomainRole0,
	Operating_System_DATA.Caption00,
	Operating_System_DATA.CSDVersion00,
	Operating_System_DATA.Version00,
	v_GS_X86_PC_MEMORY.TotalPhysicalMemory0,
	v_GS_WORKSTATION_STATUS.LastHWScan
ORDER BY VRS.Netbios_Name0

-- 173. All Workstations Assets Inventory details status
DECLARE @CollectionID AS VARCHAR(8)
DECLARE @ProjectName AS VARCHAR(25)

SET @CollectionID = 'SMS00001'
SET @ProjectName = 'LAB'

SELECT DISTINCT (VRS.Netbios_Name0) AS 'Name',
	CASE 
		WHEN VRS.Client0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Client',
	CASE 
		WHEN VRS.Active0 = 1
			THEN 'Yes'
		ELSE 'No'
		END 'Active',
	CASE 
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 1
			THEN 'VMWare'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 IN ('3', '4')
			THEN 'Desktop'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 IN ('8', '9', '10', '11', '12', '14')
			THEN 'Laptop'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 6
			THEN 'Mini Tower'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 7
			THEN 'Tower'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 13
			THEN 'All in One'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 15
			THEN 'Space-Saving'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 17
			THEN 'Main System Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 21
			THEN 'Peripheral Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 22
			THEN 'Storage Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 23
			THEN 'Rack Mount Chassis'
		WHEN v_GS_SYSTEM_ENCLOSURE.ChassisTypes0 = 24
			THEN 'Sealed-Case PC'
		ELSE 'Others'
		END 'CaseType',
	LEFT(MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0), ISNULL(NULLIF(CHARINDEX(',', MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0)) - 1, - 1), LEN(MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0)))) AS 'IPAddress',
	MAX(v_GS_NETWORK_ADAPTER_CONFIGUR.MACAddress0) AS 'MACAddress',
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0 AS 'AssignedSite',
	VRS.Client_Version0 AS 'ClientVersion',
	VRS.Creation_Date0 AS 'ClientCreationDate',
	VRS.AD_Site_Name0 AS 'ADSiteName',
	dbo.v_GS_OPERATING_SYSTEM.InstallDate0 AS 'OSInstallDate',
	DateDiff(D, dbo.v_GS_OPERATING_SYSTEM.InstallDate0, GetDate()) 'OSInstallDateAge',
	Convert(VARCHAR, v_Gs_Operating_System.LastBootUpTime0, 100) AS 'LastBootDate',
	DateDiff(D, Convert(VARCHAR, v_Gs_Operating_System.LastBootUpTime0, 100), GetDate()) AS 'LastBootDateAge',
	PC_BIOS_DATA.SerialNumber00 AS 'SerialNumber',
	v_GS_SYSTEM_ENCLOSURE.SMBIOSAssetTag0 AS 'AssetTag',
	PC_BIOS_DATA.ReleaseDate00 AS 'ReleaseDate',
	PC_BIOS_DATA.Name00 AS 'BiosName',
	PC_BIOS_DATA.SMBIOSBIOSVersion00 AS 'BiosVersion',
	v_GS_PROCESSOR.Name0 AS 'ProcessorName',
	CASE 
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'VMware%'
			THEN 'VMWare'
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'Gigabyte%'
			THEN 'Gigabyte'
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'VIA Technologies%'
			THEN 'VIA Technologies'
		WHEN Computer_System_DATA.Manufacturer00 LIKE 'MICRO-STAR%'
			THEN 'MICRO-STAR'
		ELSE Computer_System_DATA.Manufacturer00
		END 'Manufacturer',
	Computer_System_DATA.Model00 AS 'Model',
	Computer_System_DATA.SystemType00 AS 'OSType',
	v_GS_COMPUTER_SYSTEM.Domain0 AS 'DomainName',
	VRS.User_Domain0 + '\' + VRS.User_Name0 AS 'UserName',
	v_R_User.Mail0 AS 'EMailID',
	CASE 
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 0
			THEN 'Standalone Workstation'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 1
			THEN 'Member Workstation'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 2
			THEN 'Standalone Server'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 3
			THEN 'Member Server'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 4
			THEN 'Backup Domain Controller'
		WHEN v_GS_COMPUTER_SYSTEM.domainrole0 = 5
			THEN 'Primary Domain Controller'
		END 'Role',
	CASE 
		WHEN Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Enterprise Edition'
			THEN 'Microsoft(R) Windows(R) Server 2003 Enterprise Edition'
		WHEN Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Standard Edition'
			THEN 'Microsoft(R) Windows(R) Server 2003 Standard Edition'
		WHEN Operating_System_DATA.Caption00 = 'Microsoft(R) Windows(R) Server 2003, Web Edition'
			THEN 'Microsoft(R) Windows(R) Server 2003 Web Edition'
		ELSE Operating_System_DATA.Caption00
		END 'OSName',
	Operating_System_DATA.CSDVersion00 AS 'ServicePack',
	Operating_System_DATA.Version00 AS 'Version',
	((v_GS_X86_PC_MEMORY.TotalPhysicalMemory0 / 1024) / 1000) AS 'TotalRAMSize(GB)',
	max(v_GS_LOGICAL_DISK.Size0 / 1024) AS 'TotalHDDSize(GB)',
	v_GS_WORKSTATION_STATUS.LastHWScan AS 'LastHWScan',
	DateDiff(D, v_GS_WORKSTATION_STATUS.LastHwScan, GetDate()) AS 'LastHWScanAge',
	@ProjectName AS 'AccountName'
FROM V_R_System VRS
LEFT OUTER JOIN PC_BIOS_DATA ON PC_BIOS_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN Operating_System_DATA ON Operating_System_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN v_GS_WORKSTATION_STATUS ON v_GS_WORKSTATION_STATUS.ResourceID = VRS.ResourceId
LEFT OUTER JOIN Computer_System_DATA ON Computer_System_DATA.MachineID = VRS.ResourceId
LEFT OUTER JOIN v_GS_X86_PC_MEMORY ON v_GS_X86_PC_MEMORY.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_PROCESSOR ON v_GS_PROCESSOR.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_SYSTEM_ENCLOSURE ON v_GS_SYSTEM_ENCLOSURE.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_Gs_Operating_System ON v_Gs_Operating_System.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_RA_System_SMSAssignedSites ON v_RA_System_SMSAssignedSites.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_COMPUTER_SYSTEM ON v_GS_COMPUTER_SYSTEM.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_FullCollectionMembership ON v_FullCollectionMembership.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_NETWORK_ADAPTER_CONFIGUR ON v_GS_NETWORK_ADAPTER_CONFIGUR.ResourceID = VRS.ResourceId
LEFT OUTER JOIN v_GS_LOGICAL_DISK ON v_GS_LOGICAL_DISK.ResourceID = Vrs.ResourceId
	AND v_GS_LOGICAL_DISK.DriveType0 = 3
LEFT OUTER JOIN v_R_User ON VRS.User_Name0 = v_R_User.User_Name0
WHERE VRS.Operating_System_Name_and0 LIKE '%Workstation%'
	AND (
		VRS.Obsolete0 = 0
		OR VRS.Obsolete0 IS NULL
		)
	AND v_FullCollectionMembership.CollectionID = @CollectionID
GROUP BY VRS.Netbios_Name0,
	VRS.Client0,
	VRS.Active0,
	v_GS_SYSTEM_ENCLOSURE.ChassisTypes0,
	v_RA_System_SMSAssignedSites.SMS_Assigned_Sites0,
	VRS.Client_Version0,
	Vrs.Creation_Date0,
	Vrs.AD_Site_Name0,
	v_Gs_Operating_System.InstallDate0,
	v_Gs_Operating_System.LastBootUpTime0,
	PC_BIOS_DATA.SerialNumber00,
	v_GS_SYSTEM_ENCLOSURE.SMBIOSAssetTag0,
	PC_BIOS_DATA.ReleaseDate00,
	PC_BIOS_DATA.Name00,
	PC_BIOS_DATA.SMBIOSBIOSVersion00,
	v_GS_PROCESSOR.Name0,
	Computer_System_DATA.Manufacturer00,
	Computer_System_DATA.Model00,
	Computer_System_DATA.SystemType00,
	v_GS_COMPUTER_SYSTEM.Domain0,
	Vrs.User_Domain0,
	Vrs.User_Name0,
	v_R_User.Mail0,
	v_GS_COMPUTER_SYSTEM.DomainRole0,
	Operating_System_DATA.Caption00,
	Operating_System_DATA.CSDVersion00,
	Operating_System_DATA.Version00,
	v_GS_X86_PC_MEMORY.TotalPhysicalMemory0,
	v_GS_WORKSTATION_STATUS.LastHWScan
ORDER BY VRS.Netbios_Name0

-- 174. All ConfigMgr roles status
SELECT DISTINCT (
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Site System'
		) AS 'SiteSys',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Component Server'
		) AS 'CompSer',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Site Server'
		) AS 'SiteSer',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Management Point'
		) AS 'MP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Distribution Point'
		) AS 'DP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS SQL Server'
		) AS 'SQL',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Software Update Point'
		) AS 'SUP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS SRS Reporting Point'
		) AS 'SSRS',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Reporting Point'
		) AS 'RPT',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Fallback Status Point'
		) AS 'FSP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Server Locator Point'
		) AS 'SLP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS PXE Service Point'
		) AS 'PXE',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS System Health Validator'
		) AS 'SysVal',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS State Migration Point'
		) AS 'SMP',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Notification Server'
		) AS 'NotiSer',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Provider'
		) AS 'SMSPro',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Application Web Service'
		) AS 'WebSer',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Portal Web Site'
		) AS 'WebSite',
	(
		SELECT COUNT(*)
		FROM v_SystemResourceList
		WHERE RoleName = 'SMS Branch distribution point'
		) AS 'BranDP'
FROM v_SystemResourceList

-- 175. All ConfigMgr Roles Detailed status
SELECT srl.ServerName,
	srl.SiteCode,
	vs.SiteName,
	vrs.AD_Site_Name0 AS ADSite,
	vs.ReportingSiteCode AS Parent,
	vs.Installdir,
	MAX(CASE srl.rolename
			WHEN 'SMS Site System'
				THEN 'Yes'
			ELSE ' '
			END) AS SiteSys,
	MAX(CASE srl.rolename
			WHEN 'SMS Component Server'
				THEN 'Yes'
			ELSE ' '
			END) AS CompSer,
	MAX(CASE srl.rolename
			WHEN 'SMS Site Server'
				THEN 'Yes'
			ELSE ' '
			END) AS SiteSer,
	MAX(CASE srl.rolename
			WHEN 'SMS Management Point'
				THEN 'Yes'
			ELSE ' '
			END) AS MP,
	MAX(CASE srl.rolename
			WHEN 'SMS Distribution Point'
				THEN 'Yes'
			ELSE ' '
			END) AS DP,
	MAX(CASE srl.rolename
			WHEN 'SMS SQL Server'
				THEN 'Yes'
			ELSE ' '
			END) AS 'SQL',
	MAX(CASE srl.rolename
			WHEN 'SMS Software Update Point'
				THEN 'Yes'
			ELSE ' '
			END) AS SUP,
	MAX(CASE srl.rolename
			WHEN 'SMS SRS Reporting Point'
				THEN 'Yes'
			ELSE ' '
			END) AS SSRS,
	MAX(CASE srl.RoleName
			WHEN 'SMS Reporting Point'
				THEN 'Yes'
			ELSE ' '
			END) AS RPT,
	MAX(CASE srl.rolename
			WHEN 'SMS Fallback Status Point'
				THEN 'Yes'
			ELSE ' '
			END) AS FSP,
	MAX(CASE srl.rolename
			WHEN 'SMS ServerName Locator Point'
				THEN 'Yes'
			ELSE ' '
			END) AS SLP,
	MAX(CASE srl.rolename
			WHEN 'SMS PXE Service Point'
				THEN 'Yes'
			ELSE ' '
			END) AS PXE,
	MAX(CASE srl.rolename
			WHEN 'AI Update Service Point'
				THEN 'Yes'
			ELSE ' '
			END) AS AssI,
	MAX(CASE srl.rolename
			WHEN 'SMS State Migration Point'
				THEN 'Yes'
			ELSE ' '
			END) AS SMP,
	MAX(CASE srl.rolename
			WHEN 'SMS System Health Validator'
				THEN 'Yes'
			ELSE ' '
			END) AS SysVal,
	MAX(CASE srl.rolename
			WHEN 'SMS Notification Server'
				THEN 'Yes'
			ELSE ' '
			END) AS NotiSer,
	MAX(CASE srl.rolename
			WHEN 'SMS Provider'
				THEN 'Yes'
			ELSE ' '
			END) AS SMSPro,
	MAX(CASE srl.rolename
			WHEN 'SMS Application Web Service'
				THEN 'Yes'
			ELSE ' '
			END) AS WebSer,
	MAX(CASE srl.rolename
			WHEN 'SMS Portal Web Site'
				THEN 'Yes'
			ELSE ' '
			END) AS WebSite,
	MAX(CASE srl.rolename
			WHEN 'SMS Branch distribution point'
				THEN 'Yes'
			ELSE ' '
			END) AS BranDP
FROM v_SystemResourceList AS srl
LEFT JOIN v_site vs ON srl.ServerName = vs.ServerName
LEFT JOIN v_R_System_Valid vrs ON LEFT(srl.ServerName, CHARINDEX('.', srl.ServerName) - 1) = vrs.Netbios_Name0
GROUP BY srl.ServerName,
	srl.SiteCode,
	vs.SiteName,
	vs.ReportingSiteCode,
	vrs.AD_Site_Name0,
	vs.InstallDir
ORDER BY srl.sitecode,
	srl.ServerName

-- 176. All Software applications deployments status
SELECT Vaa.AssignmentName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Vaa.ApplicationName AS 'ApplicationName',
	CASE 
		WHEN Vaa.DesiredConfigType = 1
			THEN 'Install'
		WHEN vaa.DesiredConfigType = 2
			THEN 'Uninstall'
		ELSE 'Others'
		END AS 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		WHEN Ds.DeploymentIntent = 3
			THEN 'Simulate'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_ApplicationAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 1
ORDER BY Ds.DeploymentTime DESC

-- 177. All Software packages deployments status
SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Left(Ds.SoftwareName, CharIndex('(', (Ds.SoftwareName)) - 1) AS 'ApplicationName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.ModificationTime, GetDate()) AS 'CreatedDays',
	Ds.CreationTime AS 'CreationTime',
	Ds.ModificationTime AS 'LastModifiedTime',
	'Administrator' AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 2
ORDER BY Ds.DeploymentTime DESC

-- 178. All Software updates deployments status
SELECT Vaa.AssignmentName AS 'DeploymentName',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'Others',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberSuccess = 0)
			OR (Ds.NumberSuccess IS NULL)
			THEN '0'
		ELSE (round(Ds.NumberSuccess / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.CreationTime, GetDate()) AS 'CreatedDays',
	Vaa.CreationTime AS 'CreationTime',
	Vaa.LastModificationTime AS 'LastModifiedTime',
	Vaa.LastModifiedBy AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
LEFT JOIN v_CIAssignment Vaa ON Ds.AssignmentID = Vaa.AssignmentID
WHERE Ds.FeatureType = 5
ORDER BY Ds.DeploymentTime DESC

-- 179. All Operating systems deployments status
SELECT Vaa.AdvertisementName AS 'DeploymentName',
	Right(Ds.CollectionName, 3) AS 'Stage',
	Ds.SoftwareName AS 'TaskSequenceName',
	Ds.ProgramName 'DepType',
	Ds.CollectionName AS 'CollectionName',
	CASE 
		WHEN Ds.DeploymentIntent = 1
			THEN 'Required'
		WHEN Ds.DeploymentIntent = 2
			THEN 'Available'
		END AS 'Purpose',
	Ds.DeploymentTime AS 'AvailableTime',
	Ds.EnforcementDeadline AS 'RequiredTime',
	Ds.NumberTotal AS 'Target',
	Ds.NumberSuccess AS 'Success',
	Ds.NumberInProgress AS 'Progress',
	Ds.NumberErrors AS 'Errors',
	Ds.NumberOther AS 'ReqNotMet',
	Ds.NumberUnknown AS 'Unknown',
	CASE 
		WHEN (Ds.NumberTotal = 0)
			OR (Ds.NumberTotal IS NULL)
			THEN '100'
		ELSE (round((Ds.NumberSuccess + Ds.NumberOther) / convert(FLOAT, Ds.NumberTotal) * 100, 2))
		END AS 'Success%',
	DateDiff(D, Ds.DeploymentTime, GetDate()) AS 'AvailableDays',
	DateDiff(D, Ds.EnforcementDeadline, GetDate()) AS 'RequiredDays',
	DateDiff(D, Ds.ModificationTime, GetDate()) AS 'CreatedDays',
	Ds.CreationTime AS 'CreationTime',
	Ds.ModificationTime AS 'LastModifiedTime',
	'Administrator' AS 'LastModifiedBy'
FROM v_DeploymentSummary Ds
JOIN v_Advertisement Vaa ON Ds.OfferID = Vaa.AdvertisementID
WHERE Ds.FeatureType = 7
ORDER BY Ds.DeploymentTime DESC