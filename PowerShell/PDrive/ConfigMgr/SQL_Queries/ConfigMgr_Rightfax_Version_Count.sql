SELECT     dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OS, 
                      dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 as Product, dbo.v_GS_INSTALLED_SOFTWARE.ProductVersion0 as [Product Version], Count(*) as Count
FROM         dbo.v_R_System INNER JOIN
                      dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_INSTALLED_SOFTWARE ON dbo.v_R_System.ResourceID = dbo.v_GS_INSTALLED_SOFTWARE.ResourceID
GROUP BY dbo.v_GS_OPERATING_SYSTEM.Caption0, dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0, 
                      dbo.v_GS_INSTALLED_SOFTWARE.ProductVersion0
HAVING      ((dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 = 'Rightfax Product Suite - Client') or (dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 = 'Rightfax Product Suite') or (dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 = 'Rightfax Client Applications'))
ORDER BY OS, ARPDisplayName0, ProductVersion0