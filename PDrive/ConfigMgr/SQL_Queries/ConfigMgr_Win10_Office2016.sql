-- Count of Office versions
select ProductName0, count(*)
from v_R_System_Valid sys left join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)') and
	  ProductName0 like 'Microsoft Office Professional Plus %' or ProductName0 like 'Microsoft Office __-bit Components %'
group by ProductName0
order by ProductName0

-- List of unsupported Office versions
select netbios_name0, ProductName0
from v_R_System_Valid sys left join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)') and
	  ProductName0 in ('Microsoft Office Professional Plus 2007','Microsoft Office Professional Plus 2010','Microsoft Office 32-bit Components 2016')