select netbios_name0 [WKID], sys.user_name0 [User], usr.Full_User_Name0, usr.Mail0, arp.DisplayName0 [Product], arp.Version0 [Version]
from v_r_system sys join
	 v_add_remove_programs ARP on sys.ResourceID = arp.ResourceID left join
	 v_r_user USR on sys.User_Name0 = usr.User_Name0
where arp.DisplayName0 = 'Safari' and
	  sys.Operating_System_Name_and0 like '%workstation%'
order by Netbios_Name0