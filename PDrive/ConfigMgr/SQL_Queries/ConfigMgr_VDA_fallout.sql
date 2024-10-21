SELECT top 50 sys.netbios_name0 WKID, adv.AdvertisementID,adv.AdvertisementName, 
	stat.LastStateName, stat.lastexecutionresult [Result], DATEADD(HH,-5,stat.laststatustime) [Last Status Time EST], 
	adv.PackageID,
	pkg.Name AS Package, 
	adv.ProgramName AS Program, 
	adv.Comment AS Description,  
	adv.CollectionID
FROM v_advertisement adv 
	full JOIN v_Package  pkg ON adv.PackageID = pkg.PackageID 
	full JOIN v_ClientAdvertisementStatus  stat ON stat.AdvertisementID = adv.AdvertisementID 
	full JOIN v_R_System sys ON stat.ResourceID=sys.ResourceID 
WHERE pkg.name = 'XenDesktop 7.1 Upgrade w/ Lync 2013'
order by LastStatusTime desc

-- Non-VDI Workstations with VDA
select sys.Netbios_Name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain], DisplayName0 [Product], Version0 [Version], InstallDate0 [Installed]
from v_r_system SYS join
	v_add_remove_programs ARP on sys.ResourceID = arp.ResourceID
where (DisplayName0 like 'Citrix Virtual Desktop%' and Version0 = '7.1.0.4019') and
	  sys.Netbios_Name0 not like '%xdw%' and Operating_System_Name_and0 like '%workstation%' 
	  and InstallDate0 >= '20150817'
order by Netbios_Name0 DESC

-- Non-VDI Servers with VDA
select sys.Netbios_Name0 [Server], DisplayName0 [Product], Version0 [Version], InstallDate0 [Installed]
from v_r_system SYS join
	v_add_remove_programs ARP on sys.ResourceID = arp.ResourceID
where (DisplayName0 = 'Citrix Virtual Desktop Agent - x64') and
	  Operating_System_Name_and0 like '%server%' and
	  Netbios_Name0 not like '%cmf%' and
	  Netbios_Name0 not like '%xad%'
order by InstallDate0 DESC

-- Non-VDI Servers with VDA Delivery
select sys.Netbios_Name0 [Server], DisplayName0 [Product], Version0 [Version], InstallDate0 [Installed]
from v_r_system SYS join
	v_add_remove_programs ARP on sys.ResourceID = arp.ResourceID
where (DisplayName0 = 'Citrix Virtual Delivery Agent 7.1') and
	  Operating_System_Name_and0 like '%server%' and
	  Netbios_Name0 not like '%cmf%' and
	  Netbios_Name0 not like '%xad%'
order by InstallDate0 DESC

-- Non-VDI Servers with Receiver
select sys.Netbios_Name0 [Server], DisplayName0 [Product], Version0 [Version], InstallDate0 [Installed]
from v_r_system SYS join
	v_add_remove_programs ARP on sys.ResourceID = arp.ResourceID
where (DisplayName0 = 'Citrix Receiver') and
	  Operating_System_Name_and0 like '%server%' and
	  InstallDate0 >= '20150817'
order by InstallDate0 DESC

-- Non-VDI Servers with RDS
select sys.Netbios_Name0 [Server], role.Name0 [Role]
from v_r_system SYS join
	v_GS_SERVER_FEATURE ROLE on sys.ResourceID = ROLE.ResourceID
where Operating_System_Name_and0 like '%server%' and
	  sys.Resource_Domain_OR_Workgr0 != 'ts' and
	  role.name0 = 'Remote Desktop Services' and
	  sys.Netbios_Name0 not like 'XEN%'
order by sys.Netbios_Name0

-- Non-VDI Servers with Lync 2013
select sys.Netbios_Name0 [Server], DisplayName0 [Product], Version0 [Version], InstallDate0 [Installed]
from v_r_system SYS join
	v_add_remove_programs ARP on sys.ResourceID = arp.ResourceID
where (DisplayName0 = 'Microsoft Lync 2013') and
	  Operating_System_Name_and0 like '%server%' and
	  InstallDate0 >= '20150817'
