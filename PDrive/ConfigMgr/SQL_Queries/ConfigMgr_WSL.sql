select distinct sys.Netbios_Name0, opt.InstallState0, opt.Name0, TopConsoleUser0
from v_r_system sys inner join
	 v_gs_optional_feature opt on sys.ResourceID = opt.ResourceID left join
	 v_GS_SYSTEM_CONSOLE_USAGE scu on sys.ResourceID = scu.ResourceID
where opt.Name0 = 'Microsoft-Windows-Subsystem-Linux' and opt.InstallState0 = 1 and sys.ResourceID not in (select resourceid from v_cm_res_coll_WP1064E4)
