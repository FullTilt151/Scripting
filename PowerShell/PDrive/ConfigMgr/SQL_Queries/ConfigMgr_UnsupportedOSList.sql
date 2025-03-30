select Netbios_Name0 [WKID], operating_system_name_and0 [OS],
	   case operating_system_name_and0 
	   when 'Windows NT 4.0' then 'Windows NT'
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.2' then 'Windows 8'
	   when 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' then 'Windows 8'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   when 'Windows 10 Pro Technical Preview 10.0' then 'Windows 10'
	   when 'Windows 10 Enterprise Insider Preview 10.0' then 'Windows 10'
	   end as [OS Friendly],
	   InstallDate0 [OS Installed] , sys.Client0 [ConfigMgr Client], AD_Site_Name0 [AD Site] , Resource_Domain_OR_Workgr0 [Domain], SYS.User_Name0 [User], Full_User_Name0 [Friendly Name]
from v_R_System SYS left join
	 v_GS_OPERATING_SYSTEM OS on sys.ResourceID = os.ResourceID left join
	 v_r_user USR on sys.ResourceID = usr.ResourceID
where Operating_System_Name_and0 is not null and
	  (Operating_System_Name_and0 like '%nt%' or
	  Operating_System_Name_and0 like '%windows%') and
	  Operating_System_Name_and0 not like '%NT workstation 5.1%' and
	  Operating_System_Name_and0 not like '%NT workstation 6.1%' and
	  Operating_System_Name_and0 not like '%NT workstation 6.3%' and
	  Operating_System_Name_and0 not like '%server%'