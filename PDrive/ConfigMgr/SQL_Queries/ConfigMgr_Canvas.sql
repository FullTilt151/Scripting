-- List of Canvas installs
select Netbios_Name0, DisplayName0, Version0, InstallDate0
from v_add_remove_programs arp join
	 v_r_system sys ON arp.ResourceID = sys.ResourceID
where displayname0 = 'Canvas DMS'

-- Count of Canvas installs
select DisplayName0, Version0, count(*)
from v_add_remove_programs
where displayname0 = 'Canvas DMS'
group by DisplayName0, Version0