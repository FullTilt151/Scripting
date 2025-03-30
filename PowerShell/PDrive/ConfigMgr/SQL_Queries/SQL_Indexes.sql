-- Tables for a view
SELECT view_name, Table_Name
FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE
WHERE VIEW_NAME = 'v_r_system'
ORDER BY view_name, table_name

-- All indexed TABLE columns
SELECT TableName = t.name, IndexName = ind.name, IndexId = ind.index_id,  ColumnId = ic.index_column_id, ColumnName = col.name, ts.VIEW_NAME, ts.TABLE_NAME
FROM  sys.indexes ind INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id join
	 INFORMATION_SCHEMA.VIEW_TABLE_USAGE TS on t.name = ts.table_name
WHERE ind.is_primary_key = 0 AND ind.is_unique = 0 AND ind.is_unique_constraint = 0  AND t.is_ms_shipped = 0
ORDER BY t.name, ind.name, ind.index_id, ic.index_column_id

-- Joined View and Table indexed columns
SELECT distinct ts.VIEW_NAME [View], ts.TABLE_NAME [Table], col.name [Column]
FROM sys.indexes ind INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id full join
	 INFORMATION_SCHEMA.VIEW_TABLE_USAGE TS on t.name = ts.table_name
WHERE ts.VIEW_NAME like @View
ORDER BY [View]