-- 1709 PresentationCore.dll vuln
select CASE 
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
	End [Chassis Type], FileVersion, count(*)
from v_R_System sys join
	 v_gs_softwarefile sf on sys.ResourceID = sf.ResourceID join
	 v_GS_SYSTEM_ENCLOSURE se on sys.resourceid = se.ResourceID
where filename = 'presentationcore.dll' and build01 = '10.0.16299'
	  and FileVersion = '3.0.6920.8693 built by: QFE'
group by CASE 
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
	End, FileVersion
order by [Chassis Type], fileversion