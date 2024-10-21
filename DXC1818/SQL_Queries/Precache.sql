-- List precached info for collection 
SELECT HostName, PackageID, PKG.NAME, SourceVersion, c.Version, [Percent]
FROM   [ActiveEfficiency].[dbo].[contents] c 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd 
	   ON cd.ContentId = c.id 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[devices] d 
	   ON d.Id = cd.DeviceId 
	   JOIN [ConfigMGRLink].[CM_WP1].[DBO].v_Package PKG 
	   ON C.ContentName COLLATE database_default = PKG.packageid COLLATE database_default
	   JOIN [ConfigMGRLink].[CM_WP1].[DBO].v_CM_RES_COLL_WP1063BF COLL 
	   ON d.HostName COLLATE database_default = COll.Name COLLATE database_default 
WHERE [Percent] = '100'
AND EndTime LIKE '%2020%' 
AND PKG.NAME LIKE ('Drivers - %')
OR PackageID IN ('WP100481','WP1005C7','WP100417')
ORDER  BY HostName