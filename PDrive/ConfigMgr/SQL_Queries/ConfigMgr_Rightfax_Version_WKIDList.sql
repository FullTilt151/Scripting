SELECT     dbo.v_R_System.Name0 as WKID, dbo.v_R_System.User_Name0 as [User], dbo.v_R_User.Full_User_Name0 as [Display Name], dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OS, 
                      dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 AS Product, dbo.v_GS_INSTALLED_SOFTWARE.ProductVersion0 AS [Product Version]
                      
FROM         dbo.v_R_System INNER JOIN
                      dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_INSTALLED_SOFTWARE ON dbo.v_R_System.ResourceID = dbo.v_GS_INSTALLED_SOFTWARE.ResourceID INNER JOIN
                      dbo.v_R_User ON dbo.v_R_System.User_Name0 = dbo.v_R_User.User_Name0
WHERE     ((dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 = 'Rightfax Product Suite - Client') OR
                      (dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 = 'Rightfax Product Suite') OR
                      (dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 = 'Rightfax Client Applications'))
ORDER BY WKID