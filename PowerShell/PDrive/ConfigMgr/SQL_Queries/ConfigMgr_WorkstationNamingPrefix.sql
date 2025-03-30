select LEFT(netbios_name0, 4) [Prefix], 
CASE 
	--Other
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 = 2 Then 'Laptop'
	When ChassisTypes0 = 3 Then 'Desktop'
	When ChassisTypes0 = 4 Then 'Desktop'
	--PizzaBox
	When ChassisTypes0 = 5 Then 'Laptop'
	--Mini-tower
	When ChassisTypes0 = 6 Then 'Desktop'
	--Tower
	When ChassisTypes0 = 7 Then 'Desktop'
	--Portable
	When ChassisTypes0 = 8 Then 'Laptop'
	When ChassisTypes0 = 9 Then 'Laptop'
	--Notebook
	When ChassisTypes0 = 10 Then 'Laptop'
	--Handheld Device
	When ChassisTypes0 = 11 Then 'Tablet'
	--Docking Station
	When ChassisTypes0 = 12 Then 'Laptop'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	--Space Saving
	When ChassisTypes0 = 15 Then 'Desktop'
	--Lunch box
	When ChassisTypes0 = 16 Then 'Laptop'
	--Main System Chassis
	When ChassisTypes0 = 17 Then 'Desktop'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	--Peripheral Chassis
	When ChassisTypes0 = 21 Then 'Desktop'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 31 Then 'Laptop'
	Else 'Unknown'
	End [Chassis Type],
	count(*) [Count]
from v_R_System_Valid sys join
	 v_GS_SYSTEM_ENCLOSURE SE on sys.ResourceID = se.ResourceID
where Is_Virtual_Machine0 = 0
group by LEFT(netbios_name0, 4), 
CASE 
	--Other
	When ChassisTypes0 = 1 Then 'VM'
	When ChassisTypes0 = 2 Then 'Laptop'
	When ChassisTypes0 = 3 Then 'Desktop'
	When ChassisTypes0 = 4 Then 'Desktop'
	--PizzaBox
	When ChassisTypes0 = 5 Then 'Laptop'
	--Mini-tower
	When ChassisTypes0 = 6 Then 'Desktop'
	--Tower
	When ChassisTypes0 = 7 Then 'Desktop'
	--Portable
	When ChassisTypes0 = 8 Then 'Laptop'
	When ChassisTypes0 = 9 Then 'Laptop'
	--Notebook
	When ChassisTypes0 = 10 Then 'Laptop'
	--Handheld Device
	When ChassisTypes0 = 11 Then 'Tablet'
	--Docking Station
	When ChassisTypes0 = 12 Then 'Laptop'
	When ChassisTypes0 = 13 Then 'All-In-One'
	When ChassisTypes0 = 14 Then 'Sub-Notebook'
	--Space Saving
	When ChassisTypes0 = 15 Then 'Desktop'
	--Lunch box
	When ChassisTypes0 = 16 Then 'Laptop'
	--Main System Chassis
	When ChassisTypes0 = 17 Then 'Desktop'
	When ChassisTypes0 = 18 Then 'Expansion Chassis'
	When ChassisTypes0 = 19 Then 'Sub-Chassis'
	When ChassisTypes0 = 20 Then 'Bus Expansion Chassis'
	--Peripheral Chassis
	When ChassisTypes0 = 21 Then 'Desktop'
	When ChassisTypes0 = 22 Then 'Storage Chassis'
	When ChassisTypes0 = 23 Then 'Rack-Mount Chassis'
	When ChassisTypes0 = 24 Then 'Sealed PC'
	When ChassisTypes0 = 31 Then 'Laptop'
	Else 'Unknown'
	End
order by LEFT(netbios_name0, 4)
