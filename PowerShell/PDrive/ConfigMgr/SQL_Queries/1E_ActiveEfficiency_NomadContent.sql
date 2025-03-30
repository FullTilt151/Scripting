-- Count content for a machine
SELECT count(*)
FROM ContentDeliveries
WHERE DeviceId IN (
		SELECT id
		FROM [dbo].[Devices]
		WHERE hostname = 'LENPXEWPW01'
		)

-- List content for a machine
SELECT d.Hostname,
	c.contentname AS PKG_ID,
	PKG.manufacturer + ' ' + PKG.NAME + ' ' + PKG.version [Package_Name],
	c.Version,
	c.Id,
	c.[Size],
	cd.[Percent],
	cd.Endtime,
	c.HASH
--Need to get expected hash from DP
FROM [ActiveEfficiency].[dbo].[contents] c
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd ON cd.contentid = c.id
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[devices] d ON d.id = cd.deviceid
JOIN [ConfigMGRLink].[CM_WP1].[DBO].v_package PKG ON C.contentname COLLATE database_default = PKG.packageid COLLATE database_default
WHERE hostname IN ('WKMPMP06UYXT')
--and c.ContentName = 'WP1004E7'
ORDER BY c.contentname,
	c.version

--ORDER BY cd.EndTime 
--ORDER BY Size
--List of WKIDs and Precache details
SELECT DISTINCT d.Hostname,
	c.contentname AS PKG_ID,
	c.Version,
	c.Id,
	c.[Size],
	cd.[Percent],
	c.HASH
FROM [ActiveEfficiency].[dbo].[contents] c
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd ON cd.contentid = c.id
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[devices] d ON d.id = cd.deviceid
JOIN [ConfigMGRLink].[CM_WP1].[DBO].v_cm_res_coll_WP103AE4 COLL ON d.hostname COLLATE database_default = COll.Name COLLATE database_default
WHERE c.contentname = 'WP10033F'
	AND cd.[Percent] = 100
	AND c.version = 3

--Count of WKID's and Precahe details
SELECT c.contentname AS PKG_ID,
	c.Version,
	cd.[Percent],
	count(DISTINCT d.hostname)
FROM [ActiveEfficiency].[dbo].[contents] c
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd ON cd.contentid = c.id
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[devices] d ON d.id = cd.deviceid
JOIN [ConfigMGRLink].[CM_WP1].[DBO].v_cm_res_coll_WP103AE4 COLL ON d.hostname COLLATE database_default = COll.Name COLLATE database_default
WHERE c.contentname = 'WP10033F'
	AND cd.[Percent] = 100
	AND c.Version = 3
GROUP BY c.contentname,
	c.Version,
	cd.[Percent]

-- List of WKIDs with role and model
SELECT d.Hostname,
	sys.build01,
	c.contentname AS PKG_ID,
	PKG.manufacturer + ' ' + PKG.NAME + ' ' + PKG.version [Package_Name],
	c.Version,
	c.Id,
	c.[Size],
	cd.[Percent],
	cd.Endtime,
	c.HASH,
	(
		SELECT smstsrole0
		FROM [ConfigMgrLink].[CM_WP1].[DBO].v_gs_osd640 osd
		WHERE osd.resourceid = sys.resourceid
		) [Role]
--Need to get expected hash from DP
FROM [ActiveEfficiency].[dbo].[contents] c
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd ON cd.contentid = c.id
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[devices] d ON d.id = cd.deviceid
JOIN [ConfigMGRLink].[CM_WP1].[DBO].v_package PKG ON C.contentname COLLATE database_default = PKG.packageid COLLATE database_default
LEFT JOIN [ConfigMGRLink].[CM_WP1].[DBO].v_r_system sys ON d.HostName COLLATE database_default = sys.netbios_name0 COLLATE database_default
WHERE sys.build01 = '10.0.14393'
	AND c.ContentName IN ('WP10033F') --,'WP10033B','WP100067','WP100062','WP1002B4')
ORDER BY c.contentname,
	c.version
