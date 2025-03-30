select netbios_name0 [Name], 
		case Operating_System_Name_and0 
		when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
		end [OS], os.InstallDate0, ie.svcVersion0 [IE], osd.DeployedBy0, osd.ImageInstalled0, osd.ImageName0, osd.ImageRelease0, osd.SMSTSRole0, osd.TaskSequence0
from v_r_system sys left join
	 v_gs_operating_system OS on sys.resourceid = os.resourceid left join
	 v_GS_InternetExplorer640 IE on sys.ResourceID = ie.ResourceID left join
	 v_GS_OSD640 OSD on sys.ResourceID = osd.ResourceID
where ie.svcVersion0 not in (select distinct svcversion0
from v_gs_internetexplorer640
where svcVersion0 like '11%') and
	  Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 6.1','Microsoft Windows NT Workstation 6.1 (Tablet Edition)') and
	  os.InstallDate0 > datediff(DAY,30,getdate())
order by os.InstallDate0 desc