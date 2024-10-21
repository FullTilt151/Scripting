--
SELECT
  ImmediateSourceCollectionID,
  DependentCollectionID
FROM vCollectionDependencyChain
WHERE SourceCollectionID = N'SMS00001'
ORDER BY [Level] ASC

exec sp_GetCollectionsMarkedForEvaluation 


SELECT
  SourceCOllectionID,
  COUNT(*) AS TotalNumberOfDependents
FROM vCollectionDependencyChain
GROUP BY SourceCollectionID
ORDER BY TotalNumberOfDependents DESC


select * from V_collection where RefreshType = 4 OR RefreshType = 6


SELECT
  *
FROM V_collection
WHERE RefreshType IN (4, 6)
AND CollectionID IN
('WP101AEA', 'WP10352D', 'WP100017', 'WP100018', 'WP103FE7', 'WP100019', 'WP10001A', 'WP10001B', 'WP10022C')

SELECT
  *
FROM Collection_Rules_SQL a
INNER JOIN collections b
  ON a.CollectionID = b.CollectionID
WHERE b.SiteID IN
('WP101AEA', 'WP10352D', 'WP100017', 'WP100018', 'WP103FE7', 'WP100019', 'WP10001A', 'WP10001B', 'WP10022C')


SELECT
  dbschemas.[name] AS 'Schema',
  dbtables.[name] AS 'Table',
  dbindexes.[name] AS 'Index',
  indexstats.avg_fragmentation_in_percent,
  indexstats.page_count
FROM sys.DM_DB_INDEX_PHYSICAL_STATS(DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables
  ON dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas
  ON dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes
  ON dbindexes.[object_id] = indexstats.[object_id]
  AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
ORDER BY indexstats.avg_fragmentation_in_percent DESC

/*
Rebuild all the indexes in a database:Exec sp_MSForEachtable DBCC DBREINDEX (''?'')go Updates statistics for all the tables within the database:Exec sp_MSForEachTable "UPDATE STATISTICS ? with fullscan"goDBCC DBREINDEX ('WorkstationStatus_DATA','',80)update statistics WorkstationStatus_DATA with fullscanExec sp_MSForEachtable 'DBCC DBREINDEX (''?'')' Exec sp_MSForEachTable "UPDATE STATISTICS ? with fullscan"*/