select AD_Site_Name0, COUNT(*)
from v_r_system
where Full_Domain_Name0 = 'HUMAD.COM' and Operating_System_Name_and0 like '%workstation 6.1%'
group by AD_Site_Name0
HAVING Count(*) > 5
order by count(*) desc

select netbios_name0 WKID, AD_Site_Name0 [AD Site], OS.Caption0 [OS], CSDVersion0 [SP], 
		CASE ChassisTypes0
		WHEN '3' THEN 'Desktop'
		WHEN '10' THEN 'Laptop'
		END AS Chassis
from v_R_System SYS INNER JOIN
	 v_gs_operating_system OS ON SYS.ResourceID = OS.ResourceID INNER JOIN
	 v_GS_SYSTEM_ENCLOSURE SE ON SYS.ResourceID = SE.ResourceID
where Full_Domain_Name0 = 'HUMAD.COM' and Operating_System_Name_and0 like '%workstation 6.1%' and
	  (netbios_name0 = 'WKMJ58PB1' or
	  Netbios_Name0 = 'WKPB6HZV9' or
	  Netbios_Name0 = 'WKMJ00GRWR' or
	  Netbios_Name0 = 'WKPBKNEY0' or
	  Netbios_Name0 = 'TRMJYZENL' or
	  Netbios_Name0 = 'WKMJHCXL1' or
	  Netbios_Name0 = 'TRMJFFZB5' or
	  Netbios_Name0 = 'WKMJLNTPL' or
	  Netbios_Name0 = 'WKMJ01BUQ9' or
	  Netbios_Name0 = 'WKPBETD59' or
	  Netbios_Name0 = 'WKMJ11M2Z' or
	  Netbios_Name0 = 'WKPB7NP77' or
	  Netbios_Name0 = 'WK7BSSHK1' or
	  Netbios_Name0 = 'WKPB26WPT' or
	  Netbios_Name0 = 'WKMJ18CZT' or
	  Netbios_Name0 = 'WKPB9T15N' or
	  Netbios_Name0 = 'WKPBAWNX2' or
	  Netbios_Name0 = 'WKMJ20TLH' or
	  Netbios_Name0 = 'WKMJ25R6H' or
	  Netbios_Name0 = 'WKMJVKFFV'
	  )
order by [AD Site], WKID