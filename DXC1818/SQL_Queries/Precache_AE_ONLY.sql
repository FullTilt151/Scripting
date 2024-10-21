-- List precached info for collection 
SELECT ContentName As Pacakge, Size, Version, [Percent], HostName
--HostName, PackageID, PKG.NAME, SourceVersion, c.Version, [Percent]
FROM   [ActiveEfficiency].[dbo].[contents] c 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd 
	   ON cd.ContentId = c.id 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[devices] d 
	   ON d.Id = cd.DeviceId 
--WHERE HostName = 'WKR90VW1XF'
WHERE ContentName IN ('WP100481','WP1005C7','WP100417')
AND EndTime LIKE '%2020%'
--AND ContentName LIKE 'WP100481'
ORDER BY HostName


-- List precached info for collection 
SELECT TOP 1 Version,
ContentName As Pacakge, Size, [Percent], EndTime, HostName
--SELECT ContentName As Pacakge, Size, Version, [Percent], HostName
--HostName, PackageID, PKG.NAME, SourceVersion, c.Version, [Percent]
FROM   [ActiveEfficiency].[dbo].[contents] c 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd 
	   ON cd.ContentId = c.id 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[devices] d 
	   ON d.Id = cd.DeviceId 
WHERE HostName = 'WKR90VW1XF'
AND ContentName LIKE'WP100481'

SELECT TOP 1 Version,
ContentName As Pacakge, Size, [Percent], EndTime, HostName
--SELECT ContentName As Pacakge, Size, Version, [Percent], HostName
--HostName, PackageID, PKG.NAME, SourceVersion, c.Version, [Percent]
FROM   [ActiveEfficiency].[dbo].[contents] c 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd 
	   ON cd.ContentId = c.id 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[devices] d 
	   ON d.Id = cd.DeviceId 
WHERE HostName = 'WKR90VW1XF'
AND ContentName LIKE'WP1005C7'

SELECT TOP 1 Version,
ContentName As Pacakge, Size, [Percent], EndTime, HostName
--SELECT ContentName As Pacakge, Size, Version, [Percent], HostName
--HostName, PackageID, PKG.NAME, SourceVersion, c.Version, [Percent]
FROM   [ActiveEfficiency].[dbo].[contents] c 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[contentdeliveries] cd 
	   ON cd.ContentId = c.id 
	   LEFT OUTER JOIN [ActiveEfficiency].[dbo].[devices] d 
	   ON d.Id = cd.DeviceId 
WHERE HostName = 'WKR90VW1XF'
AND ContentName LIKE'WP100417'