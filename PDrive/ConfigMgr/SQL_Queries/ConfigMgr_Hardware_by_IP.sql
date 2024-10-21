select distinct sys.Netbios_Name0 [Name], sys.User_Name0 [Last User], usr.Full_User_Name0 [Last User Friendly], scu.TopConsoleUser0 [Top User], usr2.Full_User_Name0 [Top User Friendly], cs.Manufacturer0 [Mfg], cs.Model0 [Model Number], csp.Version0 [Model Name], nac.IPAddress0 [IP],
				(select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [MB RAM], 
                (select count(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [DIMM Count]
from v_r_system SYS join
	 v_gs_computer_system_product CSP on sys.resourceid = csp.resourceid join
	 v_GS_COMPUTER_SYSTEM CS on sys.ResourceID = cs.ResourceID join
	 v_GS_NETWORK_ADAPTER_CONFIGURATION NAC on sys.ResourceID = nac.ResourceID left join
	 v_R_User USR on sys.User_Name0 = usr.User_Name0 left join
	 v_GS_SYSTEM_CONSOLE_USAGE SCU on sys.resourceid = scu.ResourceID left join
	 v_r_user USR2 on scu.TopConsoleUser0 = usr2.Unique_User_Name0 left join
	 v_gs_physical_memory mem on mem.ResourceID = sys.ResourceID
where sys.Client0 = 1 and
	  nac.IPAddress0 like '193.40.11%'
order by Netbios_Name0
