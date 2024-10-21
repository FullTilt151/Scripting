-- DPA 15 installs
select netbios_name0, sys.User_Name0, DisplayName0, Version0, installdate0
from v_R_System_Valid sys join 
	 v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID
where DisplayName0 = 'Desktop & Process Analytics Client(x64) - 15.1.0.1666'
order by installdate0 desc

-- All Verint products
select Publisher0, DisplayName0, Version0, count(*)
from v_r_system sys join
	  v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID
where Publisher0 in ('Verint','Verint inc.','Verint System Inc','Verint System Inc.','Verint Systems','Verint System Ltd','Verint Systems Inc','Verint Systems Inc.','Verint Systems Ltd','Verint Systems LTD.','Verint Video Solutions','Verint, Inc.')
group by Publisher0, DisplayName0, Version0
order by DisplayName0, Version0