order by InstallDate0 DESC

-- Servers rebooted since 3:30pm 8/17
select Netbios_Name0 [Name], LastBootUpTime0 [Last Boot Up Time]
from v_R_System sys full join 
	 v_GS_OPERATING_SYSTEM OS on sys.ResourceID = os.ResourceID
where Operating_System_Name_and0 like '%server%' and
	  LastBootUpTime0 > '2015-08-17 15:30:00.000'
order by LastBootUpTime0 desc

-- All Servers with Desktop, Delivery, or RDS
select distinct sys.Netbios_Name0 [Server],
	   case 
	   when sys.netbios_name0 like '%WPL%' then 'Prod'
	   when sys.netbios_name0 like '%WDS%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WIS%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WPS%' then 'Prod'
	   when sys.netbios_name0 like '%WQL%' then 'QA'
	   when sys.netbios_name0 like '%WQS%' then 'QA'
	   when sys.netbios_name0 like '%WTS%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WDG%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WES%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WPG%' then 'Prod'
	   when sys.netbios_name0 like '%WTL%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WSL%' then 'QA'
	   when sys.netbios_name0 like '%WPC%' then 'Prod'
	   when sys.netbios_name0 like '%WQC%' then 'QA'
	   when sys.netbios_name0 like '%WPC%' then 'Prod'
	   when sys.netbios_name0 like '%WSC%' then 'QA'
	   when sys.netbios_name0 like '%WTC%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WEL%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WIL%' then 'Test/Dev'
	   end [Environment],
	   case Operating_System_Name_and0
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Advanced Server 6.3' then 'Server 2012 R2'
	   when 'Microsoft Windows NT Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Server 6.3' then 'Server 2012 R2'
	   end [OS],
	   sys.Resource_Domain_OR_Workgr0 [Domain] ,
	   (select DisplayName0 
	   from v_Add_Remove_Programs arp1
	   where arp1.ResourceID = sys.ResourceID and
		      (DisplayName0 = 'Citrix Virtual Desktop Agent - x64'))
	   [DT Product], 
	   (select Version0 
	   from v_Add_Remove_Programs arp1
	   where arp1.ResourceID = sys.ResourceID and
		(DisplayName0 = 'Citrix Virtual Desktop Agent - x64')) [DT Version], 
		(select InstallDate0 
	   from v_Add_Remove_Programs arp1
	   where arp1.ResourceID = sys.ResourceID and
		      (DisplayName0 = 'Citrix Virtual Desktop Agent - x64')) [DT Installed], 
			  (select DisplayName0 
	   from v_Add_Remove_Programs arp1
	   where arp1.ResourceID = sys.ResourceID and
		      (DisplayName0 = 'Citrix Virtual Delivery Agent 7.1')) [DE Product], 
	   (select Version0 
	   from v_Add_Remove_Programs arp1
	   where arp1.ResourceID = sys.ResourceID and
		(DisplayName0 = 'Citrix Virtual Delivery Agent 7.1')) [DE Version], 
			  (select Name0
			  from v_GS_SERVER_FEATURE ROLE1
			  where role1.ResourceID = sys.ResourceID and
				    role1.name0 = 'Remote Desktop Services') [RDS], 
		cast((select cicsd2.CurrentValue
		from v_CIComplianceStatusDetail cicsd2
		where cicsd2.Netbios_Name0 = sys.Netbios_Name0 and 
			  cicsd2.ci_id = '165992') as int) [RDS License Expires]
from v_r_system SYS right join
	 v_add_remove_programs ARP on sys.ResourceID = arp.ResourceID join
	 v_GS_SERVER_FEATURE ROLE on sys.ResourceID = role.ResourceID left join
	 v_CIComplianceStatusDetail CICSD on sys.resourceid = cicsd.ResourceID
