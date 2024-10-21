select Publisher0, DisplayName0, Version0, count(*)
from v_add_remove_programs
where DisplayName0 like '%SQL%' and
	  (Publisher0 like '%microsoft%' or
	  Publisher0 IS NULL) and 
	  DisplayName0 NOT LIKE '%hotfix%'
group by Publisher0, DisplayName0, Version0
having COUNT(*) > 1
order by Publisher0, DisplayName0, Version0