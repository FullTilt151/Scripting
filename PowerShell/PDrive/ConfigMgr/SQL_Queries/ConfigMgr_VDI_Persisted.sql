select LEFT(netbios_name0,10) [Build] , Resource_Domain_OR_Workgr0 [Domain], Is_MachineChanges_Persisted0, count(*)
from v_r_system
where netbios_name0 like '%xdw%' and Is_Virtual_Machine0 = '1' and client0 = '1'
group by LEFT(netbios_name0,10)  , Resource_Domain_OR_Workgr0, Is_MachineChanges_Persisted0
order by Build,Domain, Is_MachineChanges_Persisted0