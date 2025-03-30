SELECT dbo.v_R_System.Netbios_Name0 AS WKID,
	dbo.v_R_System.Build01 AS OS_Build,
	dbo.v_R_System.User_Name0 AS USERID,
	dbo.v_GS_MONITORDETAILS.Manufacturer0 AS Manufacturer,
	dbo.v_GS_MONITORDETAILS.Name0 AS Model,
	dbo.v_GS_MONITORDETAILS.DiagonalSize0 AS Size,
	dbo.v_GS_MONITORDETAILS.SerialNumber0 AS SerialNumaber
FROM dbo.v_R_System
INNER JOIN dbo.v_GS_MONITORDETAILS ON dbo.v_R_System.ResourceID = dbo.v_GS_MONITORDETAILS.ResourceID
ORDER BY WKID DESC
