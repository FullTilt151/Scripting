--AE info for LOUXDWSTDB1796
SELECT
  Category,
  Name,
  StringValue
FROM DeviceTags
WHERE DeviceId = '2571abc7-b03b-4bb0-9b5e-a6765de7f7d8'

--AE apps for LOUXDWSTDB1796 (oracle)
SELECT
  COALESCE(Publisher, '') Publisher,
  ApplicationName,
  COALESCE(Version, '') Version
FROM Installations
WHERE DeviceId = '2571abc7-b03b-4bb0-9b5e-a6765de7f7d8' and ApplicationName like '%documaker%'

--AE usage
SELECT
  Publisher,
  ApplicationName,
  ApplicationVersion,
  FileDescription,
  ExeName,
  ProductCode,
  LastRunDate,
  FileSize
FROM ApplicationUsage
WHERE DeviceId = '2571abc7-b03b-4bb0-9b5e-a6765de7f7d8' and Publisher like '%oracle%' and ApplicationName = 'dmstudio'