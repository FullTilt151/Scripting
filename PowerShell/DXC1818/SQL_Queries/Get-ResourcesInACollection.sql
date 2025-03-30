--Device Models in Unknow/Obs collection WP106401
SELECT Coll.Name AS WKID,
	csp.Name0 AS MTM, 
	Version0 AS Model
FROM v_CM_RES_COLL_WP106401 AS coll INNER JOIN
    dbo.v_GS_COMPUTER_SYSTEM_PRODUCT AS csp 
	ON csp.ResourceID = coll.ResourceID
ORDER by Model

SELECT *
FROM v_CM_RES_COLL_WP106401 AS coll

--DiskSpace Collection
SELECT Name, UserName, ADSiteName, DeviceOSBuild
FROM [dbo].[_RES_COLL_WP103EB6]
ORDER BY Name

--PreCache Collection
SELECT Name, UserName, ADSiteName, DeviceOSBuild
FROM [dbo].[_RES_COLL_WP1063BF]
ORDER BY Name

