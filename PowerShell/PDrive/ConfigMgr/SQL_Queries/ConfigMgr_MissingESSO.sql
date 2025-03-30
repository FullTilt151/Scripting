--Total Win7
select distinct Netbios_Name0
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE ON sys.ResourceID = v_GS_INSTALLED_SOFTWARE.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1

--Missing ESSO
select distinct Netbios_Name0
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and netbios_name0 not in (select distinct Netbios_Name0
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and
		ARPDisplayName0 = 'isam esso accessagent')
order by Netbios_Name0

--Missing ESSO and image version
select distinct Netbios_Name0, Resource_Domain_OR_Workgr0 , ImageCreationDate0, ImageInstalled0, ImageVersion0 , TaskSequence0, Install_Date0, OSVersion0, CASE WHEN OSVersion0 LIKE 'W7%' THEN 'Ghost' WHEN OSVersion0 = '10.1' THEN 'Ghost' WHEN TaskSequence0 IS NOT NULL 
                         THEN 'OSD' WHEN OSVersion0 = '10092013' THEN 'OSD' WHEN OSVersion0 = '08302013' THEN 'OSD' WHEN OSVersion0 = '10152013' THEN 'OSD' WHEN OSVersion0 = '0114' THEN 'OSD' ELSE 'Unknown' END AS Method
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID LEFT JOIN
	v_GS_OSD640 OSD ON sys.ResourceID = OSD.ResourceID LEFT JOIN
	v_GS_SystemSoftware640 SS ON SYS.ResourceID = SS.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and netbios_name0 not in (select distinct Netbios_Name0
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and
		ARPDisplayName0 = 'isam esso accessagent')
order by Method, OSVersion0, TaskSequence0

--Count missing ESSO and image version
select distinct CASE WHEN OSVersion0 LIKE 'W7%' THEN 'Ghost' WHEN OSVersion0 = '10.1' THEN 'Ghost' WHEN TaskSequence0 IS NOT NULL 
                         THEN 'OSD' WHEN OSVersion0 = '10092013' THEN 'OSD' WHEN OSVersion0 = '08302013' THEN 'OSD' WHEN OSVersion0 = '10152013' THEN 'OSD' WHEN OSVersion0 = '0114' THEN 'OSD' ELSE 'Unknown' END AS Method, Count(distinct netbios_name0)
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID LEFT JOIN
	v_GS_OSD640 OSD ON sys.ResourceID = OSD.ResourceID LEFT JOIN
	v_GS_SystemSoftware640 SS ON SYS.ResourceID = SS.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and netbios_name0 not in (select distinct Netbios_Name0
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and
		ARPDisplayName0 = 'isam esso accessagent')
GROUP BY CASE WHEN OSVersion0 LIKE 'W7%' THEN 'Ghost' WHEN OSVersion0 = '10.1' THEN 'Ghost' WHEN TaskSequence0 IS NOT NULL 
                         THEN 'OSD' WHEN OSVersion0 = '10092013' THEN 'OSD' WHEN OSVersion0 = '08302013' THEN 'OSD' WHEN OSVersion0 = '10152013' THEN 'OSD' WHEN OSVersion0 = '0114' THEN 'OSD' ELSE 'Unknown' END

--Count missing ESSO and domain
select distinct Resource_Domain_OR_Workgr0, Count(distinct netbios_name0)
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID LEFT JOIN
	v_GS_OSD640 OSD ON sys.ResourceID = OSD.ResourceID LEFT JOIN
	v_GS_SystemSoftware640 SS ON SYS.ResourceID = SS.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and netbios_name0 not in (select distinct Netbios_Name0
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and
		ARPDisplayName0 = 'isam esso accessagent')
GROUP BY Resource_Domain_OR_Workgr0

--List with ESSO
select distinct Netbios_Name0
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and
		ARPDisplayName0 = 'isam esso accessagent'

--Count with ESSO
select distinct ProductVersion0, Count(*)
from v_r_system SYS INNER JOIN
	v_GS_INSTALLED_SOFTWARE SFT ON SYS.ResourceID = SFT.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' and
		client0 = 1 and
		ARPDisplayName0 = 'isam esso accessagent'
group by ProductVersion0