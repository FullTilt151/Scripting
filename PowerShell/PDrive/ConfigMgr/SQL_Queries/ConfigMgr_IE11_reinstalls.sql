select distinct sys.Netbios_Name0, ienew.svcUpdateVersion0, ieold.svcUpdateVersion0
from v_R_System SYS left join
	 v_GS_InternetExplorer640 IEnew on sys.ResourceID = IEnew.ResourceID left join
	 v_HS_InternetExplorer640 IEold on sys.ResourceID = IEold.ResourceID
where ieold.svcUpdateVersion0 like '11%' and
	  ienew.svcUpdateVersion0 like '9%' and
	  sys.Operating_System_Name_and0 in (
	   'Microsoft Windows NT Workstation 6.1',
	   'Microsoft Windows NT Workstation 6.1 (Tablet Edition)'
	  ) and sys.Client0 = 1