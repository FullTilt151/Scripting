Select count(*) [Count]
from CollectionNotifications

SELECT tablename,
	count(*) [Count]
FROM CollectionNotifications
GROUP BY tableName
ORDER BY count(*) DESC

SELECT Count(*) [Count],
	CASE CurrentStatus
		WHEN 0
			THEN 'None'
		WHEN 1
			THEN 'Ready'
		WHEN 2
			THEN 'Refreshing'
		WHEN 3
			THEN 'Saving'
		WHEN 4
			THEN 'Evaluating'
		WHEN 5
			THEN 'Awaiting Refresh'
		WHEN 6
			THEN 'Deleting'
		WHEN 7
			THEN 'Appending Member'
		WHEN 8
			THEN 'Querying'
		END AS CurrentSTATUS
FROM V_collection
GROUP BY CurrentStatus

SELECT CollectionID,
	Name,
	Comment,
	LastChangeTime,
	EvaluationStartTime,
	LastRefreshTime,
	RefreshType,
	CollectionType,
	CASE CurrentStatus
		WHEN 0
			THEN 'None'
		WHEN 1
			THEN 'Ready'
		WHEN 2
			THEN 'Refreshing'
		WHEN 3
			THEN 'Saving'
		WHEN 4
			THEN 'Evaluating'
		WHEN 5
			THEN 'Awaiting Refresh'
		WHEN 6
			THEN 'Deleting'
		WHEN 7
			THEN 'Appending Member'
		WHEN 8
			THEN 'Querying'
		END AS CurrentSTATUS,
	MemberCount,
	MemberClassName,
	LastMemberChangeTime
FROM v_collection
WHERE CurrentStatus != 1
-- ORDER BY CurrentStatus
ORDER BY EvaluationStartTime
-- ORDER BY LastRefreshTime

SELECT *
FROM v_collection
WHERE CurrentStatus = 5

SELECT Count(*) [Count],
	CASE RefreshType
		WHEN 1
			THEN 'Manual'
		WHEN 2
			THEN 'Periodic'
		WHEN 4
			THEN 'Incremental'
		WHEN 6
			THEN 'Incremental and Periodic'
		END AS RefreshType
FROM v_Collections
GROUP BY RefreshType

-- Find the number of dependent collections for limting collections
SELECT SourceCOllectionID,
	count(*) AS TotalNumberOfDependents
FROM vCollectionDependencyChain
GROUP BY SourceCollectionID
ORDER BY TotalNumberOfDependents DESC

-- Check for specific collections not in ready status
SELECT *
FROM V_collection
WHERE RefreshType IN (4, 6)
	AND CollectionID IN ('WP101AEA', 'WP10352D', 'WP100017', 'WP100018', 'WP103FE7', 'WP100019', 'WP10001A', 'WP10001B', 'WP10022C')

-- Show rules for specific collections
SELECT *
FROM Collection_Rules_SQL a
INNER JOIN collections b ON a.CollectionID = b.CollectionID
WHERE b.SiteID IN ('WP101AEA', 'WP10352D', 'WP100017', 'WP100018', 'WP103FE7', 'WP100019', 'WP10001A', 'WP10001B', 'WP10022C')

-- Check fragmentation. Use @Threshold to set minimum acceptable level
DECLARE @Threshold FLOAT

SET @Threshold = 30

SELECT dbschemas.[name] AS 'Schema',
	dbtables.[name] AS 'Table',
	dbindexes.[name] AS 'Index',
	indexstats.avg_fragmentation_in_percent,
	indexstats.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables ON dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas ON dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
	AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
	AND indexstats.avg_fragmentation_in_percent >= @Threshold
ORDER BY indexstats.avg_fragmentation_in_percent DESC

