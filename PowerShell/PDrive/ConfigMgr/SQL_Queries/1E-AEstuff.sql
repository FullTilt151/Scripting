SELECT *
  FROM [ActiveEfficiency].[dbo].[DeviceIdentities] IDNT
  join devicetags TAGS on IDNT.DeviceId = TAGS.DeviceId
Where [Identity] like 'LOUXDWSTDB0940%'
and TAGS.Name = 'UniqueID'



Select *
FROM DeviceIdentities
Where [Identity] like 'LOUXDWSTDB094%'