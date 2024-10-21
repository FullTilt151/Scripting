SELECT     dbo.v_R_System.Netbios_Name0 AS WKID, dbo.v_R_System.User_Name0 AS [User], dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OS, 
                      dbo.v_GS_VIDEO_CONTROLLER.AdapterCompatibility0 AS Vendor, dbo.v_GS_VIDEO_CONTROLLER.Name0 AS Expr1, 
                      dbo.v_GS_VIDEO_CONTROLLER.VideoProcessor0, dbo.v_GS_VIDEO_CONTROLLER.DriverVersion0, dbo.v_GS_VIDEO_CONTROLLER.DriverDate0, 
                      dbo.v_GS_SoftwareFile.FileName, dbo.v_GS_SoftwareFile.FileVersion, dbo.v_GS_SoftwareFile.FileSize, dbo.v_GS_SoftwareFile.FilePath, dbo.v_GS_Client0.Name0, 
                      dbo.v_GS_Client0.Vendor0, dbo.v_GS_Client0.Version0
FROM         dbo.v_R_System INNER JOIN
                      dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_VIDEO_CONTROLLER ON dbo.v_R_System.ResourceID = dbo.v_GS_VIDEO_CONTROLLER.ResourceID INNER JOIN
                      dbo.v_GS_SoftwareFile ON dbo.v_R_System.ResourceID = dbo.v_GS_SoftwareFile.ResourceID INNER JOIN
                      dbo.v_GS_Client0 ON dbo.v_R_System.ResourceID = dbo.v_GS_Client0.ResourceID
WHERE     (NOT (dbo.v_GS_VIDEO_CONTROLLER.Name0 LIKE '%configmgr%')) AND (NOT (dbo.v_GS_VIDEO_CONTROLLER.Name0 LIKE '%dameware%')) AND 
                      (NOT (dbo.v_GS_VIDEO_CONTROLLER.Name0 LIKE '%logmein%')) AND (NOT (dbo.v_GS_VIDEO_CONTROLLER.Name0 LIKE '%ca it%')) AND 
                      (NOT (dbo.v_GS_VIDEO_CONTROLLER.Name0 LIKE '%vmware%')) AND (NOT (dbo.v_GS_VIDEO_CONTROLLER.Name0 LIKE '%bomgar%')) AND 
                      (NOT (dbo.v_GS_VIDEO_CONTROLLER.Name0 LIKE '%vnc%')) AND (NOT (dbo.v_GS_VIDEO_CONTROLLER.Name0 LIKE '%smart technologies%'))  AND (NOT (dbo.v_GS_VIDEO_CONTROLLER.Name0 LIKE '%displaylink%')) AND 
                      (dbo.v_GS_SoftwareFile.FileName = 'CrmSqlStartupSvc.exe') AND (dbo.v_GS_SoftwareFile.FilePath LIKE 'c:\program files%microsoft dynamics crm\client\bin\')
                      and dbo.v_gs_client0.Version0 = 'thinkpad t410'
ORDER BY WKID