select distinct DisplayName0, Version0, count(*)
from v_r_system sys join
	 v_add_remove_programs arp on sys.ResourceID = arp.ResourceID
where displayname0 = 'Microsoft Office Professional Plus 2010' and
	  ProdID0 = '{90140000-0011-0000-0000-0000000FF1CE}' and
	  sys.Client0 = 1 and
	  sys.Is_Virtual_Machine0 = 0 and
	  (sys.Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' or
	  sys.Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)')
group by DisplayName0, Version0


select HotFixID0, count(*)
from v_r_system sys join
	 v_GS_QUICK_FIX_ENGINEERING qfe on sys.ResourceID = qfe.ResourceID
where HotFixID0 = 'KB2687455' and
	  sys.Client0 = 1 and
	  sys.Is_Virtual_Machine0 = 0 and
	  (sys.Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' or
	  sys.Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)')
group by HotFixID0
order by HotFixID0

