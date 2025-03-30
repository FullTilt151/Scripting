select distinct sys.netbios_name0 [Name], 
	   case 
	   when Netbios_Name0 like '%WPS%' then 'Prod'
	   when Netbios_Name0 like '%WPL%' then 'Prod'
	   when Netbios_Name0 like '%WPC%' then 'Prod'
	   when Netbios_Name0 like '%WPB%' then 'Prod'
	   when Netbios_Name0 like '%WPG%' then 'Prod'
	   when Netbios_Name0 like '%WPU%' then 'Prod'
	   when Netbios_Name0 like '%WPV%' then 'Prod'
	   when Netbios_Name0 like '%WPM%' then 'Prod'
	   when Netbios_Name0 like '%WQS%' then 'QA'
	   when Netbios_Name0 like '%WQL%' then 'QA'
	   when Netbios_Name0 like '%WQC%' then 'QA'
	   when Netbios_Name0 like '%WAG%' then 'QA'
	   when Netbios_Name0 like '%WAS%' then 'QA'
	   when Netbios_Name0 like '%WAL%' then 'QA'
	   when Netbios_Name0 like '%WDL%' then 'Dev'
	   when Netbios_Name0 like '%WDG%' then 'Dev'
	   when Netbios_Name0 like '%WDS%' then 'Dev'
	   when Netbios_Name0 like '%PDW%' then 'Dev'
	   when Netbios_Name0 like '%WTS%' then 'Test'
	   when Netbios_Name0 like '%WTC%' then 'Test'
	   when Netbios_Name0 like '%WTL%' then 'Test'
	   when Netbios_Name0 like '%WTG%' then 'Test'
	   when Netbios_Name0 like '%WTX%' then 'Test'
	   when Netbios_Name0 like '%WEC%' then 'Education'
	   when Netbios_Name0 like '%WEL%' then 'Education'
	   when Netbios_Name0 like '%WES%' then 'Education'
	   when Netbios_Name0 like '%WIS%' then 'Intermediate'
	   when Netbios_Name0 like '%WIL%' then 'Intermediate'
	   when Netbios_Name0 like '%WRL%' then 'Recovery'
	   when Netbios_Name0 like '%WRS%' then 'Recovery'
	   when Netbios_Name0 like '%WRC%' then 'Recovery'
	   when Netbios_Name0 like '%WSL%' then 'Staging'
	   when Netbios_Name0 like '%WSC%' then 'Staging'
	   when Netbios_Name0 like '%WSS%' then 'Staging'
	   else 'Unknown'
	   end [Environment], 
	   sys.Resource_Domain_OR_Workgr0 [Domain], os.caption0 [OS], os.CSDVersion0 [Service Pack], sys.Client_Version0 [Client Version],
	   net.IPAddress0 [IP], cs.Manufacturer0 [Mfg], cs.Model0 [Model], csp.Version0 [Model Number], cs.SystemType0 [System], bios.SMBIOSBIOSVersion0 [BIOS],
	   cpu.Name0 [CPU], cpu.NormSpeed0 [CPU Speed], 
	   (select count(cpu1.DeviceID0)
	   from v_GS_PROCESSOR CPU1
	   where sys.ResourceID = cpu1.ResourceID) [CPU Count],
	   cpu.NumberOfCores0 [CPU Core Count], cpu.NumberOfLogicalProcessors0 [CPU Logical Count], 
	   ((select count(cpu1.DeviceID0)
	   from v_GS_PROCESSOR CPU1
	   where sys.ResourceID = cpu1.ResourceID) * cpu.NumberOfLogicalProcessors0) [Total CPU Logical Count], cpu.IsHyperthreadCapable0 [HT Capable], cpu.IsHyperthreadEnabled0 [HT Enabled],
	   ch.LastActiveTime [Last Active], DATEDIFF(Day, os.lastbootuptime0, getdate()) [Uptime in Days]
from v_r_system SYS join
	 v_GS_OPERATING_SYSTEM OS ON sys.resourceid = os.resourceid join
	 v_gs_network_adapter_configuration NET ON sys.ResourceID = net.ResourceID join
	 v_GS_COMPUTER_SYSTEM CS on sys.ResourceID = cs.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID join
	 v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID join
	 v_GS_PROCESSOR CPU ON sys.ResourceID = CPU.ResourceID join
	 v_ch_clientsummary CH on sys.resourceid = ch.resourceid
where sys.client0 = 1 and net.MACAddress0 IS NOT NULL and net.IPAddress0 IS NOT NULL and 
	  sys.Operating_System_Name_and0 in (
						'Microsoft Windows NT Advanced Server 5.2',
						'Microsoft Windows NT Advanced Server 6.0',
						'Microsoft Windows NT Advanced Server 6.1',
						'Microsoft Windows NT Advanced Server 6.3',
						'Microsoft Windows NT Server 5.0',
						'Microsoft Windows NT Server 5.2',
						'Microsoft Windows NT Server 6.0',
						'Microsoft Windows NT Server 6.1',
						'Microsoft Windows NT Server 6.2',
						'Microsoft Windows NT Server 6.3')
order by Name
