--Queries from CM part of diag tool.
--Server status queries and SW inv
SELECT
  CONVERT(date, lasthwscan) LastSyncDate,
  COUNT(*) DeviceCount
FROM v_gs_workstation_status
GROUP BY CONVERT(date, lasthwscan)
ORDER BY COUNT(*) DESC

--check when '2025 ran it's HW scan
select *
from v_GS_WORKSTATION_STATUS
where ResourceID = 16920825


--get ResourceID of LOUXDWSTDB2025
select *
from v_R_System_Valid
where Netbios_Name0 = 'LOUXDWSTDB2025'

--SW Inv (changed to find Oracle Documaker
SELECT DISTINCT
  publisher00 Publisher,
  displayname00 DisplayName,
  version00 Version
FROM Add_Remove_Programs_data
where DisplayName00 like 'Oracle Documaker 12.5.00.29909%'
UNION
SELECT DISTINCT
  publisher00,
  displayname00,
  version00
FROM Add_Remove_Programs_64_data
where DisplayName00 like 'Oracle Documaker 12.5.00.29909%'


--2nd query
SELECT DISTINCT
  vrs.ResourceId,
  Name0 HostName
FROM v_r_system vrs
JOIN v_add_remove_programs a
  ON a.resourceid = vrs.resourceid
WHERE COALESCE(Active0, 0) = 1
AND COALESCE(Client0, 0) = 1
AND COALESCE(Obsolete0, 0) = 0
AND COALESCE(Decommissioned0, 0) = 0
AND (Publisher0 = 'Oracle Insurance'
AND DisplayName0 = 'Oracle Documaker 12.5.00.29909')
AND Netbios_Name0 = 'LOUXDWSTDB2025'

SELECT
  CompanyName0 Publisher,
  ProductName0 Product,
  ProductVersion0 Version,
  LastUsedTime0 LastUsedTime
FROM v_gs_ccm_recently_Used_apps
WHERE ResourceId = 16818409 and CompanyName0 like 'Oracle%'



