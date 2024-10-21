-- Count of machines built by PXE box
select  case
		WHEN PXE0 IS NULL THEN 'Unknown'
		else PXE0
		end as [PXE], 
		Count(*) [Total]
from v_gs_osd640
group by PXE0
order by PXE

-- List of WKIDs by PXE box
select OSD.PXE0 [PXE], sys.Netbios_Name0 [WKID], osd.DeployedBy0 [Deployed By], CAST(osd.ImageInstalled0 as datetime) [Installed], osd.TaskSequence0 [Task Sequence], osd.SMSTSRole0 [Build]
from v_r_system SYS join
	 v_GS_OSD640 OSD ON sys.resourceid = osd.resourceid
WHERE PXE0 IS NOT NULL
order by Installed DESC

-- List of PXE boxes
select netbios_name0 [WKID]
from v_r_system
where Netbios_Name0 like '%pxewpw%' and Client0 = '1'
order by WKID