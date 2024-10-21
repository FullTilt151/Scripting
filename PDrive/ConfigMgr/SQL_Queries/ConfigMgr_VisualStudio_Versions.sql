--Visual Studio 2005
select CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		END as [OS],
		ARPDisplayName0, Count (ARPDisplayName0)
from v_gs_installed_software INNER JOIN
	 v_r_system ON v_gs_installed_software.ResourceID = v_r_system.ResourceID
where ARPDisplayName0 = 'Microsoft Visual Studio 2005 Professional Edition - ENU' OR
      ARPDisplayName0 = 'Microsoft Visual Studio 2005 Premier Partner Edition - ENU'
GROUP BY CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		END, ARPDisplayName0
ORDER BY ARPDisplayName0


--Visual Basic
select CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		END as [OS],
		ARPDisplayName0, Count (ARPDisplayName0)
from v_gs_installed_software INNER JOIN
	 v_r_system ON v_gs_installed_software.ResourceID = v_r_system.ResourceID
where ARPDisplayName0 = 'Microsoft Visual Basic 6.0 Professional Edition' OR
      ARPDisplayName0 = 'Microsoft Visual Basic for Applications 7.1 (x64)' OR
	  ARPDisplayName0 = 'Microsoft Visual Basic for Applications 7.1 (x86)' OR
	  ARPDisplayName0 = 'Visual Basic for Applications (R) Core'
GROUP BY CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		END, ARPDisplayName0
ORDER BY ARPDisplayName0


--Visual Studio .NET 2003 versions
select CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		END as [OS],
		ARPDisplayName0, Count (ARPDisplayName0)
from v_gs_installed_software INNER JOIN
	 v_r_system ON v_gs_installed_software.ResourceID = v_r_system.ResourceID
where ARPDisplayName0 = 'Microsoft Visual Studio .NET Enterprise Developer 2003 - English' OR
	  ARPDisplayName0 = 'Microsoft Visual Studio .NET Enterprise Architect 2003 - English' OR
	  ARPDisplayName0 = 'Microsoft Visual Studio .NET Professional 2003 - English' OR
	  ARPDisplayName0 = 'Visual Studio .NET Enterprise Architect 2003 - English' OR
	  ARPDisplayName0 = 'Visual Studio .NET Enterprise Developer 2003 - English' OR
	  ARPDisplayName0 = 'Visual Studio .NET Professional 2003 - English' OR
	  ARPDisplayName0 = 'Visual Studio.NET Baseline - English'
GROUP BY CASE Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		END, ARPDisplayName0
ORDER BY ARPDisplayName0


select Distinct ProductName
from v_MeteredFiles
where (FileName = 'devenv.exe' OR FileName = 'vb6.exe')
--AND ProductName NOT LIKE '%2010%' AND ProductName NOT LIKE '%2008%' AND ProductName NOT LIKE '%2012%'


select SYS.Netbios_Name0 [WKID], 
		CASE SYS.Operating_System_Name_and0
		WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
		WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
		WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
		END AS 'OS', 
		MU.UserName, US.Full_User_Name0 [Friendly name], ProductName, SF.FileDescription, MF.FileName, MF.FileVersion, MF.MeteredFileVersion [File Info], SF.FilePath, SM.UsageCount [Times Used], SM.LastUsage
from v_MonthlyUsageSummary SM FULL JOIN
	 v_MeteredFiles MF ON MF.MeteredFileID = SM.FileID FULL JOIN
	 v_MeteredUser MU ON MU.MeteredUserID = SM.MeteredUserID FULL JOIN
	 v_r_user US ON US.User_Name0 = MU.UserName FULL JOIN
	 v_r_system SYS ON SM.ResourceID = SYS.ResourceID FULL JOIN
	 v_GS_SoftwareFile SF ON SM.ResourceID = SF.ResourceID
where SF.FileName = 'devenv.exe' and SM.FileID = SF.FileID
order by SM.LastUsage DESC

select distinct SYS.Netbios_Name0 [WKID], 
	   case sys.Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   end as [OS], sf.FileName, sf.FileDescription, sf.FileVersion, sf.FilePath
from v_r_system SYS join
v_GS_SoftwareFile SF ON SYS.ResourceID = SF.ResourceID
where sys.Operating_System_Name_and0 like '%workstation%' and SF.filename = 'devenv.exe'and
SF.resourceid NOT IN (
select distinct ResourceID
from v_GS_CCM_RECENTLY_USED_APPS
where ExplorerFileName0 = 'devenv.exe')
order by sys.Netbios_Name0, FileVersion, FilePath

select distinct SYS.Netbios_Name0 [WKID]
from v_r_system SYS join
v_GS_SoftwareFile SF ON SYS.ResourceID = SF.ResourceID
where sys.Operating_System_Name_and0 like '%workstation%' and SF.filename = 'devenv.exe'and
SF.resourceid NOT IN (
select distinct ResourceID
from v_GS_CCM_RECENTLY_USED_APPS
where ExplorerFileName0 = 'devenv.exe')
order by sys.Netbios_Name0

