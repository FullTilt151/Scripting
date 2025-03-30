-- All users
select distinct usr.Unique_User_Name0 [Full User Name], usr.User_Name0 [User Name], usr.Full_User_Name0 [Friendly Name], usr.Full_Domain_Name0 [Domain], 
	   usr.title0 [Title], usr.department0 [Dept], sys.Netbios_Name0 [Last User WKID], 
	   (select sys1.Netbios_Name0
		from v_r_system SYS1
		where SYS1.resourceid = scum.ResourceID and
		      operating_system_name_and0 like '%workstation%' ) [Top User WKID]
from v_R_User USR join
	 v_r_system SYS on usr.user_name0 = sys.User_Name0 join
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM on usr.Unique_User_Name0 = scum.TopConsoleUser0
where usr.Full_Domain_Name0 != 'HMHSCHAMP.HUMAD.COM' and
	  usr.Full_Domain_Name0 != 'ADEA.HUM' and
	  usr.user_name0 not like '%A' and
	  usr.User_Name0 not like '%S' and
	  sys.Operating_System_Name_and0 like '%workstation%'
order by usr.Full_Domain_Name0, usr.department0, usr.title0, usr.User_Name0

-- Only admin accounts
select distinct usr.Unique_User_Name0 [Full User Name], usr.User_Name0 [User Name], usr.Full_User_Name0 [Friendly Name], usr.Full_Domain_Name0 [Domain], 
	   usr.title0 [Title], usr.department0 [Dept], sys.Netbios_Name0 [Last User WKID], 
	   (select sys1.Netbios_Name0
		from v_r_system SYS1
		where SYS1.resourceid = scum.ResourceID and
		      operating_system_name_and0 like '%workstation%' ) [Top User WKID]
from v_R_User USR join
	 v_r_system SYS on usr.user_name0 = sys.User_Name0 join
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM on usr.Unique_User_Name0 = scum.TopConsoleUser0
where usr.Full_Domain_Name0 != 'HMHSCHAMP.HUMAD.COM' and
	  usr.Full_Domain_Name0 != 'ADEA.HUM' and
	  (usr.user_name0 like '%A' or
	  usr.User_Name0 like '%S') and
	  sys.Operating_System_Name_and0 like '%workstation%'
order by usr.Full_Domain_Name0, usr.department0, usr.title0, usr.User_Name0