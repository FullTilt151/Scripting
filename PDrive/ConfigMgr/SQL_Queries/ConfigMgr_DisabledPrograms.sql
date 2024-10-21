SELECT     dbo.v_Package.PackageID AS Package, dbo.v_Package.Manufacturer, dbo.v_Package.Name, dbo.v_Package.Version, dbo.v_Program.ProgramName, 
                      dbo.v_Program.CommandLine, dbo.v_Program.Comment, dbo.v_Program.Description, 
                      dbo.v_Program.ProgramFlags
FROM         dbo.v_Program INNER JOIN
                      dbo.v_Package ON dbo.v_Program.PackageID = dbo.v_Package.PackageID
where (0x00001000 & dbo.v_Program.ProgramFlags)/0x00001000 = 1
order by Manufacturer