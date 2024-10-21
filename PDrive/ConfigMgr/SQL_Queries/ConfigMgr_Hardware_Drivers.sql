SELECT        DriverProvider [Mfg], Modelname [Driver], CICI.SourceSite, HWID.HardwareID, DriverINFFile, DriverVersion, DriverDate, ContentSourcePath, 
		      DP.PackageID, DP.Name, DP.SourceVersion, DP.SourceDate, DP.PkgSourcePath
FROM            dbo.v_CI_DriverModels AS CIDM INNER JOIN
                         dbo.vCI_ConfigurationItems AS CICI ON CIDM.CI_UniqueID = CICI.CI_UniqueID INNER JOIN
                         dbo.v_CI_DriversCIs AS CIDCI ON CIDM.CI_UniqueID = CIDCI.CI_UniqueID INNER JOIN
						 dbo.v_CI_DriverHardwareIDs HWID ON CIDM.CI_UniqueID = HWID.CI_UniqueID INNER JOIN
						 dbo.v_DriverContentToPackage DCTP ON CIDM.CI_ID = DCTP.CI_ID LEFT JOIN
						 dbo.v_DriverPackage DP ON DCTP.PkgID = DP.PackageID
ORDER BY CIDM.ManufacturerName, CIDM.ModelName