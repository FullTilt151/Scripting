-- Check last table statistics by date
SELECT
CONVERT(varchar(25), STATS_DATE(s.[object_id], s.stats_id), 101) AS StatisticsLastUpdated,
COUNT(*) As Total
FROM sys.stats s 
JOIN sys.stats_columns sc ON sc.[object_id] = s.[object_id] AND sc.stats_id = s.stats_id
WHERE OBJECTPROPERTY(s.OBJECT_ID,'IsUserTable') = 1
AND (s.auto_created = 1 OR s.user_created = 1)
GROUP BY CONVERT(varchar(25), STATS_DATE(s.[object_id], s.stats_id), 101)
ORDER BY 1 DESC; 

-- Run statistics
/*
exec sp_msforeachtable 'update statistics ? with fullscan'
*/

-- Table fragmentation percentages
SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName, 
ind.name AS IndexName, indexstats.index_type_desc AS IndexType, 
indexstats.avg_fragmentation_in_percent 
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
INNER JOIN sys.indexes ind  
ON ind.object_id = indexstats.object_id 
AND ind.index_id = indexstats.index_id 
WHERE indexstats.avg_fragmentation_in_percent > 30 
ORDER BY indexstats.avg_fragmentation_in_percent DESC

-- Rebuild indexes
/*
Exec sp_MSForEachtable 'DBCC DBREINDEX (''?'')'
*/