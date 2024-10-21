-- Count of VS Code versions
select case sys.Operating_System_Name_and0 
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		end [OS], ProductName0, ProductVersion0, count(*)
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.ResourceID = sft.ResourceID
where productname0 like 'Microsoft Visual Studio Code'
group by case sys.Operating_System_Name_and0 
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		end, ProductName0, ProductVersion0
order by [OS], ProductName0, ProductVersion0

-- List of VS Code WKIDs
select sys.netbios_name0, case sys.Operating_System_Name_and0 
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		end [OS], ProductName0, ProductVersion0
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.ResourceID = sft.ResourceID
where productname0 like 'Microsoft Visual Studio Code' and sys.Netbios_Name0 in (
'WKr90NSTW0',
'WKR90P8RG3',
'Wkmj027rna',
'Wkr90p6uew',
'Wkmjxzhlk',
'Wkpc0jyt2m',
'Wkmj05xbp2',
'Wkmj48bd8',
'Wkr90p6d23')