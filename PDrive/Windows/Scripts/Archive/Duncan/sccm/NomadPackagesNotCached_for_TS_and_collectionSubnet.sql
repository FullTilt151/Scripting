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
order by RefPkg.PackageType, [PackageName];


--Temporary table object for collection members and their subnets
DECLARE @SubnetsTable TABLE
(
	[MachineName] nvarchar(255),
	[Subnet] nvarchar(446)
)

INSERT INTO @SubnetsTable
select members.[Name] as [MachineName], subnets.IP_Subnets0 as [Subnet]
from v_FullCollectionMembership_Valid members
inner join v_RA_System_IPSubnets subnets
on members.resourceid = subnets.resourceid
where CollectionID = @CollectionID;

--Temporary table object for Nomad cached package information for the collection members and the TS packages
DECLARE @CollectionMemberCacheTable TABLE
(
	[MachineName] nvarchar(255),
	[PackageID] nvarchar(8) null,
	[Percent] float(3),
	[CachedVersion] int
)

--Temporary table object for Nomad cached package information for the member subnets and the TS packages
DECLARE @SubnetCacheTable TABLE
(
	[Subnet] nvarchar(446),
	[PackageID] nvarchar(8) null,
	[MaxCachedVersion] int,
	[MaxCachedVersionPercent] float(3)
)


DECLARE @ResourceID int;
DECLARE @Name nvarchar(255);
DECLARE @PackageID nvarchar(8);

DECLARE member_cursor CURSOR READ_ONLY FOR
SELECT DISTINCT ResourceID, [Name]
FROM v_FullCollectionMembership_valid
WHERE CollectionID = @CollectionID;

--Loop through each member in collection
OPEN member_cursor;
FETCH NEXT FROM member_cursor INTO @ResourceID, @Name;
WHILE @@FETCH_STATUS = 0 --Outer Cursor loop
	BEGIN
		DECLARE pkg_cursor CURSOR READ_ONLY FOR
		SELECT DISTINCT PackageID from @TSPackageTable;
		--For each member in collection, get Nomad cache information for each package in the task sequence (if exists, else will be NULL)
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
			[CachedVersion] = CAST(ISNULL((SELECT Version0 FROM v_GS__E_NomadPackages0 WHERE PackageID0 = @PackageID and ResourceID = @ResourceID), 0) AS int)
			FETCH NEXT FROM pkg_cursor INTO @PackageID;
		END
		CLOSE pkg_cursor;
		DEALLOCATE pkg_cursor;
		FETCH NEXT FROM member_cursor INTO @ResourceID, @Name;
	END
CLOSE member_cursor;
DEALLOCATE member_cursor;

DECLARE @MachineName nvarchar(255);
DECLARE @Subnet nvarchar(446);
DECLARE @MaxCachedVersion int;
DECLARE @MaxCachedVersionPercent float(3);

DECLARE subnet_cursor CURSOR READ_ONLY FOR
SELECT DISTINCT Subnet
FROM @SubnetsTable;

--Loop through each subnet, get the max cache version
OPEN subnet_cursor;
FETCH NEXT FROM subnet_cursor INTO @Subnet;
WHILE @@FETCH_STATUS = 0 --outer loop
	BEGIN
		DECLARE pkg_cursor CURSOR READ_ONLY FOR
		SELECT DISTINCT PackageID from @TSPackageTable;
		--For each subnet, get the MAX cached version for each package (if exists, else will be NULL)
		OPEN pkg_cursor;
		FETCH NEXT FROM pkg_cursor INTO @PackageID;
		WHILE @@FETCH_STATUS = 0 --Inner Cursor loop
		BEGIN
			SET @MaxCachedVersion = (SELECT MAX(CachedVersion) FROM @CollectionMemberCacheTable WHERE PackageID = @PackageID and CachedVersion is not null and MachineName IN (SELECT MachineName FROM @SubnetsTable WHERE Subnet = @Subnet))
			SET @MaxCachedVersionPercent = (SELECT MAX([Percent]) FROM @CollectionMemberCacheTable WHERE PackageID = @PackageID and CachedVersion = @MaxCachedVersion and CachedVersion IS NOT NULL and MachineName IN (SELECT MachineName FROM @SubnetsTable WHERE Subnet = @Subnet))
			--insert records into @SubnetCacheTable
			INSERT INTO @SubnetCacheTable
			SELECT
			@Subnet as [Subnet],
			@PackageID AS [PackageID],
			@MaxCachedVersion AS [MaxCachedVersion],
			@MaxCachedVersionPercent AS [MaxCachedVersionPercent];
			FETCH NEXT FROM pkg_cursor INTO @PackageID;
			
		END
		CLOSE pkg_cursor;
		DEALLOCATE pkg_cursor;
		
		FETCH NEXT FROM subnet_cursor INTO @Subnet;
	END
CLOSE subnet_cursor;
DEALLOCATE subnet_cursor;

SET NOCOUNT OFF;

SELECT DISTINCT
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
INNER JOIN @SubnetsTable Subnet
on Subnet.MachineName = Nomad.MachineName
INNER JOIN @SubnetCacheTable SubnetCache
on SubnetCache.PackageID = Pkg.PackageID and SubnetCache.Subnet = Subnet.Subnet
Where 
(
	(
		--Not on subnet at all (in the collection)
		SubnetCache.[MaxCachedVersion] = 0
	)
	OR
	(
		--Max cached version on the subnet is not correct
		Pkg.[SourceVersion] != SubnetCache.[MaxCachedVersion] 
	)
	OR
	(
		--Max cached version on the subnet is correct but not at 100%
		Pkg.[SourceVersion] = SubnetCache.[MaxCachedVersion]
		AND
		(
			SubnetCache.[MaxCachedVersionPercent] != 100
		)
	)
)
ORDER BY [MachineName], [PackageName];
