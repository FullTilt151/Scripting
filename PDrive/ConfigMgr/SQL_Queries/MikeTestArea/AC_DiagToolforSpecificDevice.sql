--CM SQL from AC diag tool
SELECT 
  CONVERT(date, lasthwscan) LastSyncDate,
  COUNT(*) DeviceCount
FROM v_gs_workstation_status
GROUP BY CONVERT(date, lasthwscan)
ORDER BY COUNT(*) DESC


select * 
from v_GS_WORKSTATION_STATUS
where ResourceID = 16910570

select * 
from v_R_System_Valid
where Netbios_Name0 = 'LOUXDWSTDB1796'

--CM Software Inventory
SELECT DISTINCT
  publisher00 Publisher,
  displayname00 DisplayName,
  version00 Version
FROM Add_Remove_Programs_data
where MachineID = 16910570
UNION
SELECT DISTINCT
  publisher00,
  displayname00,
  version00
FROM Add_Remove_Programs_64_data
where MachineID = 16910570

select *
from Add_Remove_Programs_DATA
where MachineID = 16910570 and Publisher00 like '%oracle%'
--where DisplayName00 like '%documaker%'

SELECT
  vrs.ResourceId,
  Name0 HostName,
  CASE
    WHEN ISDATE(installdate0) = 0 THEN NULL
    ELSE CONVERT(datetime, installdate0)
  END installdate
FROM v_r_system vrs
JOIN v_add_remove_programs a
  ON a.resourceid = vrs.resourceid
  where vrs.ResourceID = 16910570
AND COALESCE(Active0, 0) = 1
AND COALESCE(Client0, 0) = 1
AND COALESCE(Obsolete0, 0) = 0
AND COALESCE(Decommissioned0, 0) = 0
AND COALESCE(Publisher0, '') = ''
AND COALESCE(DisplayName0, '') = ''
AND COALESCE(Version0, '') = '07/27/2012 7.0.0.0'

select *
from v_R_System
where ResourceID = 16910570

