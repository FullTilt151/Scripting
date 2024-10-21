-- List of JRE versions
select Netbios_Name0, sft.ProductName0, sft.ProductVersion0
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.ResourceID = sft.ResourceID
where productname0 like 'java%update%' and
	  sys.Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0')
order by ProductName0

-- Count of JRE versions
select sft.ProductName0, sft.ProductVersion0, sft.UninstallString0, count(*)
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.ResourceID = sft.ResourceID
where productname0 like 'java%update%'and
	  sys.Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0')
group by sft.ProductName0, sft.ProductVersion0, UninstallString0
order by sft.ProductName0, sft.ProductVersion0, UninstallString0