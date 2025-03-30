select Netbios_Name0 [WKID], Operating_System_Name_and0 [OS], 
(select productname0 from v_gs_installed_software sft where productname0 in 
('Microsoft Office Professional Edition 2003',
'Microsoft Office Project Standard 2003',
'Microsoft Office Standard Edition 2003') and sys.ResourceID = sft.ResourceID) [Office 2003]
from v_r_system_valid sys
where Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1'
order by Netbios_Name0