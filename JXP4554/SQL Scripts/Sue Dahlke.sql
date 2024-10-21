SELECT sys.Netbios_Name0 [WKID],
	CASE sys.Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 10.0'
			THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)'
			THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)'
			THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 6.3'
			THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)'
			THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.1'
			THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 5.1'
			THEN 'Windows XP'
		END [OS],
	Process0,
	Module0,
	ModulePath0,
	TimeCreated0,
	DATEDIFF(dd, timecreated0,getdate()) [Days since inventory]
FROM v_R_System_Valid sys
JOIN v_GS_APPLICATION_ERRORS AE ON sys.ResourceID = ae.ResourceID
WHERE DATEDIFF(dd, timecreated0,getdate()) <= 7 and 
	Process0 in ('humwin.exe','Gatherer.exe','Titus.Enterprise.HealthMonitor.Console.exe')
	--AND Module0 = 'atgpcext.dll'
	AND sys.Netbios_Name0 IN ('WKMJ07ADJ9', 'WKMJ02W4F5')
ORDER BY convert(DATE, TimeCreated0, 110) DESC