-- Commands to fix fragmentation
-- EXEC sp_MSForEachtable 'DBCC DBREINDEX (''?'','''',80)'
-- GO

-- EXEC sp_MSForEachTable "UPDATE STATISTICS ? with fullscan"
-- GO

-- Show what's blocking
SELECT s.session_id,
	r.STATUS,
	r.blocking_session_id 'blocked by',
	r.wait_type,
	wait_resource,
	r.wait_time / (1000.0) 'Wait Time (in Sec)',
	r.cpu_time,
	r.logical_reads,
	r.reads,
	r.writes,
	r.total_elapsed_time / (1000.0) 'Elapsed Time (in Sec)',
	Substring(st.TEXT, (r.statement_start_offset / 2) + 1, (
			(
				CASE r.statement_end_offset
					WHEN - 1
						THEN Datalength(st.TEXT)
					ELSE r.statement_end_offset
					END - r.statement_start_offset
				) / 2
			) + 1) AS statement_text,
	Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' + Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text,
	r.command,
	s.login_name,
	s.host_name,
	s.program_name,
	s.host_process_id,
	s.last_request_end_time,
	s.login_time,
	r.open_transaction_count
FROM sys.dm_exec_sessions AS s
INNER JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE r.session_id != @@SPID
--and r.session_id = 
ORDER BY r.cpu_time DESC,
	r.STATUS,
	r.blocking_session_id,
	s.session_id

--Run against TempDB
USE TempDB
GO

/* SELECT name AS FileName,
	size * 1.0 / 128 AS FileSizeinMB,
	CASE max_size
		WHEN 0
			THEN 'Autogrowth is off.'
		WHEN - 1
			THEN 'Autogrowth is on.'
		ELSE 'Log file grows to a maximum size of 2 TB.'
		END AS [Growth],
	growth AS 'GrowthValue',
	'GrowthIncrement' = CASE 
		WHEN growth = 0
			THEN 'Size is fixed.'
		WHEN growth > 0
			AND is_percent_growth = 0
			THEN 'Growth value is in 8-KB pages.'
		ELSE 'Growth value is a percentage.'
		END
FROM tempdb.sys.database_files;
GO */

--Check CPU time - use against CM DB
SELECT SPID,
	CPU,
	s2.TEXT,
	open_tran,
	STATUS,
	program_name,
	net_library,
	loginame
FROM sys.sysprocesses
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS s2
WHERE CPU > 5000
ORDER BY STATUS

--Show busiest stored procs
SELECT TOP (15) p.name AS [SP Name],
	qs.total_worker_time AS [TotalWorkerTime],
	qs.total_worker_time / qs.execution_count AS [AvgWorkerTime],
	qs.execution_count,
	ISNULL(qs.execution_count / DATEDIFF(Minute, qs.cached_time, GETDATE()), 0) AS [Calls/Minute],
	qs.total_elapsed_time,
	qs.total_elapsed_time / qs.execution_count AS [avg_elapsed_time],
	qs.cached_time
FROM sys.procedures AS p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats AS qs WITH (NOLOCK) ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY qs.total_worker_time DESC
OPTION (RECOMPILE);

--Get some blocking info
SELECT *
FROM sys.sysprocesses
WHERE blocked = 1

SELECT *
FROM sys.sysprocesses
WHERE program_name LIKE '%Collection%'

--Get Max Evaluation Time
SELECT Name AS [Collection Name],
	DATEDIFF(s, EvaluationStartTime, LastRefreshTime) AS [Evaluation Time In Seconds]
FROM v_Collection
ORDER BY [Evaluation Time In Seconds] DESC

--Check Collection Queries
SELECT Name,
	C.CollectionID,
	QueryExpression
FROM v_CollectionRuleQuery AS CQ
INNER JOIN v_Collection AS C ON CQ.CollectionID = C.CollectionID
WHERE QueryExpression LIKE '%like%''[%]%'
ORDER BY collectionID DESC

SELECT SMS_R_SYSTEM.ResourceID,
	SMS_R_SYSTEM.ResourceType,
	SMS_R_SYSTEM.Name,
	SMS_R_SYSTEM.SMSUniqueIdentifier,
	SMS_R_SYSTEM.ResourceDomainORWorkgroup,
	SMS_R_SYSTEM.Client
FROM SMS_R_System
WHERE SMS_R_System.Name LIKE "%abcdef"

SELECT Name,
	C.CollectionID,
	QueryExpression
FROM v_CollectionRuleQuery AS CQ
INNER JOIN v_Collection AS C ON CQ.CollectionID = C.CollectionID
WHERE QueryExpression LIKE '%NOT LIKE%'
ORDER BY collectionID DESC

SELECT COLL.Name,
	COLL.CollectionID,
	COUNT(*) AS [Number of Direct Rules]
FROM v_CollectionRuleDirect AS CRD
INNER JOIN v_Collection AS COLL ON CRD.CollectionID = COLL.CollectionID
GROUP BY COLL.Name,
	COLL.CollectionID
ORDER BY [Number of Direct Rules] DESC

SELECT COLL.Name,
	COLL.CollectionID,
	Count(*) AS [Number of queries]
FROM v_CollectionRuleQuery AS CRQ
INNER JOIN v_Collection AS COLL ON CRQ.CollectionID = COLL.CollectionID
GROUP BY COLL.Name,
	COLL.CollectionID
ORDER BY [Number of queries] DESC

SELECT SD.SiteCode,
	SC.ComponentName,
	SCP.Name,
	SCP.Value1,
	SCP.Value2,
	SCP.Value3
FROM SC_Component SC
JOIN SC_SiteDefinition SD ON SD.SiteNumber = SC.SiteNumber
JOIN SC_Component_Property SCP ON SCP.ComponentID = SC.ID
WHERE SC.ComponentName LIKE 'SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT'

SELECT *
FROM Collection_EvaluationAndCRCData
ORDER BY NextRefreshTime

SELECT [SiteID],
	[CollectionID],
	[CollectionName],
	[LastRefreshRequest],
	[EvaluationStartTime],
	[LastRefreshTime],
	[LastIncrementalRefreshTime],
	datediff(ss, EvaluationStartTime, LastRefreshTime) AS 'Evaluation time in seconds',
	CASE RefreshType
		WHEN 1
			THEN 'No update'
		WHEN 2
			THEN 'Scheduled update'
		WHEN 4
			THEN 'Incremental update'
		WHEN 6
			THEN 'Scheduled and incremental update'
		END AS 'Refresh Type explained',
	[RefreshType],
	[LastMemberChangeTime],
	[LastChangeTime],
	[LimitToCollectionID],
	[LimitToCollectionName],
	[BeginDate],
	[CurrentStatus],
	[CurrentStatusTime],
	[MemberCount],
	[LocalMemberCount]
FROM [dbo].[v_Collections]
WHERE datediff(MINUTE, DATEADD(HH, DATEDIFF(hh, GETUTCDATE(), GETDATE()), EvaluationStartTime), getdate()) < 5 -- and SiteID not like 'SMS%'
ORDER BY [CollectionID]

SELECT T2.CollectionName,
	(CAST(T1.EvaluationLength AS FLOAT) / 1000) AS 'Time Spent On Eval',
	CASE T1.SiteNumber
		WHEN 1
			THEN 'PR1'
		WHEN 2
			THEN 'PR2'
		WHEN 3
			THEN 'PR3'
		WHEN 4
			THEN 'PR4'
		ELSE 'UNKNOWN'
		END AS SiteNumber
FROM DBO.Collections_L AS T1
INNER JOIN Collections_G AS T2 ON T2.CollectionID = T1.CollectionID
ORDER BY [Time Spent On Eval] DESC

--exec spCollBeginInEvaluation
