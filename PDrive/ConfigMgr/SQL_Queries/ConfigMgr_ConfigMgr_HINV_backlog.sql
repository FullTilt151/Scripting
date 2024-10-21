-- Find spids
sp_who2

-- Find blocks
SELECT db.name DBName,
tl.request_session_id,
wt.blocking_session_id,
OBJECT_NAME(p.OBJECT_ID) BlockedObjectName,
tl.resource_type,
h1.TEXT AS RequestingText,
h2.TEXT AS BlockingTest,
tl.request_mode
FROM sys.dm_tran_locks AS tl
INNER JOIN sys.databases db ON db.database_id = tl.resource_database_id
INNER JOIN sys.dm_os_waiting_tasks AS wt ON tl.lock_owner_address = wt.resource_address
INNER JOIN sys.partitions AS p ON p.hobt_id = tl.resource_associated_entity_id
INNER JOIN sys.dm_exec_connections ec1 ON ec1.session_id = tl.request_session_id
INNER JOIN sys.dm_exec_connections ec2 ON ec2.session_id = wt.blocking_session_id
CROSS APPLY sys.dm_exec_sql_text(ec1.most_recent_sql_handle) AS h1
CROSS APPLY sys.dm_exec_sql_text(ec2.most_recent_sql_handle) AS h2
GO

-- SP for delete and the specific query being ran
/*
spRemoveInvGroup
delete from HinvChangeLog where GroupKey = 220
*/

-- Kill the blocking SPID
/*
kill 121
kill 121 with statusonly
*/

-- Get total count of rows for blocking process
select * from HinvChangeLog where GroupKey = 220
select * from HinvChangeLog
select GroupKey, count(*) from HinvChangeLog group by GroupKey order by GroupKey

--https://blogs.msdn.microsoft.com/martijnh/2010/07/15/sql-serverhow-to-quickly-retrieve-accurate-row-count-for-table/
-- Row count of large table
SELECT COUNT(*)
FROM HinvChangeLog
WITH (NOLOCK)
WHERE GroupKey = 220

-- Row count of large table - filtered
SELECT Total_Rows= SUM(st.row_count)
FROM sys.dm_db_partition_stats st
WHERE object_name(object_id) = 'HinvChangeLog' AND (index_id < 2)

-- Row count of large table - unfiltered
select *
from sys.dm_db_partition_stats
WHERE object_name(object_id) = 'HinvChangeLog'

-- Create SP to manually remove HINVchangelog rows for a group
CREATE PROCEDURE [dbo].[sp_MSHinvChangeLog_Cleanup]
    @groupkey_delete int
as
DECLARE @row_count int
WHILE 1 = 1
    BEGIN
             DELETE TOP(100000) HinvChangeLog from HinvChangeLog
                    WHERE GroupKey = @groupkey_delete
             SELECT @row_count = @@rowcount
        IF @row_count < 100000 -- we're done, found all rows to delete
            BREAK
    END      
GO

-- Run SP to manually remove HINVChangeLog rows for a group
--sp_MSHinvChangeLog_Cleanup 220

-- TRUNCATE --
/* 
-- Stop INVENTORY_DATA_LOADER (or just SMS_EXECUTIVE)
-- Truncate the table
Truncate TABLE HinvChangeLog 

-- Reseed the table
Dbcc checkident ('HinvChangeLog', RESEED, 1)

-- Get any constraints?
-- The INSERT statement conflicted with the CHECK constraint "HinvChangeLog_RecordID_Partition_CK" 
Exec spCheckReseedIdentity

-- Delete Agent Inventory Maint Task failing?
Truncate TABLE JAVA_EXCEPTION_SITES_DATA
Truncate TABLE JAVA_EXCEPTION_SITES_HIST
*/
select * from v_GS_JAVA_EXCEPTION_SITES
select * from v_HS_JAVA_EXCEPTION_SITES