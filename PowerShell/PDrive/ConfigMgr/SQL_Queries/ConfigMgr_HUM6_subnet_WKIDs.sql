select sys.Netbios_Name0 [WKID], sys.User_Name0, usr.Full_User_Name0, sys.Operating_System_Name_and0 [OS], nic.IPAddress0 [IP], csp.Version0 [Model], disk.Caption0 [HD], (select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [MB RAM]
from v_r_system sys left join
	 v_GS_NETWORK_ADAPTER_CONFIGURATION NIC ON sys.ResourceID = nic.ResourceID left join
	 v_gs_computer_system_product CSP on sys.ResourceID = csp.ResourceID left join
	 v_GS_DISK DISK on sys.ResourceID = disk.ResourceID left join
	 v_R_User Usr on sys.user_name0 = usr.user_name0
where (nic.IPAddress0 like '193.61.40%' or
	  nic.IPAddress0 like '193.61.42%' or
	  nic.IPAddress0 like '193.61.79%' or
	  nic.IPAddress0 like '193.91.54%') and sys.Operating_System_Name_and0 like '%workstation%'
order by Netbios_Name0