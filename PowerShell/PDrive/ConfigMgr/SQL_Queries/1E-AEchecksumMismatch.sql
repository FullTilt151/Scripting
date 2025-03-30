DECLARE @propertyName NVARCHAR(256)
DECLARE @tableName NVARCHAR(256)

SET @tableName = 'AppliedChanges2'
SELECT value FROM fn_listextendedproperty (@propertyName, 'schema', 'dbo', 'table', @tableName, default, default)

DECLARE @checksumValue INT

SET @propertyName = 'checksum'
SELECT @checksumValue = CHECKSUM_AGG(CHECKSUM(ChangeId, DateApplied_utc, SourceVersion)) FROM [dbo].[AppliedChanges2]

SELECT @checksumValue

IF EXISTS(SELECT 1 FROM fn_listextendedproperty (@propertyName, 'SCHEMA', 'dbo', 'TABLE', @tableName, default, default))
BEGIN
    EXEC sp_updateextendedproperty @name = @propertyName, @value = @checksumValue, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = 'TABLE', @level1name = @tableName
END
ELSE
BEGIN
    EXEC sp_addextendedproperty @name = @propertyName, @value = @checksumValue, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = 'TABLE', @level1name = @tableName
END
