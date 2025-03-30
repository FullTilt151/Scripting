select Netbios_Name0 [Name], sys.Resource_Domain_OR_Workgr0 [Domain], os.Caption0 [OS], CSDVersion0 [SP], ie.svcUpdateVersion0 [IE Patch Level], svcVersion0 [IE Build1], ie.Version0 [IE Build2]
from v_r_system SYS left join
	 v_GS_OPERATING_SYSTEM OS on sys.resourceid = os.resourceid left join
	 v_GS_InternetExplorer640 IE on sys.resourceid = ie.ResourceID
where client0 = 1 and Operating_System_Name_and0 in ('Microsoft Windows NT Advanced Server 6.1','Microsoft Windows NT Server 6.1')
order by Netbios_Name0


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
	   ie.svcVersion0, ie.svcUpdateVersion0, ie.Version0
from v_r_system SYS left join
	 v_GS_InternetExplorer0 IE on sys.ResourceID = ie.ResourceID
where sys.Client0 = 1 and 
	  sys.Operating_System_Name_and0 in ('Microsoft Windows NT Advanced Server 6.1','Microsoft Windows NT Server 6.1') and
	  (ie.svcVersion0 not like '11%' or ie.svcVersion0 is null)
order by sys.Netbios_Name0