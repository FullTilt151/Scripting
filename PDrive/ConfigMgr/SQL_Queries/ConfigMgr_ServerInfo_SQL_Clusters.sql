select distinct sys.netbios_name0 [Name], sys.Resource_Domain_OR_Workgr0 [Domain], os.caption0 [OS], os.CSDVersion0 [Service Pack], 
	   net.IPAddress0 [IP], cs.Manufacturer0 [Mfg], cs.Model0 [Model], csp.Version0 [Model Number], cs.SystemType0 [System], bios.SMBIOSBIOSVersion0 [BIOS],
	   cpu.Name0 [CPU], cpu.NormSpeed0 [CPU Speed], 
	   (select count(cpu1.DeviceID0)
	   from v_GS_PROCESSOR CPU1
	   where sys.ResourceID = cpu1.ResourceID) [CPU Count],
	   cpu.NumberOfCores0 [CPU Core Count], cpu.NumberOfLogicalProcessors0 [CPU Logical Count], 
	   ((select count(cpu1.DeviceID0)
	   from v_GS_PROCESSOR CPU1
	   where sys.ResourceID = cpu1.ResourceID) * cpu.NumberOfLogicalProcessors0) [Total CPU Logical Count], cpu.IsHyperthreadCapable0 [HT Capable], cpu.IsHyperthreadEnabled0 [HT Enabled],
	   ch.LastActiveTime [Last Active], DATEDIFF(Day, os.lastbootuptime0, getdate()) [Uptime in Days], 
	   (select top 1 DisplayName0
	   from v_Add_Remove_Programs ARP1 
	   where arp1.resourceid = sys.ResourceID and 
	   (displayname0 = 'Microsoft sql server 2000' or
	 displayname0 = 'Microsoft sql server 2005' or
	 displayname0 = 'Microsoft SQL Server 2005 (64-bit)' or
	 displayname0 LIKE 'Microsoft SQL Server 2005%EXPRESS%' or
	 displayname0 = 'Microsoft sql server 2008' or
	 displayname0 = 'Microsoft sql server 2008 (64-bit)' or
	 displayname0 = 'Microsoft SQL Server 2008 R2' or
	 displayname0 = 'Microsoft SQL Server 2008 R2 (64-bit)' or
	 displayname0 = 'Microsoft SQL Server 2012 (64-bit)' or
	 displayname0 = 'Microsoft SQL Server 2012 Express LocalDB' or
	 displayname0 = 'Microsoft SQL Server 2014 (64-bit)' or
	 displayname0 = 'Microsoft SQL Server 2014 Express LocalDB')) [SQL]
from v_r_system SYS join
	 v_GS_OPERATING_SYSTEM OS ON sys.resourceid = os.resourceid join
	 v_gs_network_adapter_configuration NET ON sys.ResourceID = net.ResourceID join
	 v_GS_COMPUTER_SYSTEM CS on sys.ResourceID = cs.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID join
	 v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID join
	 v_GS_PROCESSOR CPU ON sys.ResourceID = CPU.ResourceID join
	 v_ch_clientsummary CH on sys.resourceid = ch.resourceid left join
	 v_Add_Remove_Programs ARP on sys.ResourceID = arp.ResourceID
where net.MACAddress0 IS NOT NULL and net.IPAddress0 IS NOT NULL and 
	  sys.Operating_System_Name_and0 like '%server%' and
	  (sys.Netbios_Name0 like '%SQLWPC%' or
	  sys.Netbios_Name0 like '%SQLWQC%' or
	  sys.Netbios_Name0 like '%SQLWTC%' or
	  sys.Netbios_Name0 like '%SQLWTM%' or
	  sys.Netbios_Name0 like '%SQLWPM%' or
	  sys.Netbios_Name0 like '%SQLWQM%') 	  
order by Name

/*

IPv6 enabled in reg?
IPv6 unbound from NIC?
Driver versions (Qlogic)

LOUSQLWPC79S01
LOUSQLWPC79S02
*/
