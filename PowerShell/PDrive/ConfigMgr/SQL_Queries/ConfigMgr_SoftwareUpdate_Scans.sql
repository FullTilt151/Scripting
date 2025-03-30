-- Count of scans per hour
select DATEPART(HH, LastScanTime), count(*)
from v_UpdateScanStatus
where LastScanTime > '2019-02-21'
group by DATEPART(HH, LastScanTime)
order by DATEPART(HH, LastScanTime)

-- List of scan results since X time
select ScanPackageVersion, dateadd(hh,-5,CAST(LastScanTime as DATETIME)) [LastScanTime], LastStatusMessageID, LastErrorCode, CONVERT(varbinary(8),LastErrorCode)
from v_updatescanstatus
where dateadd(hh,-5,CAST(LastScanTime as DATETIME)) > SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 08, 00)
order by CAST(LastScanTime as DATETIME) desc

-- Count of scan results since X time
select LastErrorCode, CONVERT(varbinary(8),LastErrorCode), count(*)
from v_updatescanstatus
where dateadd(hh,-5,CAST(LastScanTime as DATETIME)) > SMALLDATETIMEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 08, 00)
group by LastErrorCode, CONVERT(varbinary(8),LastErrorCode)
order by LastErrorCode

-- Scan data for a WKID
SELECT Distinct STM.Netbios_Name0 [WKID],
    USS.LastScanPackageLocation,
    USS.LastScanTime,
    USS.LastStatusMessageID,
    CONVERT(varbinary(8),USS.LastErrorCode) [LastErrorCode],
    USS.ScanPackageVersion,
    STN.StateName
FROM v_r_system STM
JOIN v_UpdateScanStatus USS ON STM.ResourceID = USS.ResourceID
join v_StateNames STN on STN.StateID = USS.LastScanState
where stm.netbios_name0 = 'wkmj059g4b'
ORDER BY USS.LastScanTime DESC

-- List of clients with count of scan failures
select sys.Netbios_Name0 [Machine], count(*) [Failed installs]
from v_r_system SYS join
	 v_update_compliancestatusall CSA on sys.resourceid = csa.resourceid join
	 v_updateinfo UI on csa.CI_ID = ui.CI_ID
where status != '3' and
	  LastEnforcementMessageTime IS NOT NULL
group by sys.Netbios_Name0
order by count(*) desc