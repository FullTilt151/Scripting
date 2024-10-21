-- List of all machines and .NET Framework v4 versions
SELECT case sys.operating_system_name_and0 
		when  'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when  'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
		when  'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
		when  'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
		when  'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
		when  'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
		end [OS],  
	   case dn.BuildNumber0
	   when '4.0.30319' then '4.0'
	   when '4.5.50709' then '4.5'
	   when '4.5.50938' then '4.5'
	   when '4.5.51209' then '4.5.1'
	   when '4.5.51641' then '4.5.1'
	   when '4.5.51650' then '4.5.2'
	   when '4.5.53341' then '4.5'
	   when '4.6.00057' then '4.6.1'
	   when '4.6.00073' then '4.6.1'
	   when '4.6.00081' then '4.6.1'
	   when '4.6.01038' then '4.6.2'
	   when '4.6.01055' then '4.6.2'
	   when '4.6.01586' then '4.6.2'
	   when '4.6.01590' then '4.6.2'
	   when '4.7.02046' then '4.7'
	   when '4.7.02053' then '4.7'
	   when '4.7.02556' then '4.7.1'
	   when '4.7.02558' then '4.7.1'
	   when '4.7.03056' then '4.7.2'
	   when '4.7.03062' then '4.7.2'
	   else 'Unknown'
	   end [Version], count(*) [Total]
FROM v_r_system_valid sys Left Join
	 v_gs_dotnetframeworks0 dn ON dn.resourceid=sys.ResourceID
where dn.BuildNumber0 like '4%' and sys.Operating_System_Name_and0 != 'Microsoft Windows NT Workstation 5.1'
group by case sys.operating_system_name_and0 
		when  'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when  'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
		when  'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
		when  'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
		when  'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
		when  'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10' end,
	   case dn.BuildNumber0
	   when '4.0.30319' then '4.0'
	   when '4.5.50709' then '4.5'
	   when '4.5.50938' then '4.5'
	   when '4.5.51209' then '4.5.1'
	   when '4.5.51641' then '4.5.1'
	   when '4.5.51650' then '4.5.2'
	   when '4.5.53341' then '4.5'
	   when '4.6.00057' then '4.6.1'
	   when '4.6.00073' then '4.6.1'
	   when '4.6.00081' then '4.6.1'
	   when '4.6.01038' then '4.6.2'
	   when '4.6.01055' then '4.6.2'
	   when '4.6.01586' then '4.6.2'
	   when '4.6.01590' then '4.6.2'
	   when '4.7.02046' then '4.7'
	   when '4.7.02053' then '4.7'
	   when '4.7.02556' then '4.7.1'
	   when '4.7.02558' then '4.7.1'
	   when '4.7.03056' then '4.7.2'
	   when '4.7.03062' then '4.7.2'
	   else 'Unknown'
	   end
order by [OS], [Version]

-- List of all machines and .NET Framework versions
SELECT sys1.netbios_name0 as [Name],
MAX(CASE dn.version0 when '1.0' THEN
case dn.buildNumber0 when isnull(dn.buildnumber0,1) then dn.BuildNumber0 End END) AS [.Net 1.0],
MAX(CASE dn.version0 when '1.1' THEN
case dn.BuildNumber0 when isnull(dn.buildnumber0,1) then dn.buildnumber0 End END) AS [.Net 1.1],
MAX(CASE dn.version0 when '2.0' THEN
case dn.BuildNumber0 when isNull(dn.buildnumber0,1) then dn.BuildNumber0 end END) AS [.Net 2.0],
MAX(CASE dn.version0 when '3.0' THEN
case dn.BuildNumber0 when isNull(dn.buildnumber0,1) then dn.BuildNumber0 end END) AS [.Net 3.0],
MAX(CASE dn.version0 when '3.5' THEN
case dn.BuildNumber0 when isNull(dn.buildnumber0,1) then dn.BuildNumber0 end END) AS [.Net 3.5],
MAX(CASE dn.version0 when '3.5' THEN
case dn.ServicePack0 when isnull(DN.ServicePack0,1) then dn.ServicePack0 end END) AS [.Net 3.5 ServicePack],
MAX(CASE dn.version0 when '4.0' THEN
case dn.BuildNumber0 when isNull(dn.buildnumber0,1) then dn.BuildNumber0 end END) AS [.Net 4.0]
FROM v_r_system_valid sys1 Left Join
v_gs_dotnetframeworks0 dn ON dn.resourceid=sys1.ResourceID
Group By sys1.netbios_name0
ORDER BY sys1.netbios_name0

-- Raw data
select distinct Build01, BuildNumber0
from v_R_System sys join
	 v_gs_dotnetframeworks0 dotnet on sys.ResourceID = dotnet.ResourceID