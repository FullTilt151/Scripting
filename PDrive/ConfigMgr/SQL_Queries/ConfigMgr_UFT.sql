select netbios_name0 [WKID], sys.user_name0 [User], usr.Full_User_Name0 [FriendlyName], usr.Mail0 [Email], ProductName [Product], ProductVersion [Version]
from v_r_system SYS join
	 v_GS_SoftwareProduct SP ON sys.ResourceID = SP.ResourceID left join
	 v_R_User USR ON sys.User_Name0 = usr.User_Name0
where ProductName = 'UFT' and
	  Operating_System_Name_and0 like '%workstation%'
order by WKID