select netbios_name0, publisher0, DisplayName0, Version0
from v_r_system sys join
	 v_add_remove_programs arp on sys.ResourceID = arp.ResourceID
where publisher0 = 'Argus Health Systems'