DECLARE @runtime DATETIME 
DECLARE @cpu_time_start     BIGINT, 
        @cpu_time           BIGINT, 
        @elapsed_time_start BIGINT, 
        @rowcount           BIGINT 
DECLARE @queryduration            INT, 
        @qrydurationwarnthreshold INT 
DECLARE @querystarttime DATETIME 

SET @runtime = Getdate() 
SET @qrydurationwarnthreshold = 5000 

PRINT '' 

PRINT 
'===============================================================================================' 

PRINT 'Missing Indexes: ' 

PRINT 
'The "improvement_measure" column is an indicator of the (estimated) improvement that might ' 

PRINT 
'be seen if the index was created.  This is a unitless number, and has meaning only relative ' 

PRINT 
'the same number for other indexes.  The measure is a combination of the avg_total_user_cost, ' 

PRINT 
'avg_user_impact, user_seeks, and user_scans columns in sys.dm_db_missing_index_group_stats.' 

PRINT '' 

PRINT '-- Missing Indexes --' 

SELECT CONVERT (VARCHAR(30), @runtime, 126)                           AS runtime 
       , 
       mig.index_group_handle, 
       mid.index_handle, 
       CONVERT (DECIMAL (28, 1), migs.avg_total_user_cost * migs.avg_user_impact 
                                 * ( 
                                 migs.user_seeks + migs.user_scans )) AS 
       improvement_measure, 
       'CREATE INDEX missing_index_' 
       + CONVERT (VARCHAR, mig.index_group_handle) 
       + '_' + CONVERT (VARCHAR, mid.index_handle) 
       + ' ON ' + mid.statement + ' (' 
       + Isnull (mid.equality_columns, '') + CASE WHEN mid.equality_columns IS 
       NOT NULL 
       AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END 
       + Isnull (mid.inequality_columns, '') + ')' 
       + Isnull (' INCLUDE (' + mid.included_columns + ')', '')       AS 
       create_index_statement, 
       migs.*, 
       mid.database_id, 
       mid.[object_id] 
FROM   sys.dm_db_missing_index_groups mig 
       INNER JOIN sys.dm_db_missing_index_group_stats migs 
               ON migs.group_handle = mig.index_group_handle 
       INNER JOIN sys.dm_db_missing_index_details mid 
               ON mig.index_handle = mid.index_handle 
WHERE  CONVERT (DECIMAL (28, 1), migs.avg_total_user_cost * migs.avg_user_impact 
                                 * ( 
                                        migs.user_seeks + migs.user_scans )) > 
       10 
ORDER  BY migs.avg_total_user_cost * migs.avg_user_impact * ( 
                    migs.user_seeks + migs.user_scans ) DESC 

PRINT ''   