SELECT
 dbo.v_R_System.Name0,
 sw.Name AS [MW Name],
 sw.Description,
 sw.Duration AS 'Duration Minutes',
 sw.IsEnabled AS 'MW Enabled',
 dbo.v_R_System.Operating_System_Name_and0
 FROM
 dbo.v_ServiceWindow AS sw INNER JOIN
 dbo.v_FullCollectionMembership AS fcm 
 ON sw.CollectionID = fcm.CollectionID 
 INNER JOIN dbo.v_R_System
 ON fcm.ResourceID = dbo.v_R_System.ResourceID
 where v_R_System.Name0 = 'COMPUTERNAME'
 ORDER BY [MW Name], dbo.v_R_System.Name0