select DisplayName0, count(*)
from v_r_system SYS join
	 v_add_remove_programs arp on sys.resourceid = arp.ResourceID join
	 v_CH_ClientSummary CS on sys.ResourceID = cs.ResourceID
where sys.Client0 = 1 and sys.Operating_System_Name_and0 like '%workstation%' and
arp.displayname0 = 'Impact 360 Desktop Applications' and cs.LastActiveTime > DATEADD(day, -15, getdate())
group by DisplayName0