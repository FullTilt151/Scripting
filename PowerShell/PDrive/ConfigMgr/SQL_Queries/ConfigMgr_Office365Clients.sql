select sys.Netbios_Name0, sys.user_name0, usr.Full_User_Name0, usr.title0, usr.department0, o365.*
from v_r_system sys inner join
	 v_GS_OFFICE365PROPLUSCONFIGURATIONS o365 on sys.ResourceID = o365.ResourceID left join
	 v_R_User usr on sys.User_Name0 = usr.User_Name0
where InstallationPath0 is not null
order by Netbios_Name0