-- Physical machines with IE9
select distinct Netbios_Name0, 
	   case se.ChassisTypes0
	   when 1 then 'VM'
	   when 3 then 'Desktop'
	   when 7 then 'Desktop'
	   when 8 then 'Laptop'
	   when 10 then 'Laptop'
	   when 12 then 'Laptop'
	   when 15 then 'Desktop'
	   when 17 then 'Desktop'
	   end [Chassis], sys.User_Name0, usr1.Full_User_Name0, usr1.Mail0, usr1.title0, usr1.department0, scu.TopConsoleUser0, usr2.Full_User_Name0, usr2.Mail0, usr2.title0, usr2.department0
from v_R_System_Valid SYS left join
	 v_r_user USR1 on usr1.User_Name0 = sys.User_Name0 left join
	 v_GS_SYSTEM_CONSOLE_USAGE SCU on sys.ResourceID = scu.ResourceID left join
	 v_r_user USR2 on usr2.Unique_User_Name0 = scu.TopConsoleUser0 left join
	 v_GS_SYSTEM_ENCLOSURE SE on sys.ResourceID = se.ResourceID
where sys.resourceid in (
select ResourceID
from v_GS_InternetExplorer640
where svcversion0 not like '11%') and sys.Is_Virtual_Machine0 = 0
order by Netbios_Name0

-- Virtual machines with IE9
select distinct Netbios_Name0, sys.User_Name0, usr1.Full_User_Name0, usr1.Mail0, usr1.title0, usr1.department0, scu.TopConsoleUser0, usr2.Full_User_Name0, usr2.Mail0, usr2.title0, usr2.department0
from v_R_System_Valid SYS left join
	 v_r_user USR1 on usr1.User_Name0 = sys.User_Name0 left join
	 v_GS_SYSTEM_CONSOLE_USAGE SCU on sys.ResourceID = scu.ResourceID left join
	 v_r_user USR2 on usr2.Unique_User_Name0 = scu.TopConsoleUser0
where sys.resourceid in (
select ResourceID
from v_GS_InternetExplorer640
where svcversion0 not like '11%') and sys.Is_Virtual_Machine0 = 1
order by netbios_name0
