-- Count of versions by VDG key
select distinct case
		sys.Operating_System_Name_and0
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		end [OS], Agentversion0, count(*)
from v_R_System_Valid SYS left join
	 v_GS_VDG640 DG on sys.ResourceID = dg.ResourceID
where sys.Operating_System_Name_and0 like '%workstation%'
group by case
		sys.Operating_System_Name_and0
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		end, Agentversion0
order by [OS],Agentversion0