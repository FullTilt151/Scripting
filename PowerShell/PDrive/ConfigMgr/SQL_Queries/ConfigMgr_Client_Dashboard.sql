select netbios_name0, client0, Resource_Domain_OR_Workgr0, Operating_System_Name_and0
from v_r_system

-- Windows Workstation Client Compliance
select client0 [Client], Resource_Domain_OR_Workgr0 [Domain], count(*) [Total]
from v_r_system
where Operating_System_Name_and0 like '%workstation%' and
	  Resource_Domain_OR_Workgr0 != 'HMHSCHAMP'
group by client0, Resource_Domain_OR_Workgr0
order by Client0, Resource_Domain_OR_Workgr0


-- Windows Server Client Compliance
select client0 [Client], Resource_Domain_OR_Workgr0 [Domain], count(*) [Total]
from v_r_system
where Operating_System_Name_and0 like '%server%' and
	  Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and
	  Resource_Domain_OR_Workgr0 != 'TS' and
	  Operating_System_Name_and0 != 'Microsoft Windows NT Server Linux'
group by client0, Resource_Domain_OR_Workgr0
order by Client0, Resource_Domain_OR_Workgr0

-- Citrix Server Client Compliance
select client0 [Client], Resource_Domain_OR_Workgr0 [Domain], 
	   case Operating_System_Name_and0
	   when 'Microsoft Windows NT Server 5.0' then 'Server 2000'
	   when 'Microsoft Windows NT Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Advanced Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Advanced Server 6.3' then 'Server 2012 R2'
	   else 'Unknown'
	   end as [OS],
	   count(*) [Total]
from v_r_system
where Resource_Domain_OR_Workgr0 = 'TS'
group by client0, Resource_Domain_OR_Workgr0, 
	   case Operating_System_Name_and0
	   when 'Microsoft Windows NT Server 5.0' then 'Server 2000'
	   when 'Microsoft Windows NT Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Advanced Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Advanced Server 6.3' then 'Server 2012 R2'
	   else 'Unknown'
	   end
order by Client0, Resource_Domain_OR_Workgr0, OS

-- HGB Client Compliance
select client0 [Client], Resource_Domain_OR_Workgr0 [Domain], 
	   case Operating_System_Name_and0
	   when 'Mac OS X 10.9.2' then 'Mac OS X'
	   when 'Mac OS X 10.9.4' then 'Mac OS X'
	   when 'Microsoft Windows NT Server 5.0' then 'Server 2000'
	   when 'Microsoft Windows NT Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Advanced Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Advanced Server 6.3' then 'Server 2012 R2'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   else 'Unknown'
	   end [OS],
	   count(*) [Total]
from v_r_system
where Resource_Domain_OR_Workgr0 = 'HMHSCHAMP'
group by client0, Resource_Domain_OR_Workgr0, 
	  case Operating_System_Name_and0
	   when 'Mac OS X 10.9.2' then 'Mac OS X'
	   when 'Mac OS X 10.9.4' then 'Mac OS X'
	   when 'Microsoft Windows NT Server 5.0' then 'Server 2000'
	   when 'Microsoft Windows NT Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Advanced Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Advanced Server 6.3' then 'Server 2012 R2'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   else 'Unknown'
	   end
order by Client0, Resource_Domain_OR_Workgr0, OS

-- Other Client Compliance
select client0 [Client], Resource_Domain_OR_Workgr0 [Domain], operating_system_name_and0 [OS], count(*) [Total]
from v_r_system
where Operating_System_Name_and0 = 'Microsoft Windows NT Server Linux' or
	  (Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and
	  Resource_Domain_OR_Workgr0 != 'TS' and resourceid not in 
	  (select resourceid from v_r_system where 
	  Operating_System_Name_and0 like '%server%' or
	  Operating_System_Name_and0 like '%workstation%'))
group by client0, Resource_Domain_OR_Workgr0, Operating_System_Name_and0
order by Client0, Resource_Domain_OR_Workgr0, Operating_System_Name_and0