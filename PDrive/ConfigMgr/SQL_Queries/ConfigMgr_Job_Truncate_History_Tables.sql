SELECT t.NAME                                         AS TableName, 
       s.NAME                                         AS SchemaName, 
       p.rows                                         AS RowCounts, 
       Sum(a.total_pages) * 8                         AS TotalSpaceKB, 
       Sum(a.used_pages) * 8                          AS UsedSpaceKB, 
       ( Sum(a.total_pages) - Sum(a.used_pages) ) * 8 AS UnusedSpaceKB 
FROM   sys.tables t 
       INNER JOIN sys.indexes i 
               ON t.object_id = i.object_id 
       INNER JOIN sys.partitions p 
               ON i.object_id = p.object_id 
                  AND i.index_id = p.index_id 
       INNER JOIN sys.allocation_units a 
               ON p.partition_id = a.container_id 
       LEFT OUTER JOIN sys.schemas s 
                    ON t.schema_id = s.schema_id 
WHERE  t.NAME NOT LIKE 'dt%' 
       AND t.NAME LIKE '%[_]HIST' 
       AND t.NAME NOT IN ( 'Disk_HIST', 'Logical_Disk_HIST', 'MAPPED_LOGICAL_DISK_HIST' ) 
       AND t.is_ms_shipped = 0 
       AND i.object_id > 255 
GROUP  BY t.NAME, 
          s.NAME, 
          p.rows 
ORDER  BY rowcounts DESC 

go

/****** Object:  Job [ConfigMgr Truncate History Tables]    Script Date: 9/8/2014 2:05:50 PM ******/ 

BEGIN TRANSACTION 

DECLARE @ReturnCode INT 

SELECT @ReturnCode = 0 

/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9/8/2014 2:05:51 PM ******/ 
IF NOT EXISTS (SELECT NAME 
               FROM   msdb.dbo.syscategories 
               WHERE  NAME = N'[Uncategorized (Local)]' 
                      AND category_class = 1) 
  BEGIN 
      EXEC @ReturnCode = msdb.dbo.Sp_add_category 
        @class=N'JOB', 
        @type=N'LOCAL', 
        @name=N'[Uncategorized (Local)]' 

      IF ( @@ERROR <> 0 
            OR @ReturnCode <> 0 ) 
        GOTO quitwithrollback 
  END 

DECLARE @jobId BINARY(16) 

EXEC @ReturnCode = msdb.dbo.Sp_add_job 
  @job_name=N'ConfigMgr Truncate History Tables', 
  @enabled=1, 
  @notify_level_eventlog=0, 
  @notify_level_email=0, 
  @notify_level_netsend=0, 
  @notify_level_page=0, 
  @delete_level=0, 
  @description=N'Truncate ConfigMgr database History tables', 
  @category_name=N'[Uncategorized (Local)]', 
  @owner_login_name=N'NT AUTHORITY\SYSTEM', 
  @job_id = @jobId output 

IF ( @@ERROR <> 0 
      OR @ReturnCode <> 0 ) 
  GOTO quitwithrollback 

/****** Object:  Step [Truncate]    Script Date: 9/8/2014 2:05:51 PM ******/ 
EXEC @ReturnCode = msdb.dbo.Sp_add_jobstep 
  @job_id=@jobId, 
  @step_name=N'Truncate', 
  @step_id=1, 
  @cmdexec_success_code=0, 
  @on_success_action=1, 
  @on_success_step_id=0, 
  @on_fail_action=2, 
  @on_fail_step_id=0, 
  @retry_attempts=0, 
  @retry_interval=0, 
  @os_run_priority=0, 
  @subsystem=N'TSQL', 
  @command=N'USE [CM_WP1]
  GO
  DECLARE @SQL NVARCHAR(MAX) = N''  ''  
  SELECT    @SQL = @SQL + N''TRUNCATE TABLE dbo.'' + TABLE_NAME + '';  
  ''    FROM    INFORMATION_SCHEMA.TABLES x  
  WHERE    x.TABLE_SCHEMA = ''dbo''    
  AND x.TABLE_NAME LIKE ''%[_]HIST''    
  AND x.TABLE_NAME not in (''Disk_HIST'',''Logical_Disk_HIST'',''MAPPED_LOGICAL_DISK_HIST'')  
  ORDER BY    x.TABLE_NAME
  exec sp_executesql @SQL', 
  @database_name=N'CM_WP1', 
  @flags=0 

IF ( @@ERROR <> 0 
      OR @ReturnCode <> 0 ) 
  GOTO quitwithrollback 

EXEC @ReturnCode = msdb.dbo.Sp_update_job 
  @job_id = @jobId, 
  @start_step_id = 1 

IF ( @@ERROR <> 0 
      OR @ReturnCode <> 0 ) 
  GOTO quitwithrollback 

EXEC @ReturnCode = msdb.dbo.Sp_add_jobschedule 
  @job_id=@jobId, 
  @name=N'ConfigMgr Truncate Hsitory', 
  @enabled=1, 
  @freq_type=4, 
  @freq_interval=1, 
  @freq_subday_type=1, 
  @freq_subday_interval=0, 
  @freq_relative_interval=0, 
  @freq_recurrence_factor=0, 
  @active_start_date=20140908, 
  @active_end_date=99991231, 
  @active_start_time=231100, 
  @active_end_time=235959, 
  @schedule_uid=N'9936718a-af85-497b-ac0d-d47d91ce99d8' 

IF ( @@ERROR <> 0 
      OR @ReturnCode <> 0 ) 
  GOTO quitwithrollback 

EXEC @ReturnCode = msdb.dbo.Sp_add_jobserver 
  @job_id = @jobId, 
  @server_name = N'(local)' 

IF ( @@ERROR <> 0 
      OR @ReturnCode <> 0 ) 
  GOTO quitwithrollback 

COMMIT TRANSACTION 

GOTO endsave 

QUITWITHROLLBACK: 

IF ( @@TRANCOUNT > 0 ) 
  ROLLBACK TRANSACTION 

ENDSAVE: 

go   