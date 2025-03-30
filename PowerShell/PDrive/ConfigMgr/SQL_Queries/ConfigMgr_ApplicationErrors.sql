-- Count of all errors last 7 days
select modulepath0, Module0,ProcessPath0, Process0, count(sys.Netbios_Name0)
from v_R_System_Valid sys join
	 v_GS_APPLICATION_ERRORS ERR on sys.ResourceID = err.ResourceID
where cast(TimeCreated0 as datetime) > DATEADD(dd,-7, getdate()) 
group by modulepath0, Module0,ProcessPath0,  Process0
order by count(sys.Netbios_Name0) desc

-- List of all errors last 7 days
select sys.Netbios_Name0, modulepath0, Module0,ProcessPath0,  Process0, TimeCreated0
from v_r_system_valid sys join
	 v_GS_APPLICATION_ERRORS ERR on sys.ResourceID = err.ResourceID
where cast(TimeCreated0 as datetime) > DATEADD(dd,-7, getdate())
order by cast(TimeCreated0 as datetime) desc

-- List of errors for a specific machine
select sys.Netbios_Name0, Process0, Module0, ModulePath0, TimeCreated0
from v_R_System_Valid sys join
	 v_GS_APPLICATION_ERRORS AE on sys.ResourceID = ae.ResourceID
where sys.Netbios_Name0 = 'WKMJ0CG5F9'
order by convert(date, TimeCreated0, 110) desc

-- List of errors last X days by OS and process and module
select sys.Netbios_Name0, 
	   case sys.Operating_System_Name_and0
	   WHEN 'Microsoft Windows NT Workstation 10.0' THEN 'Windows 10'
	   WHEN 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' THEN 'Windows 10'
	   WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
	   WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
	   WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
	   end [OS],
	   Process0, Module0, ModulePath0, TimeCreated0, DATEADD(dd, -30, timecreated0)
from v_R_System_Valid sys join
	 v_GS_APPLICATION_ERRORS AE on sys.ResourceID = ae.ResourceID
where TimeCreated0 > DATEADD(dd, -30, getdate()) and 
	  Process0 = 'SenseNTP.exe' --and Module0 = 'atgpcext.dll'
order by convert(date, TimeCreated0, 110) desc

-- Count of errors last X days by process and module
select distinct Process0, Module0, count(Netbios_Name0)
from v_R_System_Valid sys join
	 v_GS_APPLICATION_ERRORS AE on sys.ResourceID = ae.ResourceID
where TimeCreated0 > DATEADD(dd, -30, getdate()) and 
	  Process0 = 'SenseNTP.exe' --and Module0 != 'Unknown'
group by Process0, Module0
--having count(Netbios_Name0) > 5
order by count(Netbios_Name0) desc

-- Raw data for a process
select distinct sys.Name, sys.IsVirtualMachine, scum.TopConsoleUser0, usr.Mail0, sys.DeviceOS, sys.DeviceOSBuild, err.Module0, err.ModulePath0, err.Process0, err.ProcessPath0, err.TimeCreated0
from vSMS_CombinedDeviceResources sys inner join
	 v_GS_APPLICATION_ERRORS err on sys.MachineID = err.ResourceID left join
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP scum on sys.MachineID = scum.ResourceID left join
	 v_R_User usr on SUBSTRING(scum.TopConsoleUser0, CHARINDEX('\', scum.TopConsoleUser0)+1, 8) = usr.User_Name0
where Process0 = 'SenseNTP.exe'

-- Count of all errors each month for a process
SELECT s.Is_Virtual_Machine0
    , count(Is_Virtual_Machine0) [CountOfErrors]
    , month(DATEADD(MONTH, DATEDIFF(MONTH, 0, apperr.TimeCreated0), 0)) [Month]
	, year(DATEADD(year, DATEDIFF(YEAR, 0, apperr.TimeCreated0), 0)) [Year]
FROM v_GS_APPLICATION_ERRORS apperr
    JOIN v_R_System_Valid s ON s.ResourceID = apperr.ResourceID
WHERE Process0 = 'SenseNTP.exe' or Module0 = 'SenseNTP.exe'
    AND Is_Virtual_Machine0 IS NOT NULL
GROUP BY Is_Virtual_Machine0, DATEADD(MONTH, DATEDIFF(MONTH, 0, apperr.TimeCreated0), 0), DATEADD(year, DATEDIFF(YEAR, 0, apperr.TimeCreated0), 0)
ORDER BY [Year] desc,[Month] desc, s.Is_Virtual_Machine0

-- MDATP crashes with VDA
select sys.Netbios_Name0, sys.Build01, (select ProductName0 from v_GS_INSTALLED_SOFTWARE sft where ProductName0 in (
'Citrix 7.15 LTSR - Virtual Delivery Agent','Citrix 7.15 LTSR CU1 - Virtual Delivery Agent','Citrix 7.15 LTSR CU3 - Virtual Delivery Agent',
'Citrix 7.15 LTSR CU4 - Virtual Delivery Agent','Citrix Virtual Apps and Desktops 7 1912 LTSR - Virtual Delivery Agent','Citrix Virtual Apps and Desktops 7 1912 LTSR CU1 - Virtual Delivery Agent',
'Citrix Virtual Delivery Agent 7.16','Citrix Virtual Delivery Agent 7.6.300','Citrix Virtual Delivery Agent 7.9') and sys.resourceid = sft.ResourceID) [VDA], 
	err.Module0, err.ModulePath0, err.Process0, err.ProcessPath0, err.TimeCreated0
from v_R_System sys inner join
	 v_GS_APPLICATION_ERRORS err on sys.ResourceID = err.ResourceID
where process0 = 'SenseNTP.exe' or module0 = 'SenseNTP.exe'

-- All webex crashes with model
select distinct sys.Netbios_Name0, csp.version0, err.process0, err.ProcessPath0, err.TimeCreated0
from v_R_System_Valid sys inner join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID left join
	 v_GS_PNP_SIGNED_DRIVER_CUSTOM drv on sys.ResourceID = drv.ResourceID left join
	 v_GS_APPLICATION_ERRORS err on sys.ResourceID = err.ResourceID
where process0 in (
'ptoneclk.exe','ptOIEx.exe','ptSrv.exe','ptUpdate.exe','ptpluginhost.exe',
'WebexMTA.exe','PTIM.exe','CiscoWebExStart.exe','ptMeetingsHost.exe','atmgr.exe',
'ptWbxONI.exe','webexAppLauncher.exe'
) and TimeCreated0 > DATEADD(dd, -60, getdate()) and DeviceName0 in (
'Intel(R) HD Graphics 520',
'Intel(R) HD Graphics 620',
'Intel(R) UHD Graphics 620'
)