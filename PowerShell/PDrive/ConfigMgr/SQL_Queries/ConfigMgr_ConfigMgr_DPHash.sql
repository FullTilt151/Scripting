SELECT DISTINCT [PkgID], [ContentId],ContentDPMap.Version, [URL], [ServerName], [NewHash]
FROM ContentDPMap
INNER JOIN SMSPackages ON ContentDPMap.ContentID = SMSPackages.PkgID
WHERE AccessType = 1
and PackageType not in (5,8) 
AND ContentID = 'WQ100547' --or ContentID = 'CAS00FBE'

SELECT DISTINCT [PkgID], ContentDPMap.Version, [NewHash]
FROM ContentDPMap
INNER JOIN SMSPackages ON ContentDPMap.ContentID = SMSPackages.PkgID
WHERE AccessType = 1
and PackageType not in (5,8) 
AND ContentID = 'WQ100547' --or ContentID = 'CAS00FBE'