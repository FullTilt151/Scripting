SELECT      v_GS_SYSTEM.Name0 WKID,PackageID, 
			CASE PackageType
				WHEN '0' THEN 'Package'
				WHEN '3' THEN 'Driver Package'
				WHEN '4' THEN 'Task Sequence'
				WHEN '5' THEN 'Software Update'
				WHEN '8' THEN 'Application'
				WHEN '258' THEN 'Boot Image'
				WHEN '257' THEN 'OS Image'
			END as [Package Type],
			Manufacturer, Name PackageName, Version, Description, CAST((CAST(DiskUsageKB0 as bigint)/1048) as decimal(9,2)) as [Size in MB], 
			SourceVersion, Version0 as [Cached Version], Percent0 as [Percent Cached],  
			CASE 
				WHEN Nomad.Version0 = v_package.SourceVersion then 'X'
				ELSE ' '
			END AS [Cached?],
			ReturnStatus0 Status, OptInfo0 as [Optional Info], StartTimeUTC0 as [Start Time],
			LastRefreshTime as [Last Update], CachePriority0 as [Cache Priority], WorkRate0
FROM        v_GS__E_NomadPackages0 Nomad inner join 
			v_Package on Nomad.PackageID0 = dbo.v_package.PackageID INNER JOIN v_GS_SYSTEM ON Nomad.ResourceID = v_GS_SYSTEM.ResourceID
where Name0 = 'citpxewpw01'
order by [Package Type],PackageName