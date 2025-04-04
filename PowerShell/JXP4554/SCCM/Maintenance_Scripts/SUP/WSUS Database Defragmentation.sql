/****************************************************************************** 
This sample T-SQL script performs basic maintenance tasks on SUSDB 
1. Identifies indexes that are fragmented and defragments them. For certain 
   tables, a fill-factor is set in order to improve insert performance. 
   Based on MSDN sample at http://msdn2.microsoft.com/en-us/library/ms188917.aspx 
   and tailored for SUSDB requirements 
2. Updates potentially out-of-date table statistics. 

If you need to connect to the windows internal db, here's the path:
\\.\pipe\MSSQL$MICROSOFT##SSEE\sql\query
******************************************************************************/
USE SUSDB;
GO

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

-- Rebuild or reorganize indexes based on their fragmentation levels 
DECLARE @work_to_do TABLE (
	objectid INT,
	indexid INT,
	pagedensity FLOAT,
	fragmentation FLOAT,
	numrows INT
	)
DECLARE @objectid INT;
DECLARE @indexid INT;
DECLARE @schemaname NVARCHAR(130);
DECLARE @objectname NVARCHAR(130);
DECLARE @indexname NVARCHAR(130);
DECLARE @numrows INT
DECLARE @density FLOAT;
DECLARE @fragmentation FLOAT;
DECLARE @command NVARCHAR(4000);
DECLARE @fillfactorset BIT
DECLARE @numpages INT

-- Select indexes that need to be defragmented based on the following 
-- * Page density is low 
-- * External fragmentation is high in relation to index size 
PRINT 'Estimating fragmentation: Begin. ' + convert(NVARCHAR, getdate(), 121)

INSERT @work_to_do
SELECT f.object_id,
	index_id,
	avg_page_space_used_in_percent,
	avg_fragmentation_in_percent,
	record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') AS f
WHERE (
		f.avg_page_space_used_in_percent < 85.0
		AND f.avg_page_space_used_in_percent / 100.0 * page_count < page_count - 1
		)
	OR (
		f.page_count > 50
		AND f.avg_fragmentation_in_percent > 15.0
		)
	OR (
		f.page_count > 10
		AND f.avg_fragmentation_in_percent > 80.0
		)

PRINT 'Number of indexes to rebuild: ' + cast(@@ROWCOUNT AS NVARCHAR(20))
PRINT 'Estimating fragmentation: End. ' + convert(NVARCHAR, getdate(), 121)

SELECT @numpages = sum(ps.used_page_count)
FROM @work_to_do AS fi
INNER JOIN sys.indexes AS i ON fi.objectid = i.object_id
	AND fi.indexid = i.index_id
INNER JOIN sys.dm_db_partition_stats AS ps ON i.object_id = ps.object_id
	AND i.index_id = ps.index_id

-- Declare the cursor for the list of indexes to be processed. 
DECLARE curIndexes CURSOR
FOR
SELECT *
FROM @work_to_do

-- Open the cursor. 
OPEN curIndexes

-- Loop through the indexes 
WHILE (1 = 1)
BEGIN
	FETCH NEXT
	FROM curIndexes
	INTO @objectid,
		@indexid,
		@density,
		@fragmentation,
		@numrows;

	IF @@FETCH_STATUS < 0
		BREAK;

	SELECT @objectname = QUOTENAME(o.name),
		@schemaname = QUOTENAME(s.name)
	FROM sys.objects AS o
	INNER JOIN sys.schemas AS s ON s.schema_id = o.schema_id
	WHERE o.object_id = @objectid;

	SELECT @indexname = QUOTENAME(name),
		@fillfactorset = CASE fill_factor
			WHEN 0
				THEN 0
			ELSE 1
			END
	FROM sys.indexes
	WHERE object_id = @objectid
		AND index_id = @indexid;

	IF (
			(
				@density BETWEEN 75.0
					AND 85.0
				)
			AND @fillfactorset = 1
			)
		OR (@fragmentation < 30.0)
		SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REORGANIZE';
	ELSE IF @numrows >= 5000
		AND @fillfactorset = 0
		SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD WITH (FILLFACTOR = 90)';
	ELSE
		SET @command = N'ALTER INDEX ' + @indexname + N' ON ' + @schemaname + N'.' + @objectname + N' REBUILD';

	PRINT convert(NVARCHAR, getdate(), 121) + N' Executing: ' + @command;

	EXEC (@command);

	PRINT convert(NVARCHAR, getdate(), 121) + N' Done.';
END

-- Close and deallocate the cursor. 
CLOSE curIndexes;

DEALLOCATE curIndexes;

IF EXISTS (
		SELECT *
		FROM @work_to_do
		)
BEGIN
	PRINT 'Estimated number of pages in fragmented indexes: ' + cast(@numpages AS NVARCHAR(20))

	SELECT @numpages = @numpages - sum(ps.used_page_count)
	FROM @work_to_do AS fi
	INNER JOIN sys.indexes AS i ON fi.objectid = i.object_id
		AND fi.indexid = i.index_id
	INNER JOIN sys.dm_db_partition_stats AS ps ON i.object_id = ps.object_id
		AND i.index_id = ps.index_id

	PRINT 'Estimated number of pages freed: ' + cast(@numpages AS NVARCHAR(20))
END
GO

--Update all statistics 
PRINT 'Updating all statistics.' + convert(NVARCHAR, getdate(), 121)

EXEC sp_updatestats

PRINT 'Done updating statistics.' + convert(NVARCHAR, getdate(), 121)
GO


