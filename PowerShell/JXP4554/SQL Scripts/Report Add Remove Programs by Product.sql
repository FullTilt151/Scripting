DECLARE @ProductFilter VARCHAR(255)
DECLARE @Product VARCHAR(255)

SET @ProductFilter = 'tableau software'
SET @Product = 'Tableau Software?????? Tableau 2018.1 (20181.18.0510.1418)'

SELECT DISTINCT cast(Publisher0 + ' ' + DisplayName0 AS VARCHAR(255)) [Product],
	cast(Publisher0 AS VARCHAR(255)) [Publisher0],
	cast(DisplayName0 AS VARCHAR(255)) [DisplayName0]
FROM v_r_system_valid sys
LEFT JOIN v_Add_Remove_Programs ARP ON sys.ResourceID = arp.ResourceID
WHERE DisplayName0 LIKE '%' + @ProductFilter + '%'
ORDER BY [Product]

SELECT DISTINCT STM.Netbios_Name0 AS WKID,
	OS.DisplayName [OS],
	cast(ARP.DisplayName0 AS VARCHAR(255)) AS [Add/Remove Name],
	cast(ARP.Publisher0 AS VARCHAR(255)) AS Vendor,
	ARP.ProdID0 AS Product,
	cast(ARP.Version0 AS VARCHAR(255)) AS Version
FROM v_ADD_REMOVE_PROGRAMS ARP
INNER JOIN v_R_System_valid STM ON STM.ResourceID = ARP.ResourceID
JOIN Humana_os_caption_displayname OS ON stm.Operating_System_Name_and0 = OS.Caption
WHERE ARP.DisplayName0 IN (@Product)
ORDER BY WKID
