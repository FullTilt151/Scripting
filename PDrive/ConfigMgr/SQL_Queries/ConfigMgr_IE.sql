-- IE versions
SELECT  distinct    CASE SYS.Operating_System_Name_and0
					WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
					WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
					WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
					END as [OS], 
						 IE.Build0, IE.svcKBNumber0, 
					CASE 
					WHEN IE.Version0 LIKE '8%' THEN '8'
					WHEN IE.svcVersion0 LIKE '8%' THEN '8'
					WHEN IE.svcVersion0 LIKE '9%' THEN '9'
					WHEN IE.svcVersion0 LIKE '10%' THEN '10'
					WHEN IE.svcVersion0 LIKE '11%' THEN '11'
					ELSE 'Unknown'
					END AS [Major version],
                         IE.svcUpdateVersion0, IE.svcVersion0, IE.Version0, COUNT(*) AS Total
FROM            dbo.v_R_System SYS INNER JOIN
                         dbo.v_GS_InternetExplorer640 IE ON SYS.ResourceID = IE.ResourceID
GROUP BY CASE SYS.Operating_System_Name_and0
					WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
					WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
					WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
					END, SYS.Operating_System_Name_and0, IE.Build0, IE.svcKBNumber0, 
					CASE 
					WHEN IE.Version0 LIKE '8%' THEN '8'
					WHEN IE.svcVersion0 LIKE '8%' THEN '8'
					WHEN IE.svcVersion0 LIKE '9%' THEN '9'
					WHEN IE.svcVersion0 LIKE '10%' THEN '10'
					WHEN IE.svcVersion0 LIKE '11%' THEN '11'
					ELSE 'Unknown'
					END,
                         IE.svcUpdateVersion0, IE.svcVersion0, IE.Version0
HAVING Operating_System_Name_and0 like '%workstation%'
ORDER BY OS,svcUpdateVersion0, IE.svcVersion0 DESC