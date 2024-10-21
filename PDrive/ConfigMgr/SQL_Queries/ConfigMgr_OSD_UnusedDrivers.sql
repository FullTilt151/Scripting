SELECT     locCI.DisplayName AS DriverName, locCI.CI_ID, drivers.DriverClass, drivers.DriverProvider AS ProviderName, drivers.DriverVersion, 
                      CIs.IsEnabled AS DriverEnabled0
FROM         dbo.v_CI_DriversCIs AS drivers INNER JOIN
                      dbo.v_ConfigurationItems AS CIs ON CIs.CI_ID = drivers.CI_ID INNER JOIN
                      dbo.v_LocalizedCIProperties_SiteLoc AS locCI ON drivers.CI_ID = locCI.CI_ID
WHERE     (locCI.CI_ID NOT IN
                          (SELECT     CI_ID
                            FROM          dbo.v_DriverContentToPackage))