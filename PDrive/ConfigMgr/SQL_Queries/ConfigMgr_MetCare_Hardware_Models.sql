select v_gs_computer_system.Manufacturer0, v_GS_COMPUTER_SYSTEM.Model0, count(*)
from v_R_system full join
	 v_GS_COMPUTER_SYSTEM ON v_r_system.resourceid = v_GS_COMPUTER_SYSTEM.ResourceID
where Resource_Domain_OR_Workgr0 = 'CORP'
group by v_gs_computer_system.Manufacturer0, v_GS_COMPUTER_SYSTEM.Model0
order by count(*) desc