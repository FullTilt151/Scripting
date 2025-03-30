SELECT  [ID]
,[DatabaseName]
,[SchemaName]
,[ObjectName]
,[ObjectType]
,[IndexName]
,[IndexType]
,[StatisticsName]
,[PartitionNumber]
,[ExtendedInfo]
,[Command]
,[CommandType]
,[StartTime]
,[EndTime]
,DATEDIFF(n, [StartTime],[EndTime]) AS DateDiff
,[ErrorNumber]
,[ErrorMessage]
FROM [CMMonitor].[dbo].[CommandLog]
WHERE  StartTime > '2021-08-02 00:00' --DATEADD(dd,-1,GETDATE()) --will show only the last two days.  
--and DatabaseName = 'CM_WP1' 
--and CommandType = 'UPDATE_STATISTICS' and
ORDER BY ID DESC 
-- ORDER BY DateDiff