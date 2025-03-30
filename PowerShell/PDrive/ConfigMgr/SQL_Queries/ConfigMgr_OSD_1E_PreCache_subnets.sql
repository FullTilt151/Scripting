SELECT SYS.Netbios_Name0, LDISK.FreeSpace0 / 1024 AS FreeSpace, IPSUB.IP_Subnets0, SYS.Operating_System_Name_and0
FROM v_R_System AS SYS
JOIN v_GS_LOGICAL_DISK AS LDISK ON LDISK.ResourceID = SYS.ResourceID
JOIN v_RA_System_IPSubnets AS IPSUB ON IPSUB.ResourceID = SYS.ResourceID
WHERE IPSUB.IP_Subnets0 = '32.32.212.0'
AND LDISK.FreeSpace0 > 80000
AND SYS.Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1'
AND SYS.Netbios_Name0 LIKE 'WKM%'
--AND 
--SYS.ResourceID IN
--    (SELECT ResourceID FROM v_FullCollectionMembership
--    WHERE CollectionID = 'CAS00733')
--ORDER BY FreeSpace DESC
