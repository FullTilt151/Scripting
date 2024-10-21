-- Count of OS by chassis type
select CASE 
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1' Then 'Windows XP'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' Then 'Windows 7'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' Then 'Windows 7'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.2' Then 'Windows 8'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' Then 'Windows 8'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.3' Then 'Windows 8.1'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' Then 'Windows 8.1'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 10.0' Then 'Windows 10'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' Then 'Windows 10'
	   End [OS], 
	CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21,35) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else 'Unknown'
	End [Chassis Type],
	Count (sys.ResourceID) [Count]
from v_R_System_valid sys INNER JOIN
	v_GS_SYSTEM_ENCLOSURE SE ON sys.ResourceID = SE.ResourceID
where Operating_System_Name_and0 like '%Workstation%'
group by CASE 
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1' Then 'Windows XP'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' Then 'Windows 7'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' Then 'Windows 7'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.2' Then 'Windows 8'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' Then 'Windows 8'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.3' Then 'Windows 8.1'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' Then 'Windows 8.1'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 10.0' Then 'Windows 10'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' Then 'Windows 10'
	   End, 
		CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21,35) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else 'Unknown' 
	End
order by os desc, [Chassis Type]

-- OS build by chassis type
select sys.build01,
	   	CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21,35) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else 'Unknown'
	End [Chassis Type],
	Count (sys.ResourceID) [Count]
from v_R_System sys INNER JOIN
	v_GS_SYSTEM_ENCLOSURE SE ON sys.ResourceID = SE.ResourceID
where Operating_System_Name_and0 like '%Workstation%' and sys.Resource_Domain_OR_Workgr0 = 'HUMAD'
group by sys.Build01, 
		CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21,35) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else 'Unknown' 
	End
order by build01 desc, [Chassis Type]

-- Chassis info for a WKID
select Netbios_Name0, sys.Resource_Domain_OR_Workgr0, AD_Site_Name0, se.ChassisTypes0, csp.Vendor0, csp.Version0, csp.Name0
from v_r_system_valid sys join
	 v_gs_system_enclosure se on sys.resourceid = se.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID
where se.ChassisTypes0 = '23'

-- List of unknown chassis types
select sys.netbios_name0,  se.chassistypes0,
		CASE 
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1' Then 'Windows XP'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' Then 'Windows 7'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' Then 'Windows 7'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.2' Then 'Windows 8'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' Then 'Windows 8'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.3' Then 'Windows 8.1'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' Then 'Windows 8.1'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 10.0' Then 'Windows 10'
	   When Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' Then 'Windows 10'
	   End [OS], 
	CASE 
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 in (2,5,8,9,10,12,16,31) Then 'Laptop'
	When ChassisTypes0 in (3,4,6,7,15,17,21) Then 'Desktop'
	When ChassisTypes0 = 11 Then 'Tablet'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 32 Then 'Tablet'
	Else 'Unknown'
	End [Chassis Type], csp.Version0, csp.name0
from v_R_System_valid sys INNER JOIN
	v_GS_SYSTEM_ENCLOSURE SE ON sys.ResourceID = SE.ResourceID left join
	v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID
where Operating_System_Name_and0 like '%Workstation%' and ChassisTypes0 not in (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,31,32)