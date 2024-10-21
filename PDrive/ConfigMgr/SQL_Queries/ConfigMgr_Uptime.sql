-- Uptime list
select sys.netbios_name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain], sys.AD_Site_Name0 [AD] , sys.User_Name0 [Last User], usr.Mail0 [Email], usr.title0 [Title], usr.department0 [Dept], scum.TopConsoleUser0 [Top User], cs.LastActiveTime [Last Active], LastHWScan [Last HW Scan], lastbootuptime0 [Last Boot up], DATEDIFF(Day, lastbootuptime0, getdate()) [Uptime]
from v_r_system SYS left join
	 v_gs_operating_system OS ON sys.ResourceID = os.ResourceID left join
	 v_GS_WORKSTATION_STATUS WS ON sys.ResourceID = ws.ResourceID left join
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM ON sys.ResourceID = SCUM.ResourceID left join
	 v_CH_ClientSummary CS ON sys.ResourceID = cs.ResourceID left join
	 v_r_user USR on sys.user_name0 = usr.user_name0
where sys.Operating_System_Name_and0 like '%workstation%' and
	  sys.Is_Virtual_Machine0 = 0 and 
	  sys.Client0 = '1' and
	  sys.Resource_Domain_OR_Workgr0 not in ('HMHSCHAMP','RX1AD') and
	  DATEDIFF(Day, lastbootuptime0, getdate()) > 7
order by uptime desc

-- Uptime list for email notifications
select sys.netbios_name0 [WKID], usr.Mail0 [Email]
from v_r_system SYS left join
	 v_gs_operating_system OS ON sys.ResourceID = os.ResourceID left join
	 v_GS_WORKSTATION_STATUS WS ON sys.ResourceID = ws.ResourceID left join
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM ON sys.ResourceID = SCUM.ResourceID left join
	 v_CH_ClientSummary CS ON sys.ResourceID = cs.ResourceID left join
	 v_r_user USR on sys.user_name0 = usr.user_name0
where sys.Operating_System_Name_and0 like '%workstation%' and
	  sys.Is_Virtual_Machine0 = 0 and 
	  sys.Client0 = '1' and
	  sys.Resource_Domain_OR_Workgr0 not in ('HMHSCHAMP','RX1AD') and
	  usr.Mail0 IS NOT NULL and
	  usr.Mail0 != '' and
	  DATEDIFF(Day, LastHWScan, getdate()) < 10 and
	  DATEDIFF(Day, lastbootuptime0, getdate()) > 30

-- Uptime - no user
select sys.netbios_name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain], sys.AD_Site_Name0 [AD] , sys.User_Name0 [Last User], scum.TopConsoleUser0 [Top User] , cs.LastActiveTime [Last Active], LastHWScan [Last HW Scan], lastbootuptime0 [Last Boot up], DATEDIFF(Day, lastbootuptime0, getdate()) [Uptime]
from v_r_system SYS left join
	 v_gs_operating_system OS ON sys.ResourceID = os.ResourceID left join
	 v_GS_WORKSTATION_STATUS WS ON sys.ResourceID = ws.ResourceID left join
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM ON sys.ResourceID = SCUM.ResourceID left join
	 v_CH_ClientSummary CS ON sys.ResourceID = cs.ResourceID
where sys.Operating_System_Name_and0 like '%workstation%' and
	  sys.Is_Virtual_Machine0 = 0 and 
	  sys.Client0 = '1' and
	  sys.Resource_Domain_OR_Workgr0 not in ('HMHSCHAMP','RX1AD') and
	  (sys.User_Name0 IS NULL and scum.TopConsoleUser0 IS NULL) and
	  DATEDIFF(Day, lastbootuptime0, getdate()) > 7
order by uptime desc

-- Uptime count - TRxxx and no user
select case
	   when sys.netbios_name0 like 'TR%' then 'Training Room Machines'
	   when (sys.user_name0 IS NULL and scum.TopConsoleUser0 IS NULL) then 'Machines with no user'
	   else 'Unknown'
	   end [Type], 
	   count(*) [Count]
from v_r_system SYS left join
	 v_gs_operating_system OS ON sys.ResourceID = os.ResourceID left join
	 v_GS_WORKSTATION_STATUS WS ON sys.ResourceID = ws.ResourceID left join
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM ON sys.ResourceID = SCUM.ResourceID left join
	 v_CH_ClientSummary CS ON sys.ResourceID = cs.ResourceID
where sys.Operating_System_Name_and0 like '%workstation%' and
	  sys.Is_Virtual_Machine0 = 0 and 
	  sys.Client0 = '1' and
	  sys.Resource_Domain_OR_Workgr0 not in ('HMHSCHAMP','RX1AD') and
	  (sys.Netbios_Name0 like 'TR%' or
	  (sys.User_Name0 is null and scum.TopConsoleUser0 IS NULL)) and
	  DATEDIFF(Day, lastbootuptime0, getdate()) > 7
group by case
	   when sys.netbios_name0 like 'TR%' then 'Training Room Machines'
	   when (sys.user_name0 IS NULL and scum.TopConsoleUser0 IS NULL) then 'Machines with no user'
	   else 'Unknown'
	   end