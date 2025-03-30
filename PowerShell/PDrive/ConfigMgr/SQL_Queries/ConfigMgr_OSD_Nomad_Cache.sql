IF OBJECT_ID('v_GS__E_NomadPackages0', 'V') IS NOT NULL /* Testing for the view name as it exist on CM12 */
BEGIN 

( 
SELECT DISTINCT    v_Package.Name AS Name, CAST((CAST(nomad.BytesFromDP0 as float)/1048576) as decimal(9,2)) AS [MB From DP], 
                      CAST((CAST(nomad.BytesFromPeer0  as float)/1048576) as decimal(9,2)) AS [MB From Peer], 
                      CAST((CAST(nomad.AlreadyCached0  as bigint)/1048576) as decimal(9,2)) AS [MB Already Cached],
                      CONVERT(nvarchar, dateadd(s, CAST(nomad.BackOffSeconds0 as bigint), 0),108) AS [Back Off Time], 
                      CONVERT(nvarchar, dateadd(s, CAST(nomad.DisconnectedSeconds0 as bigint), 0),108) AS [Disconnected Time],
                      CONVERT(nvarchar, dateadd(s, CAST(nomad.CachingSeconds0 as bigint), 0),108) AS [Caching Time],
                      CONVERT(nvarchar, dateadd(s, CAST(nomad.ElapsedSeconds0 as bigint), 0),108) AS [Elapsed Time],
                      nomad.Percent0 AS [Percent], nomad.ReturnStatus0 AS [Return Status],
                      nomad.OptInfo0 AS [Optional Info], nomad.Version0 AS [Version]
FROM         v_GS__E_NomadPackages0 nomad INNER JOIN
                       v_Package ON nomad.PackageID0 = v_Package.PackageID INNER JOIN v_GS_SYSTEM ON nomad.ResourceID = v_GS_SYSTEM.ResourceID
WHERE                 v_Package.PackageType != 8 AND v_Package.PackageType != 4 
                                AND       (v_GS_SYSTEM.Name0 = 'CITPXEWPW01')
)
Union
(
SELECT DISTINCT    v_LocalizedCIProperties.DisplayName AS Name, CAST(CAST(nomad.BytesFromDP0 as bigint)/1048576 as decimal(9,2)) AS [MB From DP], 
                      CAST((CAST(nomad.BytesFromPeer0 as bigint)/1048576) as decimal(9,2)) AS [MB From Peer], 
                      CAST((CAST(nomad.AlreadyCached0 as bigint)/1048576) as decimal(9,2)) AS [MB Already Cached],
                      CONVERT(nvarchar, dateadd(s, CAST(nomad.BackOffSeconds0 as bigint), 0),108) AS [Back Off Time], 
                      CONVERT(nvarchar, dateadd(s, CAST(nomad.DisconnectedSeconds0 as bigint), 0),108) AS [Disconnected Time],
                      CONVERT(nvarchar, dateadd(s, CAST(nomad.CachingSeconds0 as bigint), 0),108) AS [Caching Time],
                      CONVERT(nvarchar, dateadd(s, CAST(nomad.ElapsedSeconds0 as bigint), 0),108) AS [Elapsed Time],
                      nomad.Percent0 AS [Percent], nomad.ReturnStatus0 AS [Return Status],
                      nomad.OptInfo0 AS [Optional Info], nomad.Version0 AS [Version]
FROM         v_GS__E_NomadPackages0 nomad INNER JOIN
                      v_CIToContent ON nomad.PackageID0 = v_CIToContent.Content_UniqueID INNER JOIN
                      v_LocalizedCIProperties ON v_CIToContent.CI_ID = v_LocalizedCIProperties.CI_ID INNER JOIN v_GS_SYSTEM ON nomad.ResourceID = v_GS_SYSTEM.ResourceID
WHERE     (v_GS_SYSTEM.Name0 = 'CITPXEWPW01')
)

END