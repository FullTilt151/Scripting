-- List of installs
select sys.Netbios_Name0, SUBSTRING(scu.TopConsoleUser0, CHARINDEX('\', scu.TopConsoleUser0)+1, 8), usr1.Full_User_Name0, usr1.title0, usr1.department0, ProductName0, sft.InstallDate0, cs.LastHW
from v_r_system sys join
	 v_gs_installed_software sft on sys.ResourceID = sft.ResourceID left join
	 v_r_user usr on sys.User_Name0 = usr.User_Name0 left join
	 v_GS_SYSTEM_CONSOLE_USAGE scu on sys.ResourceID = scu.ResourceID join
	 v_r_user usr1 on SUBSTRING(scu.TopConsoleUser0, CHARINDEX('\', scu.TopConsoleUser0)+1, 8) = usr1.User_Name0 left join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID
where ProductName0 like 'Oracle VM VirtualBox%'
order by ProductName0

-- List of uninstall strings
select distinct ProductName0, UninstallString0
from v_GS_INSTALLED_SOFTWARE
where ProductName0 like 'Oracle VM VirtualBox%'
order by ProductName0