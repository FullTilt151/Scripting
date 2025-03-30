SELECT c.ContentName,
	c.Version AS SourceVersion,
	c.Id,
	c.[Size],
	d.hostname,
	cd.[Percent],
	cd.EndTime
FROM [ActiveEfficiency].[dbo].[Contents] c
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[ContentDeliveries] cd ON cd.contentid = c.id
LEFT OUTER JOIN [ActiveEfficiency].[dbo].[Devices] d ON d.id = cd.deviceid
WHERE ContentName = 'WP10048C' --and d.HostName = 'louappwps1653'
ORDER BY c.ContentName,
	c.Version
