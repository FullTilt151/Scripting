--CM-SoftwareINV
SELECT DISTINCT
  publisher00 Publisher,
  displayname00 DisplayName,
  version00 Version
FROM Add_Remove_Programs_data
UNION
SELECT DISTINCT
  publisher00,
  displayname00,
  version00
FROM Add_Remove_Programs_64_data


--CM DISTINCT devices for particular software
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
AND ((Publisher0 = ''
AND DisplayName0 = 'Nuance PDF Create 7'
AND Version0 = '7.00.2164')
OR (Publisher0 = ''
AND DisplayName0 = 'Scansoft PDF Create'
AND Version0 = '')
OR (Publisher0 = 'Nuance Communications, Inc.'
AND DisplayName0 = 'Nuance PDF Create 8'
AND Version0 = '8.10.6293')
OR (Publisher0 = 'Nuance Communications, Inc'
AND DisplayName0 = 'Nuance PDF Create 7'
AND Version0 = '7.00.2164'))

--CM devices for particular software
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
WHERE COALESCE(Active0, 0) = 1
AND COALESCE(Client0, 0) = 1
AND COALESCE(Obsolete0, 0) = 0
AND COALESCE(Decommissioned0, 0) = 0
AND COALESCE(Publisher0, '') = 'Nuance Communications, Inc.'
AND COALESCE(DisplayName0, '') = 'Nuance PDF Create 8'
AND COALESCE(Version0, '') = '8.10.6293'

--CM Usage for a particular device
SELECT
  CompanyName0 Publisher,
  ProductName0 Product,
  ProductVersion0 Version,
  LastUsedTime0 LastUsedTime
FROM v_gs_ccm_recently_Used_apps
WHERE ResourceId = 16777504
