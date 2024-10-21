select netbios_name0 [WKID], Resource_Domain_OR_Workgr0 [Domain], 
	   case sys.Is_Virtual_Machine0
	   when '0' then 'Physical'
	   when '1' then 'VM'
	   end as [VM], 
	   ch.LastActiveTime, csp.vendor0 [Mfg], csp.name0 [Model #], csp.Version0 [Model], sys.User_Name0 [Username], usr.Full_User_Name0 [Friendly Name], usr.full_domain_name0 [Logon Domain], usr.Mail0 [Email]
from v_r_system SYS left join
	 v_R_User USR ON sys.User_Name0 = usr.User_Name0 join
	 v_CH_ClientSummary CH ON sys.ResourceID = ch.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1'
order by Netbios_Name0

select case sys.Is_Virtual_Machine0
	   when '0' then 'Physical'
	   when '1' then 'VM'
	   end as [VM], count(*) [Count]
from v_r_system SYS join
	 v_CH_ClientSummary CH ON sys.ResourceID = ch.ResourceID
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1'
group by case sys.Is_Virtual_Machine0
	   when '0' then 'Physical'
	   when '1' then 'VM'
	   end