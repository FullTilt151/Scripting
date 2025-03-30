select Publisher0, DisplayName0, Version0, count(*)
from v_add_remove_programs
where Publisher0 like '%logitech%'
group by Publisher0, DisplayName0, Version0
order by Publisher0, DisplayName0, Version0

select Netbios_Name0, sys.User_Name0, usr.Full_User_Name0, usr.title0, usr.department0, arp.DisplayName0
from v_R_System_Valid sys join
	 v_Add_Remove_Programs arp on sys.ResourceID = arp.ResourceID join
	 v_R_User usr on sys.User_Name0 = usr.User_Name0
where DisplayName0 in ('Logitech Unifying Software 2.10','Logitech Unifying Software 2.50')
order by Netbios_Name0