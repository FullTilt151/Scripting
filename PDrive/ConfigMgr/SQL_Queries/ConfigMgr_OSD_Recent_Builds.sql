select sys.netbios_name0, sys.Creation_Date0, ws.LastHWScan, osd.DeployedBy0, osd.ImageCreationDate0, osd.ImageInstalled0, osd.SMSTSRole0, osd.PXE0, osd.TaskSequence0
from v_r_system sys left join	
	 v_gs_osd640 OSD on sys.resourceid = osd.resourceid left join
	 v_GS_WORKSTATION_STATUS WS on sys.resourceid = ws.ResourceID
where sys.Client0 = 1 and
	  DATEDIFF(d, sys.Creation_Date0, getdate()) < 1 and
	  sys.Operating_System_Name_and0 like '%workstation%'
order by sys.Creation_Date0 DESC