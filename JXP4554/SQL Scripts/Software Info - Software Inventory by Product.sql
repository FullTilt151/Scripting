SELECT DISTINCT STM.netbios_name0 [WKID],
	OS.displayname [OS],
	ARP.ProductName0 [Product Name],
	ARP.Publisher0 [Vendor],
	ARP.ProductVersion0 [Version],
	ARP.InstallDate0 [Install Date]
FROM v_GS_INSTALLED_SOFTWARE ARP
INNER JOIN v_r_system_valid STM ON STM.resourceid = ARP.resourceid
JOIN humana_os_caption_displayname OS ON stm.operating_system_name_and0 = OS.caption
WHERE ARP.ProductName0 IN (@Product)
ORDER BY wkid,
	[Install Date]

SELECT DISTINCT ProductName0
FROM v_GS_INSTALLED_SOFTWARE
WHERE ProductName0 LIKE '%Reader%'
ORDER BY ProductName0

SELECT DISTINCT STM.Netbios_Name0 [WKID],
	STW.ProductName0 [Product],
	STW.ProductVersion0 [Version],
	STW.Publisher0 [Manufacturer]
FROM v_GS_INSTALLED_SOFTWARE STW
JOIN v_R_System stm ON STW.ResourceID = STM.ResourceID
JOIN v_FullCollectionMembership FCM ON STM.ResourceID = FCM.ResourceID
WHERE FCM.CollectionID = 'WQ1009A3'
	AND (
		STW.ProductName0 LIKE 'Adobe%'
		OR STW.ProductName0 LIKE '7-Zip%'
		)
ORDER BY WKID,
	Product

SELECT *
FROM v_UpdateInfo
WHERE IsExpired = 1
	OR IsTombstoned = 1

/* 
UPDATE v_UpdateInfo
SET IsTombstoned = 1
WHERE IsExpired = 1
 */

 Select distinct ProductName0
 from v_GS_INSTALLED_SOFTWARE
 where ProductName0 like '%office%2016%'
order by ProductName0
