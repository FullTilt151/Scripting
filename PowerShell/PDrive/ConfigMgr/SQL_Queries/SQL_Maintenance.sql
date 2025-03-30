-- Check index fragmentation for indexes with page count > 1500
SELECT DB_NAME(database_id) AS [Database Name], OBJECT_NAME(ps.OBJECT_ID) AS [Object Name], i.name AS [Index Name], ps.index_id, index_type_desc, avg_fragmentation_in_percent, fragment_count, page_count 
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL ,N'LIMITED') AS ps 
    INNER JOIN sys.indexes AS i WITH (NOLOCK) ON ps.[object_id] = i.[object_id] AND ps.index_id = i.index_id 
WHERE database_id = DB_ID() AND page_count > 1500 
ORDER BY avg_fragmentation_in_percent DESC OPTION (RECOMPILE);

-- Re-index on all tables
--EXEC sp_MSforeachtable 'DBCC DBREINDEX (''?'')'

-- Check stats
SELECT CONVERT(varchar(25), STATS_DATE(s.[object_id], s.stats_id), 101) AS StatisticsLastUpdated, COUNT(*) As Total
FROM sys.stats s 
JOIN sys.stats_columns sc ON sc.[object_id] = s.[object_id] AND sc.stats_id = s.stats_id
WHERE OBJECTPROPERTY(s.OBJECT_ID,'IsUserTable') = 1 AND (s.auto_created = 1 OR s.user_created = 1)
GROUP BY CONVERT(varchar(25), STATS_DATE(s.[object_id], s.stats_id), 101)
ORDER BY YEAR(CONVERT(varchar(25), STATS_DATE(s.[object_id], s.stats_id), 101)) desc, MONTH(CONVERT(varchar(25), STATS_DATE(s.[object_id], s.stats_id), 101)) desc, DAY(CONVERT(varchar(25), STATS_DATE(s.[object_id], s.stats_id), 101)) desc

-- Update stats on all tables
-- EXEC sp_MSForEachTable 'UPDATE STATISTICS ? with fullscan'