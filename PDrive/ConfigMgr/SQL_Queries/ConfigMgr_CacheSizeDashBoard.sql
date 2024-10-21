-- Workstation - Cache Size
select case sys.Operating_System_Name_and0 
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   end as [OS], 
	   sys.Is_Virtual_Machine0 [VM], LOWER(cache.Location0) [Path], cache.Size0 [Size], count(*) [Total]
from v_r_system sys left join
	 v_GS_SMS_ADVANCED_CLIENT_CACH CACHE on sys.resourceid = cache.ResourceID
where sys.Operating_System_Name_and0 like '%workstation%' and
	  sys.Client0 = '1'
group by case sys.Operating_System_Name_and0 
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
	   when 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
	   end, sys.Is_Virtual_Machine0, cache.Location0, cache.Size0
having count(*) > 5
order by OS, VM, Size

-- Servers - Cache Size
select case sys.Operating_System_Name_and0 
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Windows Server 2003'
	   when 'Microsoft Windows NT Advanced Server 6.0' then 'Windows Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Windows Server 2008 R2'
	   when 'Microsoft Windows NT Server 6.0' then 'Windows Server 2008'
	   when 'Microsoft Windows NT Server 6.2' then 'Windows Server 2012'
	   when 'Microsoft Windows NT Server 6.3' then 'Windows Server 2012 R2'
	   end as [OS], 
       sys.Is_Virtual_Machine0 [VM], cache.Location0 [Path], cache.Size0 [Size], count(*) [Total]
from v_r_system sys left join
	 v_GS_SMS_ADVANCED_CLIENT_CACH CACHE on sys.resourceid = cache.ResourceID
where sys.Operating_System_Name_and0 not like '%workstation%' and 
	  sys.Operating_System_Name_and0 like '%windows%' and
	  sys.Client0 = '1'
group by case sys.Operating_System_Name_and0 
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Windows Server 2003'
	   when 'Microsoft Windows NT Advanced Server 6.0' then 'Windows Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Windows Server 2008 R2'
	   when 'Microsoft Windows NT Server 6.0' then 'Windows Server 2008'
	   when 'Microsoft Windows NT Server 6.2' then 'Windows Server 2012'
	   when 'Microsoft Windows NT Server 6.3' then 'Windows Server 2012 R2'
	   end, sys.Is_Virtual_Machine0, cache.Location0, cache.Size0
having count(*) > 5
order by OS, VM, Size