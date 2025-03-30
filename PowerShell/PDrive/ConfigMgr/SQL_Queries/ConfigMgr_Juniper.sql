select DisplayName0, count(*)
from v_add_remove_programs
where publisher0 in ('Juniper Networks','Juniper Networks, Inc.')
group by DisplayName0
order by DisplayName0