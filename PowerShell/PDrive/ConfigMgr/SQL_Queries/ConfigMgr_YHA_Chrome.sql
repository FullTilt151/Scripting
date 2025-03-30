select distinct netbios_name0, sft.productname0, sft.productversion0
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.resourceid = sft.resourceid join
	 v_RA_System_SystemOUName ou on sys.ResourceID = ou.ResourceID
where ProductName0 = 'Google Chrome' and System_OU_Name0 in (
'HUMAD.COM/YHA',
'HUMAD.COM/YHA/COMPUTERS',
'HUMAD.COM/YHA/COMPUTERS/DESKTOPS',
'HUMAD.COM/YHA/COMPUTERS/LAPTOPS',
'HUMAD.COM/YHA/COMPUTERS/LAPTOPS/ADMINACCESS')