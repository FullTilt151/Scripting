SELECT   distinct     RefPkg.Manufacturer + ' ' + RefPkg.Name + ' ' + RefPkg.Version AS [Package Name], 
                         TS.RefPackageID AS [Package ID], 
                         CASE RefPkg.PackageType WHEN '0' THEN 'Package' WHEN '3' THEN 'Driver Package' WHEN '4' THEN 'Task Sequence' WHEN '5' THEN 'Software Update' WHEN '8'
                          THEN 'Application' WHEN '258' THEN 'Boot Image' WHEN '257' THEN 'OS Image' END AS [Package Type], RefPkg.SourceVersion [Version], 
						  CAST((CAST(v_PackageStatusRootSummarizer.SourceSize as bigint)/1048) as decimal(9,0)) as [Size in MB]
FROM            dbo.v_TaskSequencePackageReferences AS TS INNER JOIN
                         dbo.v_Package AS RefPkg ON TS.RefPackageID = RefPkg.PackageID INNER JOIN
                         dbo.v_Package AS TSPkg ON TS.PackageID = TSPkg.PackageID INNER JOIN
						 dbo.v_GS__E_NomadPackages0 AS Nomad ON RefPkg.PackageID = Nomad.PackageID0 INNER JOIN
						 dbo.v_packagestatusrootsummarizer ON RefPkg.PackageID = v_PackageStatusRootSummarizer.PackageID
WHERE        (TSPkg.Name = '1E ZTI Win7x64E-OSDDeploy-Master-Rel3-0830-Image') AND 
			 (RefPkg.PackageID NOT IN (
							SELECT  distinct      dbo.v_Package.PackageID
							FROM            dbo.v_GS__E_NomadPackages0 AS Nomad INNER JOIN
							 dbo.v_Package ON Nomad.PackageID0 = dbo.v_Package.PackageID INNER JOIN
							 dbo.v_GS_SYSTEM ON Nomad.ResourceID = v_GS_SYSTEM.ResourceID INNER JOIN
							 dbo.v_gs_network_adapter_configuration ON v_GS_SYSTEM.ResourceID = v_GS_NETWORK_ADAPTER_CONFIGURATION.ResourceID
							 WHERE        (v_GS_NETWORK_ADAPTER_CONFIGURATION.IPAddress0 like '193.42.55.%') and Nomad.Version0 = v_package.SourceVersion))
order by [Package Type],[Package Name]
