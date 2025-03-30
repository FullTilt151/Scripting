select DisplayName0, Version0, count(*)
from v_r_system SYS join
     v_add_remove_programs arp on sys.ResourceID = arp.ResourceID
where displayname0 like 'Intel%driver update%' and sys.Client0 = 1
group by Publisher0, DisplayName0, Version0
order by Version0