-- Missing precache packages
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
where (tspkg.PackageID in (@DeploymentTS)) and
		refpkg.PackageID not in (
			select RefPackageID from dbo.v_TaskSequencePackageReferences TPR 
			where TPR.PackageID = @PrecacheTS)
order by [Package Type],[Package Name],[Task Sequence]

-- Precache Task sequences
select PackageID, Name
from v_TaskSequencePackage
where Name like '1E OSD Master - Pre-Cache%' or Name = 'Windows 10 - ZTI - Wipe and Load - PRECACHE'
order by Name

-- Deployment Task sequences
select PackageID, Name
from v_TaskSequencePackage
where Name like '%Windows%' and Name not like '%B&C%' and Name not like '%Offline%'
order by Name