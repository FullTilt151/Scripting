use SUSDB
DECLARE @var1 NVARCHAR(255)
DECLARE @msg NVARCHAR(100)
DECLARE @Count INT = 0

SELECT UpdateId
INTO #results
FROM PUBLIC_VIEWS.vUpdate
WHERE IsDeclined = 1

DECLARE wc CURSOR
FOR
SELECT UpdateId
FROM #results

OPEN wc

FETCH NEXT
FROM wc
INTO @var1

WHILE (@@FETCH_STATUS > - 1)
BEGIN
	SET @Count = @Count + 1
	SET @msg = CONVERT(VARCHAR(4), @Count) + ' Deleting ' + CONVERT(VARCHAR(100), @var1)

	RAISERROR (
			@msg,
			0,
			1
			)
	WITH NOWAIT

	EXEC spDeleteUpdateByUpdateID @UpdateID = @var1

	FETCH NEXT
	FROM wc
	INTO @var1
END

CLOSE wc

DEALLOCATE wc

DROP TABLE #results

SELECT UpdateId
FROM PUBLIC_VIEWS.vUpdate
WHERE IsDeclined = 1
