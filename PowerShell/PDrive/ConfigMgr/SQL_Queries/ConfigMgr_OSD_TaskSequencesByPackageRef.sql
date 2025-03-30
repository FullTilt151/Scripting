SELECT        TS.PackageID [TS ID], TS.Name [TS Name], TSRef.RefPackageID [Pkg ID], Pkg.Manufacturer [Pkg Mfg], Pkg.Name AS [Pkg Name], Pkg.Version [Pkg Version]
FROM            dbo.v_TaskSequencePackageReferences AS TSRef INNER JOIN
                         dbo.v_TaskSequencePackage AS TS ON TSRef.PackageID = TS.PackageID INNER JOIN
                         dbo.v_Package AS Pkg ON TSRef.RefPackageID = Pkg.PackageID
ORDER BY TS.Name, Pkg.Manufacturer, Pkg.Name

select PackageID, PackageID + ' - ' + Manufacturer + ' ' + Name + ' ' + Version [Package Name]
from v_Package
order by PackageID