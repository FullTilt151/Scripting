SELECT     dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OS, dbo.v_GS_SoftwareFile.FileName, dbo.v_GS_SoftwareFile.FileVersion, Count (*) as Count
FROM         dbo.v_R_System INNER JOIN
                      dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_SoftwareFile ON dbo.v_R_System.ResourceID = dbo.v_GS_SoftwareFile.ResourceID INNER JOIN
                      dbo.v_R_User ON dbo.v_R_System.User_Name0 = dbo.v_R_User.User_Name0
GROUP BY dbo.v_GS_OPERATING_SYSTEM.Caption0, dbo.v_GS_SoftwareFile.FileName, dbo.v_GS_SoftwareFile.FileVersion, dbo.v_GS_SoftwareFile.FilePath
HAVING dbo.v_GS_SoftwareFile.FileName = 'iexplore.exe' and dbo.v_GS_OPERATING_SYSTEM.Caption0 != 'microsoft windows xp professional' and dbo.v_GS_OPERATING_SYSTEM.Caption0 != '' and dbo.v_GS_SoftwareFile.FilePath = 'c:\program files\internet explorer\'
order by OS,FileVersion