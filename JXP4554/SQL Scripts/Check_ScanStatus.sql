SELECT STN.StateName,
	count(*) [Count]
FROM v_UpdateScanStatus USS
JOIN v_StateNames STN ON STN.StateID = USS.LastScanState
WHERE (dateadd(hh, - 5, CAST(USS.LastScanTime AS DATETIME)) > SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 08, 00))
	AND USS.LastErrorCode != 0
GROUP BY STN.StateName
ORDER BY Count DESC

SELECT DISTINCT STM.Netbios_Name0 [WKID],
	USS.LastScanPackageLocation,
	USS.LastScanTime,
	USS.LastStatusMessageID,
	CONVERT(VARBINARY(8), USS.LastErrorCode) [LastErrorCode],
	USS.ScanPackageVersion,
	STN.StateName
FROM v_r_system STM
JOIN v_UpdateScanStatus USS ON STM.ResourceID = USS.ResourceID
JOIN v_StateNames STN ON STN.StateID = USS.LastScanState
WHERE (dateadd(hh, - 5, CAST(USS.LastScanTime AS DATETIME)) > SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 08, 00))
	AND USS.LastErrorCode != 0
ORDER BY USS.LastScanTime DESC

SELECT CONVERT(VARBINARY(8), USS.LastErrorCode) [LastErrorCode],
	Count(*) [Count]
FROM v_updateScanStatus USS
WHERE (dateadd(hh, - 5, CAST(USS.LastScanTime AS DATETIME)) > SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 08, 00))
	AND USS.LastErrorCode != 0
GROUP BY [LastErrorCode]
ORDER BY [Count] DESC

SELECT DISTINCT STM.Netbios_Name0 [WKID],
	USS.LastScanPackageLocation,
	USS.LastScanTime,
	USS.LastStatusMessageID,
	CONVERT(VARBINARY(8), USS.LastErrorCode) [LastErrorCode],
	USS.ScanPackageVersion,
	STN.StateName
FROM v_r_system STM
JOIN v_UpdateScanStatus USS ON STM.ResourceID = USS.ResourceID
JOIN v_StateNames STN ON STN.StateID = USS.LastScanState
WHERE USS.LastScanPackageLocation = 'http://LOUAPPWPS1642.rsc.humad.com:8530'
ORDER BY STM.Netbios_Name0

SELECT DISTINCT STM.Netbios_Name0 [WKID]
FROM v_r_system STM
JOIN v_UpdateScanStatus USS ON STM.ResourceID = USS.ResourceID
JOIN v_StateNames STN ON STN.StateID = USS.LastScanState
WHERE USS.LastScanPackageLocation = '' or USS.LastScanPackageLocation is NULL
ORDER BY STM.Netbios_Name0
