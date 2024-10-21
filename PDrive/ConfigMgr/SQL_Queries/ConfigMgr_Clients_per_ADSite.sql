select Resource_Domain_OR_Workgr0 [Domain], ad_site_name0 [AD Site], count(*) [Client Count]
from v_r_system
where client0 = 1
group by Resource_Domain_OR_Workgr0, ad_site_name0
order by Domain, count(*) desc