
SELECT     dbo.v_GS_OPERATING_SYSTEM.Caption0 as OS, dbo.v_GS_SoftwareFile.FileName, dbo.v_GS_SoftwareFile.FileVersion,case
                      when FileVersion = '9.0.21022.8' then 'Base'
                      when FileVersion = '9.0.30729.1' then 'Base + SP1'
                      when FileVersion >= '9.0.30729.4413' then 'Base + SP1 + FCU'
                      end as 'Patch Level' ,dbo.v_GS_SoftwareFile.FilePath, COUNT(dbo.v_R_System.Netbios_Name0) AS Count
FROM         dbo.v_R_System INNER JOIN
                      dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_SoftwareFile ON dbo.v_R_System.ResourceID = dbo.v_GS_SoftwareFile.ResourceID
WHERE     (dbo.v_R_System.Obsolete0 = 0)
GROUP BY dbo.v_GS_OPERATING_SYSTEM.Caption0, dbo.v_GS_SoftwareFile.FileName, dbo.v_GS_SoftwareFile.FileVersion, dbo.v_GS_SoftwareFile.FilePath
HAVING      (dbo.v_GS_SoftwareFile.FileName = 'Microsoft.VisualStudio.TeamFoundation.TeamExplorer.dll') AND 
                      ((dbo.v_GS_SoftwareFile.FilePath LIKE 'c:\program files\microsoft%visual studio%') OR (dbo.v_GS_SoftwareFile.FilePath LIKE 'c:\program files (x86)\microsoft%visual studio%')) AND (dbo.v_GS_SoftwareFile.FileVersion LIKE '9%')
ORDER BY OS DESC, [Patch Level]



					  case
                      when FileVersion = '8.0.50727.147' then 'Base'
                      when FileVersion = '8.0.50727.762' then 'SP1 Only'
                      when FileVersion = '8.0.50727.4430' then 'SP1 + FCU'
                      end as 'Patch Level'
                      
                      case
                      when FileVersion = '9.0.21022.8' then 'Base'
                      when FileVersion = '9.0.30729.1' then 'Base + SP1'
                      when FileVersion >= '9.0.30729.4413' then 'Base + SP1 + FCU'
                      end as 'Patch Level'