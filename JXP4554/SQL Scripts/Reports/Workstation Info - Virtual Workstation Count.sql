SELECT sys.netbios_name0 [WKID],
	sys.Resource_Domain_OR_Workgr0 [Domain],
	sys.AD_Site_Name0 [AD Site],
	OSC.[DisplayName] [OS]
FROM v_r_system SYS
JOIN Humana_OS_Caption_DisplayName OSC ON SYS.Operating_System_Name_and0 = OSC.Caption
WHERE client0 = 1
	AND is_virtual_machine0 = 1
	AND Operating_System_Name_and0 LIKE 'Microsoft Windows NT Workstation%'
ORDER BY netbios_name0,
	Domain,
	OS
