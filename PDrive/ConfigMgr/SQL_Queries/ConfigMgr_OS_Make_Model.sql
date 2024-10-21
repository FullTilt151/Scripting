SELECT     dbo.v_R_System.netbios_name0 [WKID], 
		   CASE dbo.v_R_System.Operating_System_Name_and0
		   WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		   WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
		   WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
		   WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
		   WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		   end [OS],
		   CSP.Vendor0 AS [Vendor], CSP.Version0 AS [Model_Name], 
                      CSP.Name0 AS [Model_Number],  
            CASE SE.ChassisTypes0
		When 1 Then 'VM'
			When 2 Then 'Unknown'
			When 3 Then 'Desktop'
			When 4 Then 'Desktop'
			When 5 Then 'Laptop'
			When 6 Then 'Desktop'
			When 7 Then 'Desktop'
			When 8 Then 'Laptop'
			When 9 Then 'Laptop'
			When 10 Then 'Laptop'
			When 11 Then 'Handheld Device'
			When 12 Then 'Laptop'
			When 13 Then 'All-In-One'
			When 14 Then 'Sub-Notebook'
			When 15 Then 'Desktop'
			When 16 Then 'Laptop'
			When 17 Then 'Desktop'
			When 18 Then 'Expansion Chassis'
			When 19 Then 'Sub-Chassis'
			When 20 Then 'Bus Expansion Chassis'
			When 21 Then 'Desktop'
			When 22 Then 'Storage Chassis'
			When 23 Then 'Rack-Mount Chassis'
			When 24 Then 'Sealed PC'
			Else 'Unknown'
			End [Chassis]
FROM         dbo.v_R_System LEFT JOIN
                      dbo.v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON dbo.v_R_System.ResourceID = CSP.ResourceID INNER JOIN
                      v_GS_SYSTEM_ENCLOSURE SE ON dbo.v_R_System.ResourceID = SE.ResourceID
WHERE dbo.v_R_System.Operating_System_Name_and0 like '%workstation%'
ORDER BY [WKID], [Model_Name], [Model_Number]