where Operating_System_Name_and0 like '%server%' and
	  Resource_Domain_OR_Workgr0 != 'TS' and
	  (arp.displayname0 = 'Citrix Virtual Desktop Agent - x64' or
	  arp.DisplayName0 = 'Citrix Virtual Delivery Agent 7.1' or
	  role.name0 = 'Remote Desktop Services') and
	  sys.Netbios_Name0 not like 'SIMCMF%' and
	  client0 = 1
order by sys.Netbios_Name0

-- All Servers with Desktop, Delivery, or RDS count
select case 
	   when sys.netbios_name0 like '%WPL%' then 'Prod'
	   when sys.netbios_name0 like '%WDS%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WIS%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WPS%' then 'Prod'
	   when sys.netbios_name0 like '%WQL%' then 'QA'
	   when sys.netbios_name0 like '%WQS%' then 'QA'
	   when sys.netbios_name0 like '%WTS%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WDG%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WES%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WPG%' then 'Prod'
	   when sys.netbios_name0 like '%WTL%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WSL%' then 'QA'
	   when sys.netbios_name0 like '%WPC%' then 'Prod'
	   when sys.netbios_name0 like '%WQC%' then 'QA'
	   when sys.netbios_name0 like '%WPC%' then 'Prod'
	   when sys.netbios_name0 like '%WSC%' then 'QA'
	   when sys.netbios_name0 like '%WTC%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WEL%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WIL%' then 'Test/Dev'
	   end [Environment]--, count(sys.Netbios_Name0)
from v_r_system SYS right join
	 v_add_remove_programs ARP on sys.ResourceID = arp.ResourceID join
	 v_GS_SERVER_FEATURE ROLE on sys.ResourceID = role.ResourceID
where Operating_System_Name_and0 like '%server%' and
	  Resource_Domain_OR_Workgr0 != 'TS' and
	  (arp.displayname0 = 'Citrix Virtual Desktop Agent - x64' or
	  arp.DisplayName0 = 'Citrix Virtual Delivery Agent 7.1' or
	  role.name0 = 'Remote Desktop Services') and
	  sys.Client0 = 1
group by case 
	   when sys.netbios_name0 like '%WPL%' then 'Prod'
	   when sys.netbios_name0 like '%WDS%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WIS%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WPS%' then 'Prod'
	   when sys.netbios_name0 like '%WQL%' then 'QA'
	   when sys.netbios_name0 like '%WQS%' then 'QA'
	   when sys.netbios_name0 like '%WTS%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WDG%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WES%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WPG%' then 'Prod'
	   when sys.netbios_name0 like '%WTL%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WSL%' then 'QA'
	   when sys.netbios_name0 like '%WPC%' then 'Prod'
	   when sys.netbios_name0 like '%WQC%' then 'QA'
	   when sys.netbios_name0 like '%WPC%' then 'Prod'
	   when sys.netbios_name0 like '%WSC%' then 'QA'
	   when sys.netbios_name0 like '%WTC%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WEL%' then 'Test/Dev'
	   when sys.netbios_name0 like '%WIL%' then 'Test/Dev'
	   end

-- Servers with VDA - files
select sys.Netbios_Name0, sys.Resource_Domain_OR_Workgr0, sys.Operating_System_Name_and0, sf.FileName, FileVersion, FilePath
from v_r_system SYS join
	 v_GS_SoftwareFile SF on sys.ResourceID = sf.ResourceID
where filename = 'BrokerAgent.exe' and
	  client0 = 1 and
	  Operating_System_Name_and0 like '%server%' and
	  Resource_Domain_OR_Workgr0 != 'TS'
order by Netbios_Name0

-- Servers with RFS - files
select sys.Netbios_Name0, sys.Resource_Domain_OR_Workgr0, sys.Operating_System_Name_and0, sf.FileName, FileVersion, FilePath
from v_r_system SYS join
	 v_GS_SoftwareFile SF on sys.ResourceID = sf.ResourceID
where filename = 'tsappinstall.exe' and
	  client0 = 1 and
	  Operating_System_Name_and0 like '%server%' and
	  Resource_Domain_OR_Workgr0 != 'TS' and
	  FilePath = 'C:\WINDOWS\system32\'
order by Netbios_Name0