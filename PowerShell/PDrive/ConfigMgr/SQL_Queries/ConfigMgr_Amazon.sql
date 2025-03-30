select Publisher0, DisplayName0, Version0, count(*)
from v_add_remove_programs
where publisher0 in ('Amazon Web Services Developer Relations','Amazon','Amazon Corporate LLC','Amazon Web Services')
group by Publisher0, DisplayName0, Version0
order by Publisher0, DisplayName0, Version0