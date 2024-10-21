SELECT distinct    tsinfo.ReferencePackageID AS 'Package ID', tsinfo.ReferenceName AS 'Package Name', tsinfo.ReferenceVersion, tsinfo.ReferenceProgramName, 
                      pkg.SourceVersion AS 'Source Version', NomadPkgs.Version0 AS 'Cached Version', 
                      case
					  when pkg.SourceVersion = Nomadpkgs.Version0 then 'X'
                      END as 'Cached',
                      CAST(NomadPkgs.DiskUsageKB0 / 1024.0E AS DECIMAL(10, 2)) as 'Size in MB', NomadPkgs.Percent0 AS '% Cached', NomadPkgs.ReturnCode0 AS [Return Code], NomadPkgs.ReturnStatus0 AS Status
FROM         dbo.v_TaskSequenceReferencesInfo AS tsinfo LEFT OUTER JOIN
                      dbo.v_GS__E_Nomad_Packages0 AS NomadPkgs ON NomadPkgs.PackageID0 = tsinfo.ReferencePackageID AND NomadPkgs.ResourceID = '16777317' INNER JOIN
                      dbo.v_Package AS pkg ON tsinfo.ReferencePackageID = pkg.PackageID
ORDER BY '% Cached'