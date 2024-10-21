-- List of machines with WAH Utility
select sys.Netbios_Name0 [Name], wah.version0 [WAH Utility Version], wah.Installed0 [Installed]
from v_R_System SYS join
	v_gs_wahutility0 WAH on sys.ResourceID = wah.resourceid
where sys.Client0 = 1 and
	  wah.version0 is not null

-- Count of machines with WAH Utility
select wah.version0 [WAH Utility Version], count(*) [Total]
from v_R_System SYS join
	v_gs_wahutility0 WAH on sys.ResourceID = wah.resourceid
where sys.Client0 = 1 and
	  wah.version0 is not null
group by wah.version0