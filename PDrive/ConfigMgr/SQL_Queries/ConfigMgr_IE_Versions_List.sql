select netbios_name0 [WKID],
	   case Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   else 'Other'
	   end as [OS],
	   sys.User_Name0 [User],usr.Full_User_Name0 [Friendly Name], usr.Mail0 [Email], ie.svcUpdateVersion0 [IE Version]
from v_r_system SYS left join
	 v_GS_InternetExplorer640 IE on sys.resourceid = ie.ResourceID left join
	 v_R_User USR ON sys.User_Name0 = usr.User_Name0
where sys.Operating_System_Name_and0 like '%workstation%' and ie.svcUpdateVersion0 like @IEversion
order by [WKID]