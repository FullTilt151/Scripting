-- CEViewer
SELECT [t2].[CollectionName], [t2].[SiteID], [t2].[value] AS [Seconds], [t2].[LastIncrementalRefreshTime], [t2].[IncrementalMemberChanges] AS [IncChanges], [t2].[LastMemberChangeTime] AS [MemberChangeTime]
FROM (
    SELECT [t0].[CollectionName], [t0].[SiteID], DATEDIFF(Millisecond, [t1].[IncrementalEvaluationStartTime], [t1].[LastIncrementalRefreshTime]) * 0.001 AS [value], [t1].[LastIncrementalRefreshTime], [t1].[IncrementalMemberChanges], [t1].[LastMemberChangeTime], [t1].[IncrementalEvaluationStartTime], v1.[RefreshType]
    FROM [dbo].[Collections_G] AS [t0] INNER JOIN
	[dbo].[Collections_L] AS [t1] ON [t0].[CollectionID] = [t1].[CollectionID] INNER JOIN
	v_Collection v1 on [t0].[siteid] = v1.CollectionID
    ) AS [t2]
WHERE ([t2].[IncrementalEvaluationStartTime] IS NOT NULL) AND ([t2].[LastIncrementalRefreshTime] IS NOT NULL) and (refreshtype='4' or refreshtype='6')
ORDER BY [t2].[value] DESC

/* Important objects in collection evaluation
Tables:	CollectionMembers, collection_rules, collection_rules_sql, collections_g, collections_l, collectionqueryruletables, collectionnotifications
SP’s: sp_transfermemberhip, sp_getcollectionsmarkedforevaluation, spcollbeginincevaluation, spcollendincevaluation
Functions: fn_collectiondependencychain
*/

-- SP that hung up CollNotification table
-- EXEC spCollEndIncEvaluation 18008245112
-- EXEC spCollEndIncEvaluation 18104486858

-- Sys processes and spid (identify long running processes)
select spid, blocked, cpu, physical_io, memusage, status, program_name, cmd
from sys.sysprocesses where program_name like 'SMS_COLLECTION_EVALUATOR%'

-- Kill 225

-- Get the query for a spid
dbcc inputbuffer(51)
dbcc inputbuffer(100)
dbcc inputbuffer(101)
dbcc inputbuffer(176)

-- Collection status count
select case currentstatus
	  when '0' then 'NONE'
	  when '1' then 'READY'
	  when '2' then 'REFRESHING'
	  when '3' then 'SAVING'
	  when '4' then 'EVALUATING'
	  when '5' then 'AWAITING_REFRESH'
	  when '6' then 'DELETING'
	  when '7' then 'APPENDING_MEMBER'
	  when '8' then 'QUERYING'
	  end [Status], count(*)
from v_collection
group by case currentstatus
	  when '0' then 'NONE'
	  when '1' then 'READY'
	  when '2' then 'REFRESHING'
	  when '3' then 'SAVING'
	  when '4' then 'EVALUATING'
	  when '5' then 'AWAITING_REFRESH'
	  when '6' then 'DELETING'
	  when '7' then 'APPENDING_MEMBER'
	  when '8' then 'QUERYING'
	  end

-- Collection status list
select *
from v_Collection
where CurrentStatus = '2'

-- Remaining rows in CollectionNotification
Select count(*)
from CollectionNotifications
--where RecordID <= 19849692808

-- Tables with lots of Coll changes
SELECT	tablename, count(*) [Count]
FROM 		CollectionNotifications
GROUP BY	tableName
ORDER BY	count(*) DESC

-- spCollEndIncEvaluation modified
/*
SET NOCOUNT ON 
while (1=1)
begin 
    delete top (40000) from CollectionNotifications where RecordID <= 18104486858
    if @@ROWCOUNT = 0  
        break 
end 
*/

-- SQL Blocks
SELECT s.session_id    ,r.STATUS    ,r.blocking_session_id as 'blocked by'    ,r.wait_type    ,wait_resource    ,r.wait_time / (1000.0) as 'Wait Time (in Sec)'    ,r.cpu_time    ,r.logical_reads    ,r.reads    ,r.writes    ,r.total_elapsed_time / (1000.0) 'Elapsed Time (in Sec)'
    ,Substring(st.TEXT, (r.statement_start_offset / 2) + 1, (
            (
                CASE r.statement_end_offset
                    WHEN - 1
                        THEN Datalength(st.TEXT)
                    ELSE r.statement_end_offset
                    END - r.statement_start_offset
                ) / 2
            ) + 1) AS statement_text
    ,Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' + 
     Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text
    ,r.command    ,s.login_name    ,s.host_name    ,s.program_name    ,s.host_process_id    ,s.last_request_end_time    ,s.login_time    ,r.open_transaction_count
FROM sys.dm_exec_sessions AS s
INNER JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE r.session_id != @@SPID and r.blocking_session_id <> 0
ORDER BY r.cpu_time DESC    ,r.STATUS    ,r.blocking_session_id    ,s.session_id