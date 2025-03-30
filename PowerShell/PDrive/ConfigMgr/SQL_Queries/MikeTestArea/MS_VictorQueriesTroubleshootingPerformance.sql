---Processes Blocked
select * from sys.sysprocesses where blocked <> 0

SELECT SPID, CPU, s2.text, open_tran, status, program_name, net_library, loginame
FROM  sys.sysprocesses
      CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS s2
WHERE CPU > 5000        -- CPU usage greater than 5 seconds
and   status like 'run%'

SELECT T.*, E.text, p.query_plan
FROM sys.dm_tran_active_snapshot_database_transactions T
JOIN sys.dm_exec_requests R ON T.Session_ID = R.Session_ID
INNER JOIN sys.sysprocesses S on S.spid = T.Session_ID
OUTER APPLY sys.dm_exec_query_plan(R.plan_handle) AS P
OUTER APPLY sys.dm_exec_sql_text(R.sql_handle) AS E
ORDER BY elapsed_time_seconds DESC;

--check fragmentation
SELECT OBJECT_NAME(ips.OBJECT_ID)
 ,i.NAME
 ,ips.index_id
 ,index_type_desc
 ,avg_fragmentation_in_percent
 ,avg_page_space_used_in_percent
 ,page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
INNER JOIN sys.indexes i ON (ips.object_id = i.object_id)
 AND (ips.index_id = i.index_id)
ORDER BY avg_fragmentation_in_percent DESC