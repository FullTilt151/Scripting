-- Original query
select ResourceID, powershellversion0
from v_GS_PowerShell0

-- Workstation counts by OS
WITH CTE AS (SELECT   ResourceID, MAX(PowerShellVersion0) AS Version
             FROM            v_GS_PowerShell0
             GROUP BY ResourceID)
SELECT CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 10.0' THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' THEN 'Windows 10'
		END as [OS]
		, CTE.Version [PowerShell Version], COUNT(SYS.ResourceID) AS Total
FROM CTE FULL JOIN
	 v_r_system SYS ON CTE.ResourceID = SYS.ResourceID
WHERE SYS.Operating_System_Name_and0 like '%workstation%'
	  and sys.Client0 = '1'
GROUP BY CASE operating_system_name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 10.0' THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' THEN 'Windows 10'
		END, CTE.Version
ORDER BY OS, CTE.Version

-- Server counts by OS
WITH CTE AS (SELECT   ResourceID, MAX(PowerShellVersion0) AS Version
             FROM            v_GS_PowerShell0
             GROUP BY ResourceID)
SELECT CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Advanced Server 5.2' THEN 'Server 2003'
		WHEN 'Microsoft Windows NT Advanced Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Advanced Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Advanced Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Advanced Server 6.3' THEN 'Server 2012 R2'
		WHEN 'Microsoft Windows NT Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Server 6.3' THEN 'Server 2012 R2'
		END as [OS]
		, CTE.Version [PowerShell Version], COUNT(SYS.ResourceID) AS Total
FROM CTE FULL JOIN
	 v_R_System_Valid SYS ON CTE.ResourceID = SYS.ResourceID
WHERE (SYS.Operating_System_Name_and0 like 'Microsoft Windows NT Server%' or
	  SYS.Operating_System_Name_and0 like 'Microsoft Windows NT Advanced Server%')
GROUP BY case Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Advanced Server 5.2' THEN 'Server 2003'
		WHEN 'Microsoft Windows NT Advanced Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Advanced Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Advanced Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Advanced Server 6.3' THEN 'Server 2012 R2'
		WHEN 'Microsoft Windows NT Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Server 6.3' THEN 'Server 2012 R2'
		END,
		CTE.Version
ORDER BY OS, CTE.Version

-- PoSH version for a device
WITH CTE AS (SELECT   ResourceID, MAX(PowerShellVersion0) [PoSH Version]
             FROM            v_GS_PowerShell0
             GROUP BY ResourceID)
SELECT netbios_name0 [Name], Resource_Domain_OR_Workgr0 [Domain],  
	   CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 10.0' THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Advanced Server 5.2' THEN 'Server 2003'
		WHEN 'Microsoft Windows NT Advanced Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Advanced Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Advanced Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Advanced Server 6.3' THEN 'Server 2012 R2'
		WHEN 'Microsoft Windows NT Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Server 6.3' THEN 'Server 2012 R2'
		END as [OS],
		cte.[PoSH Version]
FROM CTE FULL JOIN
	 v_r_system SYS ON CTE.ResourceID = SYS.ResourceID
where sys.Netbios_Name0 = @CompName

-- Posh v2
select CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 10.0' THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Advanced Server 5.2' THEN 'Server 2003'
		WHEN 'Microsoft Windows NT Advanced Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Advanced Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Advanced Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Advanced Server 6.3' THEN 'Server 2012 R2'
		WHEN 'Microsoft Windows NT Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Server 6.3' THEN 'Server 2012 R2'
		END as [OS], posh.PowerShellVersion0, count(*) [Count]
from v_R_System_Valid sys left join
	 v_GS_PowerShell0 posh on sys.ResourceID = posh.resourceid
where PowerShellVersion0 = '2.0'
group by CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)' THEN 'Windows 8'
		WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
		WHEN 'Microsoft Windows NT Workstation 10.0' THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' THEN 'Windows 10'
		WHEN 'Microsoft Windows NT Advanced Server 5.2' THEN 'Server 2003'
		WHEN 'Microsoft Windows NT Advanced Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Advanced Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Advanced Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Advanced Server 6.3' THEN 'Server 2012 R2'
		WHEN 'Microsoft Windows NT Server 6.0' THEN 'Server 2008'
		WHEN 'Microsoft Windows NT Server 6.1' THEN 'Server 2008 R2'
		WHEN 'Microsoft Windows NT Server 6.2' THEN 'Server 2012'
		WHEN 'Microsoft Windows NT Server 6.3' THEN 'Server 2012 R2'
		END, posh.PowerShellVersion0
order by [os]