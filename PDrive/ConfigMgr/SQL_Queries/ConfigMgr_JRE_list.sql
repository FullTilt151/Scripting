SELECT     distinct
           dbo.v_R_System.Name0 as WKID, 
           dbo.v_R_System.User_Name0 as [User], 
           dbo.v_R_User.Full_User_Name0 as [Display Name], 
           dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OS, 
--           dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 AS Product, 
           dbo.v_GS_INSTALLED_SOFTWARE.ProductVersion0 AS [Product Version]
                      
FROM       dbo.v_R_System INNER JOIN
               dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
               dbo.v_GS_INSTALLED_SOFTWARE ON dbo.v_R_System.ResourceID = dbo.v_GS_INSTALLED_SOFTWARE.ResourceID INNER JOIN
               dbo.v_R_User ON dbo.v_R_System.User_Name0 = dbo.v_R_User.User_Name0

WHERE     
(dbo.v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 like '%java%' and 						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%development%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%jdk%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%java db%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%auto%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%javafx%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%jrockit%' and            						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%core%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%crystal%'  and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%tool%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%visual%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%vmware%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%profiler%' and 						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%decompiler%' and  						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%cvom%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%HDF%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%IBM%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%agent%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%bmc%' and 						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%preparation%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%auto%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%sdk%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%javaapm%' and						
v_GS_INSTALLED_SOFTWARE.ARPDisplayName0 not like '%wiseman%')   	
ORDER BY WKID