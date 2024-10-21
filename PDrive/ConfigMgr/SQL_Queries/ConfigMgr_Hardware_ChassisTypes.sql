select se.Manufacturer0, cs.Model0 , csp.Version0, ChassisTypes0, count(*) [Count]
from v_gs_system_enclosure se join
	 v_GS_COMPUTER_SYSTEM cs on se.ResourceID = cs.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on se.ResourceID = csp.ResourceID
where ChassisTypes0 in (10,12,8)
group by se.Manufacturer0, cs.Model0 , csp.Version0, ChassisTypes0
order by ChassisTypes0, Manufacturer0, Model0, Version0