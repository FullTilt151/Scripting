-- MSXML version by WKID
select netbios_name0, ARPDisplayName0, ProductVersion0
from v_r_system INNER JOIN
	 v_gs_installed_software ON v_r_system.resourceid = v_GS_INSTALLED_SOFTWARE.ResourceID
where ARPDisplayName0 like '%MSXML%' and
		netbios_name0 = 'WKMJABGRY'
order by netbios_name0, ARPDisplayName0, ProductVersion0

--IE version by WKID
SELECT netbios_name0,  CASE SYS.Operating_System_Name_and0
					WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
					WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
					WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
					WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
					END as [OS], 
						 IE.Build0, IE.svcKBNumber0,IE.svcUpdateVersion0, IE.svcVersion0
FROM            dbo.v_R_System SYS FULL JOIN
                         dbo.v_GS_InternetExplorer640 IE ON SYS.ResourceID = IE.ResourceID
WHERE netbios_name0 = 'WKMJ13NPF' or
	  netbios_name0 = 'WKMJVZBCH' or
	  netbios_name0 = 'WKMJWKTMP' or
	  netbios_name0 = 'WKMJHZRH6' or
	  netbios_name0 = 'WKMJ94R09' or
	  netbios_name0 = 'WKMJABGRY'
ORDER BY OS, build0, svcUpdateVersion0, IE.svcVersion0 DESC