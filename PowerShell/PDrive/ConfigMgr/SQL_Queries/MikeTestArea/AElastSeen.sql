SELECT b.hostname,[Name],[Category],[StringValue],[DeviceId],[Index]
FROM [ActiveEfficiency].[dbo].[DeviceTags] as a  inner join dbo.devices as b on a.deviceid = b.id  
WHERE [Name] = 'lastseen' and hostname = 'WKPBDNEHB'