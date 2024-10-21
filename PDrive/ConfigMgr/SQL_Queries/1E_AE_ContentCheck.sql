--Check AE content for specific machine and content ID
select 
--Pkg.PackageID,
--Pkg.Name as PkgName,
--Pkg.Version as PkgVersionText,
--Pkg.Language,
--Pkg.Manufacturer,
c.ContentName, c.Version AS SourceVersion, c.Id, c.[Size], d.hostname,cd.[Percent]
,cd.EndTime
from [ActiveEfficiency].[dbo].[Contents] c
left outer join [ActiveEfficiency].[dbo].[ContentDeliveries] cd on cd.contentid = c.id
left outer join [ActiveEfficiency].[dbo].[Devices] d on d.id = cd.deviceid
--LEFT OUTER JOIN v_Content VC ON ( c.ContentName COLLATE DATABASE_DEFAULT = VC.Content_UniqueID OR (c.ContentName + '.' + c.Version ) COLLATE DATABASE_DEFAULT = VC.Content_UniqueID )
--LEFT OUTER JOIN v_Package Pkg ON VC.PkgId = Pkg.PackageID
WHERE HostName = 'DSIPXEWPW18'
--AND ContentName = 'WP10045A'
ORDER BY cd.[Percent]


select 
c.ContentName, c.Version AS SourceVersion, c.Id, c.[Size], d.hostname,cd.[Percent]
,cd.EndTime
from [ActiveEfficiency].[dbo].[Contents] c
left outer join [ActiveEfficiency].[dbo].[ContentDeliveries] cd on cd.contentid = c.id
left outer join [ActiveEfficiency].[dbo].[Devices] d on d.id = cd.deviceid
WHERE c.Version = 74
AND ContentName = 'WP10045A'
ORDER BY c.ContentName, c.Version