-- Count of versions on Win7
select distinct 
		case productname0
			when 'Microsoft Visual Studio Enterprise 2015' then '2015 Enterprise'
			when 'Microsoft Visual Studio Premium 2012' then '2012 Premium'
			when 'Microsoft Visual Studio Premium 2013' then '2013 Premium'
			when 'Microsoft Visual Studio Premium 2015' then '2015 Premium'
			when 'Microsoft Visual Studio Professional 2012' then '2012 Pro'
			when 'Microsoft Visual Studio Professional 2013' then '2013 Pro'
			when 'Microsoft Visual Studio Professional 2015' then '2015 Pro'
			when 'Microsoft Visual Studio Ultimate 2012' then '2012 Ultimate'
			when 'Microsoft Visual Studio Ultimate 2013' then '2013 Ultimate'
			else 'Unknown' 
			end [VS], count(sys.resourceid)
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.resourceid = sft.resourceid
where productname0 in (
'Microsoft Visual Studio Enterprise 2015',
'Microsoft Visual Studio Premium 2012',
'Microsoft Visual Studio Premium 2013',
'Microsoft Visual Studio Premium 2015',
'Microsoft Visual Studio Professional 2012',
'Microsoft Visual Studio Professional 2013',
'Microsoft Visual Studio Professional 2015',
'Microsoft Visual Studio Ultimate 2012',
'Microsoft Visual Studio Ultimate 2013'
) 
and operating_system_name_and0 in ('Microsoft Windows NT Workstation 6.1', 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)')
group by case productname0
			when 'Microsoft Visual Studio Enterprise 2015' then '2015 Enterprise'
			when 'Microsoft Visual Studio Premium 2012' then '2012 Premium'
			when 'Microsoft Visual Studio Premium 2013' then '2013 Premium'
			when 'Microsoft Visual Studio Premium 2015' then '2015 Premium'
			when 'Microsoft Visual Studio Professional 2012' then '2012 Pro'
			when 'Microsoft Visual Studio Professional 2013' then '2013 Pro'
			when 'Microsoft Visual Studio Professional 2015' then '2015 Pro'
			when 'Microsoft Visual Studio Ultimate 2012' then '2012 Ultimate'
			when 'Microsoft Visual Studio Ultimate 2013' then '2013 Ultimate'
			else 'Unknown' 
			end
order by [VS]

-- Count of versions total
select case sys.Operating_System_Name_and0
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		end [OS], 
		case sft.productname0
		when 'Microsoft Visual Studio 2010 Premium - ENU' then 'Premium'
		when 'Microsoft Visual Studio 2010 Professional - ENU' then 'Pro'
		when 'Microsoft Visual Studio Enterprise 2015' then 'Enterprise'
		when 'Microsoft Visual Studio Premium 2012' then 'Premium'
		when 'Microsoft Visual Studio Premium 2013' then 'Premium'
		when 'Microsoft Visual Studio Premium 2015' then 'Premium'
		when 'Microsoft Visual Studio Professional 2012' then 'Pro'
		when 'Microsoft Visual Studio Professional 2013' then 'Pro'
		when 'Microsoft Visual Studio Professional 2015' then 'Pro'
		when 'Microsoft Visual Studio 2010 Ultimate - ENU' then 'Ultimate'
		when 'Microsoft Visual Studio Ultimate 2012' then 'Ultimate'
		when 'Microsoft Visual Studio Ultimate 2013' then 'Ultimate'
		when 'Microsoft Visual Studio 2017' then '2017'
		end [VS], 
	ProductName0, count(*) [Count]
from v_R_System_Valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 in (
'Microsoft Visual Studio 2010 Premium - ENU',
'Microsoft Visual Studio 2010 Professional - ENU',
'Microsoft Visual Studio Enterprise 2015',
'Microsoft Visual Studio Premium 2012',
'Microsoft Visual Studio Premium 2013',
'Microsoft Visual Studio Premium 2015',
'Microsoft Visual Studio Professional 2012',
'Microsoft Visual Studio Professional 2013',
'Microsoft Visual Studio Professional 2015',
'Microsoft Visual Studio 2010 Ultimate - ENU',
'Microsoft Visual Studio Ultimate 2012',
'Microsoft Visual Studio Ultimate 2013',
'Microsoft Visual Studio 2017'
) and Operating_System_Name_and0 in (
'Microsoft Windows NT Workstation 6.1',
'Microsoft Windows NT Workstation 6.1 (Tablet Edition)',
'Microsoft Windows NT Workstation 10.0',
'Microsoft Windows NT Workstation 10.0 (Tablet Edition)'
)
group by case sys.Operating_System_Name_and0
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		end, case sft.productname0
		when 'Microsoft Visual Studio 2010 Premium - ENU' then 'Premium'
		when 'Microsoft Visual Studio 2010 Professional - ENU' then 'Pro'
		when 'Microsoft Visual Studio Enterprise 2015' then 'Enterprise'
		when 'Microsoft Visual Studio Premium 2012' then 'Premium'
		when 'Microsoft Visual Studio Premium 2013' then 'Premium'
		when 'Microsoft Visual Studio Premium 2015' then 'Premium'
		when 'Microsoft Visual Studio Professional 2012' then 'Pro'
		when 'Microsoft Visual Studio Professional 2013' then 'Pro'
		when 'Microsoft Visual Studio Professional 2015' then 'Pro'
		when 'Microsoft Visual Studio 2010 Ultimate - ENU' then 'Ultimate'
		when 'Microsoft Visual Studio Ultimate 2012' then 'Ultimate'
		when 'Microsoft Visual Studio Ultimate 2013' then 'Ultimate'
		when 'Microsoft Visual Studio 2017' then '2017'
		end, 
		ProductName0
order by [OS], [VS]

