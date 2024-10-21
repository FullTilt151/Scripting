select sys.netbios_name0 [Name], sys.Resource_Domain_OR_Workgr0 [Domain],
	   case sys.Operating_System_Name_and0 
	   when 'Microsoft Windows NT Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Server 6.3' then 'Server 2012 R2'
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Advanced Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Advanced Server 6.3' then 'Server 2012 R2'
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   end [OS], 
	   arp.DisplayName0 [VSE], Version0 [VSE Version]
from v_r_system SYS join
	 v_add_remove_programs ARP on sys.resourceid = arp.resourceid
where arp.DisplayName0 like 'McAfee VirusScan Enterprise' and
	  sys.Is_Virtual_Machine0 = '1' and
	  sys.Client0 = '1' and
	  sys.Resource_Domain_OR_Workgr0 != 'TS' and
	  (sys.Operating_System_Name_and0 != 'Microsoft Windows NT Server 5.2' and
	  sys.Operating_System_Name_and0 != 'Microsoft Windows NT Advanced Server 5.2' and
	  sys.Operating_System_Name_and0 != 'Microsoft Windows NT Server 6.1' and
	  sys.Operating_System_Name_and0 != 'Microsoft Windows NT Advanced Server 6.1')
order by OS, Netbios_Name0