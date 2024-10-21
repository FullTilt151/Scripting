select TopConsoleUser0, USR.Full_User_Name0 [Full Name], count(*) [Total]
from v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM join
	 v_r_user USR ON SCUM.TopConsoleUser0 = USR.Unique_User_Name0 join
	 v_r_system SYS ON SCUM.ResourceID = SYS.ResourceID
where sys.Operating_System_Name_and0 like '%workstation%'
group by TopConsoleUser0, Full_User_Name0
having count(*) > '2'
order by count(*) desc