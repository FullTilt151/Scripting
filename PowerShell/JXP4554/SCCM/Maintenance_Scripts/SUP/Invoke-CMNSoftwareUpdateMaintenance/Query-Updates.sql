SELECT TOP 5 *
FROM v_AuthListInfo

SELECT TOP 5 *
FROM v_UpdateInfo

SELECT *
FROM vSMS_CIRelation CR
JOIN v_UpdateCIs UCI ON cr.FromCIID = UCI.CI_ID

SELECT DISTINCT upd.DisplayName
FROM vSMS_CIRelation AS cr
INNER JOIN fn_ListUpdateCIs(1033) upd ON upd.CI_ID = cr.ToCIID
	AND cr.RelationType = 1
INNER JOIN v_CIToContent CC ON cc.CI_ID = upd.CI_ID
INNER JOIN v_AuthListInfo AL ON al.CI_ID = cr.FromCIID

SELECT TOP 5 UPD.*
FROM vSMS_CIRelation AS cr
INNER JOIN fn_ListUpdateCIs(1033) upd ON upd.CI_ID = cr.ToCIID
	AND cr.RelationType = 1
INNER JOIN v_CIToContent CC ON cc.CI_ID = upd.CI_ID
INNER JOIN v_AuthListInfo AL ON al.CI_ID = cr.FromCIID
WHERE UPD.ArticleID > 2443100
	AND UPD.ArticleID < 2443110

SELECT TOP 5. *
FROM v_UpdateCIs
WHERE CI_UniqueID = '7cf9c202-6725-4cb8-bc4f-4051ae5b5253'

SELECT TOP 5. *
FROM v_UpdateCIs
WHERE IsDeployed = 1

SELECT DISTINCT UCI.CI_UniqueID
FROM vSMS_CIRelation CR
JOIN v_UpdateCIs UCI ON CR.ToCIID = UCI.CI_ID
JOIN v_AuthListInfo AL ON AL.CI_ID = CR.FromCIID
ORDER BY UCI.CI_UniqueID

-- List of scan results since X time
SELECT ScanPackageVersion,
	dateadd(hh, - 5, CAST(LastScanTime AS DATETIME)) [LastScanTime],
	LastStatusMessageID,
	LastErrorCode
FROM v_updatescanstatus
WHERE dateadd(hh, - 5, CAST(LastScanTime AS DATETIME)) > SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 08, 00)
ORDER BY CAST(LastScanTime AS DATETIME) DESC

-- Count of scan results since X time
SELECT LastErrorCode,
	count(*)
FROM v_updatescanstatus
WHERE dateadd(hh, - 5, CAST(LastScanTime AS DATETIME)) > SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 16, 00)
GROUP BY LastErrorCode
ORDER BY LastErrorCode
