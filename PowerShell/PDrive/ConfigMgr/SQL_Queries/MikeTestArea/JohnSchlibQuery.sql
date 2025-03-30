DROP TABLE #AIData;
Declare @Product varchar(255)
Declare @Vendor varchar(255)
set @Product = 'Incopy'
set @Vendor = 'Adobe';

SELECT     ResourceID, v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedPublisher,
           v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName,
           v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedVersion,
           v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ProductVersion0,
           v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstallType0,
           v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstallSource0,
           v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstalledLocation0 
                    
                            
INTO            [#AIData]
FROM         dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED
WHERE     (dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName LIKE '%' + @Product + '%'
          AND dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedPublisher LIKE '%' + @Vendor + '%')

SELECT      SYS.Netbios_Name0 AS WKID,
             USERS.User_Name0 AS [User ID],
        USERS.Full_User_Name0 AS [User Name],
        SYS.AD_Site_Name0 AS [Site Name],
        AID.NormalizedPublisher AS [Vendor Name],
        AID.NormalizedName AS [Product Name],
        AID.NormalizedVersion AS [Product Version],
        AID.InstallType0 AS [Install Type],
        AID.InstallSource0,
        AID.InstalledLocation0,
        sys.Operating_System_Name_and0 AS [OS],
             SYS.Client0 as [Client],
        SYS.Active0 as [Active]     
             
        
FROM         [#AIData] AS AID 
                  INNER JOIN dbo.v_R_System SYS ON aid.ResourceID = SYS.ResourceID
                  Left outer JOIN dbo.v_R_User AS USERS ON SYS.User_Name0 = USERS.User_Name0
                  Where SYS.Obsolete0 = 0 AND SYS.Decommissioned0 = 0 
ORDER BY  [wkid] ASC, [Product Name] ASC, [Product Version] ASC


/* PART TWO */
SELECT      count(DISTINCT SYS.Netbios_Name0) AS WKID_TOTAL,
        AID.NormalizedName AS [Normalized Name], AID.NormalizedVersion, sys.Operating_System_Name_and0 AS [OS]
FROM         [#AIData] AS AID 
                  INNER JOIN dbo.v_R_System SYS ON aid.ResourceID = SYS.ResourceID
Where SYS.Obsolete0 = 0 AND SYS.Decommissioned0 = 0
GROUP BY  AID.NormalizedName, AID.NormalizedVersion,sys.Operating_System_Name_and0 
order by AID.NormalizedName Desc, sys.Operating_System_Name_and0 desc




