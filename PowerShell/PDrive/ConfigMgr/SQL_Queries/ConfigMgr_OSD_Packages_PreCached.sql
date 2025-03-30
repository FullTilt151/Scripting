select TSPkg.Name [Task Sequence], TS.PackageID [Task Sequence ID],RefPkg.Manufacturer + ' ' + RefPkg.Name + ' ' + RefPkg.Version [Package Name], TS.RefPackageID [Package ID],
		CASE RefPkg.PackageType
			WHEN '0' THEN 'Package'
			WHEN '3' THEN 'Driver Package'
			WHEN '4' THEN 'Task Sequence'
			WHEN '5' THEN 'Software Update'
			WHEN '8' THEN 'Application'
			WHEN '258' THEN 'Boot Image'
			WHEN '257' THEN 'OS Image'
		END as [Package Type]
from dbo.v_TaskSequencePackageReferences TS inner join
	 dbo.v_Package RefPkg on TS.RefPackageID = RefPkg.PackageID inner join
	 dbo.v_Package TSPkg on TS.PackageID = TSPkg.PackageID
where TS.PackageID = 'CAS00083' or TS.PackageID = 'CAS0086D'
order by RefPkg.PackageType,[Package Name]