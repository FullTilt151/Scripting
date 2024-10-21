--Win10 1809 Targets w/Agents current - WP106354
SELECT Name AS WKID, 
	Version0 AS Model, 
	User_Name0 AS USERID, 
	Full_User_Name0 AS Associate_Name, 
	Mail0 AS Email, 
	title0 AS Title, 
	department0 AS Department
FROM v_CM_RES_COLL_WP106354
    dbo.v_GS_COMPUTER_SYSTEM_PRODUCT AS csp 
	ON csp.ResourceID = coll.ResourceID INNER JOIN
    v_CombinedDeviceResources AS cdr 
	ON coll.ResourceID = cdr.MachineID INNER JOIN
    v_R_User AS usr 
	ON cdr.LastLogonUser = usr.User_Name0
ORDER BY WKID


--Win10 1809 Targets w/Agents current - Direct On-Network - WP106DB2
SELECT Name AS WKID, 
	Version0 AS Model, 
	User_Name0 AS USERID, 
	Full_User_Name0 AS Associate_Name, 
	Mail0 AS Email, 
	title0 AS Title, 
	department0 AS Department
FROM v_CM_RES_COLL_WP106DB2
    dbo.v_GS_COMPUTER_SYSTEM_PRODUCT AS csp 
	ON csp.ResourceID = coll.ResourceID INNER JOIN
    v_CombinedDeviceResources AS cdr 
	ON coll.ResourceID = cdr.MachineID INNER JOIN
    v_R_User AS usr 
	ON cdr.LastLogonUser = usr.User_Name0
ORDER BY WKID

--Win10 1809 Targets w/Agents current - No Array-Aruba - WP106E36
SELECT dbo.v_GS_COMPUTER_SYSTEM.Name0 AS WKID, 
	dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Version0 AS Model, 
	dbo.v_R_User.User_Name0 AS USERID, 
	dbo.v_R_User.Full_User_Name0 AS Associate_Name, 
	dbo.v_R_User.Mail0 AS Email, 
	dbo.v_R_User.title0 AS Title, 
	dbo.v_R_User.department0 AS Department
FROM v_CM_RES_COLL_WP106E36
    dbo.v_GS_COMPUTER_SYSTEM_PRODUCT AS csp 
	ON csp.ResourceID = coll.ResourceID INNER JOIN
    v_CombinedDeviceResources AS cdr 
	ON coll.ResourceID = cdr.MachineID INNER JOIN
    v_R_User AS usr 
	ON cdr.LastLogonUser = usr.User_Name0
ORDER BY WKID

--Win10 1809 Targets - WP105E67
SELECT Name AS WKID, 
	Version0 AS Model, 
	User_Name0 AS USERID, 
	Full_User_Name0 AS Associate_Name, 
	Mail0 AS Email, 
	title0 AS Title, 
	department0 AS Department
FROM v_CM_RES_COLL_WP105E67
    dbo.v_GS_COMPUTER_SYSTEM_PRODUCT AS csp 
	ON csp.ResourceID = coll.ResourceID INNER JOIN
    v_CombinedDeviceResources AS cdr 
	ON coll.ResourceID = cdr.MachineID INNER JOIN
    v_R_User AS usr 
	ON cdr.LastLogonUser = usr.User_Name0
ORDER BY Name

--DiskSpace - WP103EB6
SELECT coll.Name AS WKID, 
	Version0 AS Model, 
	User_Name0 AS USERID, 
	Full_User_Name0 AS Associate_Name, 
	Mail0 AS Email, 
	title0 AS Title, 
	department0 AS Department
FROM v_CM_RES_COLL_WP103EB6 AS coll INNER JOIN
    dbo.v_GS_COMPUTER_SYSTEM_PRODUCT AS csp 
	ON csp.ResourceID = coll.ResourceID INNER JOIN
    v_CombinedDeviceResources AS cdr 
	ON coll.ResourceID = cdr.MachineID INNER JOIN
    v_R_User AS usr 
	ON cdr.LastLogonUser = usr.User_Name0
ORDER BY WKID

--Email Manager Collection 
SELECT coll.Name AS WKID, 
	Version0 AS Model, 
	User_Name0 AS USERID, 
	Full_User_Name0 AS Associate_Name, 
	Mail0 AS Email, 
	title0 AS Title, 
	department0 AS Department,
    (SELECT Full_User_Name0 FROM dbo.v_R_User AS MGR WHERE usr.Manager0 = MGR.Distinguished_Name0) [MGR_Name],
	(SELECT title0 FROM dbo.v_R_User AS MGR WHERE usr.Manager0 = MGR.Distinguished_Name0) [MGR_Title],
	(SELECT Mail0 FROM dbo.v_R_User AS MGR WHERE usr.Manager0 = MGR.Distinguished_Name0) [MGR_Email]
FROM v_CM_RES_COLL_WP10804F AS coll INNER JOIN
    dbo.v_GS_COMPUTER_SYSTEM_PRODUCT AS csp 
	ON csp.ResourceID = coll.ResourceID INNER JOIN
    v_CombinedDeviceResources AS cdr 
	ON coll.ResourceID = cdr.MachineID INNER JOIN
    v_R_User AS usr 
	ON cdr.LastLogonUser = usr.User_Name0
ORDER BY MGR_Email