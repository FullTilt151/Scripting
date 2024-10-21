select caption0 [OS], Locale0 [Locale], OSLanguage0 [Language], count(*) [Total]
from v_r_system sys left join
	 v_gs_operating_system OS on sys.ResourceID = os.ResourceID
where sys.client0 = 1
group by caption0, Locale0, OSLanguage0
order by caption0, Locale0, OSLanguage0