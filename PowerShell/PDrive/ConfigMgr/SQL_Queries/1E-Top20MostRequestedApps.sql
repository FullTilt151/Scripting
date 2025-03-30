CREATE FUNCTION ConvertNumber(@Number INT)
RETURNS VARCHAR(20)
AS
BEGIN

DECLARE @String VARCHAR(20)

SET @String = LTRIM(@Number)
IF (LEN(@String) > 6)
BEGIN
	SET @String =
		SUBSTRING(@String, 1, LEN(@String) - 6) +
		',' +
		SUBSTRING(@String, LEN(@String) - 5, 3) +
		',' +
		SUBSTRING(@String, LEN(@String) - 2, LEN(@String))
END
ELSE IF (LEN(@String) > 3)
BEGIN
	SET @String =
		SUBSTRING(@String, 1, LEN(@String) - 3) +
		',' +
		SUBSTRING(@String, LEN(@String) - 2, LEN(@String))
END

RETURN @String

END
GO

SELECT	TOP 20 DisplayName, dbo.ConvertNumber(Total) [Shopping Requests]
FROM	(
			SELECT	TOP 20 A.DisplayName, COUNT(*) Total
			FROM	tb_CompletedOrder CO
						INNER JOIN tb_Application A ON CO.ApplicationId = A.ApplicationId
			GROUP BY CO.ApplicationId, A.DisplayName
			ORDER BY Total DESC
) X
ORDER BY Total DESC

DROP FUNCTION ConvertNumber
GO