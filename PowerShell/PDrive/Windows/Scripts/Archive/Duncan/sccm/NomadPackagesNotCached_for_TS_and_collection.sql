DECLARE @TaskSequenceID nvarchar(8)
DECLARE @CollectionID nvarchar(8)

SET @TaskSequenceID = 'TST00083'
SET @CollectionID = 'TST0004B'

--Temporary table object for package information
DECLARE @TSPackageTable TABLE
(
	[PackageID] nvarchar(8),
	[PackageName] nvarchar(386),
	[SourceVersion] int,
	[PackageType] nvarchar(15)
)

--Retrieve Package Information from Task Sequence
SET NOCOUNT ON;
INSERT INTO @TSPackageTable
SELECT
TS.RefPackageID AS [PackageID],
RefPkg.Manufacturer + ' ' + RefPkg.Name + ' ' + RefPkg.Version AS [PackageName],
RefPkg.SourceVersion AS [SourceVersion],
		CASE RefPkg.PackageType
			WHEN '0' THEN 'Package'
			WHEN '3' THEN 'Driver Package'
			WHEN '4' THEN 'Task Sequence'
			WHEN '5' THEN 'Software Update'
			WHEN '8' THEN 'Application'
			WHEN '258' THEN 'Boot Image'
			WHEN '257' THEN 'OS Image'
		END as [PackageType]

from dbo.v_TaskSequencePackageReferences TS 
	inner join dbo.v_Package RefPkg 
	on TS.RefPackageID = RefPkg.PackageID  
	inner join dbo.v_Package TSPkg 
	on TS.PackageID = TSPkg.PackageID 
where TS.PackageID = @TaskSequenceID
order by RefPkg.PackageType, [PackageName]

--Temporary table object for Nomad cached package information for the collection members and the TS packages
DECLARE @CollectionMemberCacheTable TABLE
(
	[MachineName] nvarchar(255),
	[PackageID] nvarchar(8) null,
	[Percent] float(3),
	[CachedVersion] int
)

DECLARE @ResourceID int;
DECLARE @Name nvarchar(255);
DECLARE @PackageID nvarchar(8);

DECLARE member_cursor CURSOR READ_ONLY FOR
SELECT ResourceID, [Name]
FROM v_FullCollectionMembership
WHERE CollectionID = @CollectionID;

--Loop through each member in collection
OPEN member_cursor;
FETCH NEXT FROM member_cursor INTO @ResourceID, @Name;
WHILE @@FETCH_STATUS = 0 --Outer Cursor loop
	BEGIN
		DECLARE pkg_cursor CURSOR READ_ONLY FOR
		SELECT PackageID from @TSPackageTable;
		--For each member in collection, get Nomad cache information for each package in the task sequence
		OPEN pkg_cursor;
		FETCH NEXT FROM pkg_cursor INTO @PackageID;
		WHILE @@FETCH_STATUS = 0 --Inner Cursor loop
		BEGIN
			--insert records into @CollectionMemberCacheTable
			INSERT INTO @CollectionMemberCacheTable
			SELECT
			@NAME as [MachineName],
			@PackageID AS [PackageID],
			[Percent] = CAST(ISNULL((SELECT Percent0 FROM v_GS__E_NomadPackages0 WHERE PackageID0 = @PackageID and ResourceID = @ResourceID), 0) as float(3)), 
			[CachedVersion] = CAST(ISNULL((SELECT Version0 FROM v_GS__E_NomadPackages0 WHERE PackageID0 = @PackageID and ResourceID = @ResourceID), 0) as int);
			FETCH NEXT FROM pkg_cursor INTO @PackageID;
		END
		CLOSE pkg_cursor;
		DEALLOCATE pkg_cursor;
		FETCH NEXT FROM member_cursor INTO @ResourceID, @Name;
	END
CLOSE member_cursor;
DEALLOCATE member_cursor;

SET NOCOUNT OFF;

SELECT 
Nomad.[MachineName],
pkg.[PackageID],
Pkg.[PackageName],
Pkg.[PackageType],
Pkg.[SourceVersion],
Nomad.[CachedVersion],
Nomad.[Percent]
from @TSPackageTable Pkg 
INNER JOIN @CollectionMemberCacheTable Nomad
on Pkg.PackageID = Nomad.PackageID
Where 
Pkg.[SourceVersion] != Nomad.[CachedVersion]
OR Nomad.[Percent] != 100
ORDER BY [MachineName], [PackageName]
