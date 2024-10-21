SELECT STM.netbios_name0,
	NAC.IPAddress0,
	NAC.IPSubnet0
FROM v_R_System STM
JOIN v_GS_NETWORK_ADAPTER_CONFIGURATION NAC ON STM.ResourceID = NAC.ResourceID
JOIN v_FullCollectionMembership FCM ON STM.ResourceID = FCM.ResourceID
WHERE IPAddress0 IS NOT NULL
	AND FCM.CollectionID = (
		SELECT SiteID
		FROM v_Collections
		WHERE CollectionName LIKE 'SCCM Site System'
		)
ORDER BY Netbios_Name0
