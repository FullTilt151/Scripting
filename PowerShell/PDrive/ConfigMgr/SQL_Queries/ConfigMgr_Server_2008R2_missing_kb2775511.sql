select sys.netbios_name0 [Server], 
	   case sys.Operating_System_Name_and0 
	   when 'Microsoft Windows NT Advanced Server 5.2' then 'Server 2003'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.0' then 'Server 2008'
	   when 'Microsoft Windows NT Advanced Server 6.1' then 'Server 2008 R2'
	   when 'Microsoft Windows NT Advanced Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Server 6.2' then 'Server 2012'
	   when 'Microsoft Windows NT Advanced Server 6.3' then 'Server 2012 R2'
	   end as [OS], sys.Resource_Domain_OR_Workgr0 [Domain], Is_Virtual_Machine0 [VM]
from v_r_system sys
where sys.Operating_System_Name_and0 = 'Microsoft Windows NT Advanced Server 6.1' and
	  sys.Client0 = '1' and
	  sys.ResourceID not in 
		(select resourceid
		from v_gs_quick_fix_engineering
		where hotfixid0 = 'KB2775511')
order by Server