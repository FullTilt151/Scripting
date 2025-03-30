select sys.Netbios_Name0 [Name], sys.Resource_Domain_OR_Workgr0 [Domain], 
	   case sys.Operating_System_Name_and0 
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Advanced Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Advanced Server 6.3' then 'Server 2012 R2'
	   when 'Microsoft Windows NT Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Server 6.3' then 'Server 2012 R2'
	   end as [OS], 
	   ie.svcVersion0 [IE Major Version]
from v_R_System_Valid SYS left join
	 v_GS_InternetExplorer0 IE on sys.ResourceID = ie.ResourceID
where ((sys.Operating_System_Name_and0 in ('Microsoft Windows NT Advanced Server 6.0','Microsoft Windows NT Server 6.0') and ie.svcVersion0 not like '9%') or
	  (sys.Operating_System_Name_and0 in ('Microsoft Windows NT Advanced Server 6.1','Microsoft Windows NT Server 6.1') and ie.svcVersion0 not like '11%') or
	  (sys.Operating_System_Name_and0 in ('Microsoft Windows NT Advanced Server 6.2','Microsoft Windows NT Server 6.2') and ie.svcVersion0 not like '10%') or
	  (sys.Operating_System_Name_and0 in ('Microsoft Windows NT Advanced Server 6.3','Microsoft Windows NT Server 6.3') and ie.svcVersion0 not like '11%')) and
	  sys.Resource_Domain_OR_Workgr0 in @Domain
order by sys.Netbios_Name0



select distinct sys.Resource_Domain_OR_Workgr0 [Domain]
from v_R_System_Valid SYS
where sys.Operating_System_Name_and0 in ('Microsoft Windows NT Advanced Server 6.0','Microsoft Windows NT Server 6.0','Microsoft Windows NT Advanced Server 6.1','Microsoft Windows NT Server 6.1',
										  'Microsoft Windows NT Advanced Server 6.2','Microsoft Windows NT Server 6.2','Microsoft Windows NT Advanced Server 6.3','Microsoft Windows NT Server 6.3')