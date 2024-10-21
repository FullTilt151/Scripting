-- Devices in AE
SELECT *
FROM Devices

-- Precache jobs
SELECT cdj.*, dg.externalid [Collection], cg.Name [PkgName], cg.ExternalId [PkgID]
FROM ContentDistributionJobs CDJ join
	 DeviceGroups DG on CDJ.DeviceGroupId = DG.Id join
	 ContentGroups CG on CDJ.ContentGroupId = CG.Id	 
Where cdj.Id = '41270D37-028E-42F4-8D34-08040C1E89B6'

-- Content information by package ID
SELECT *
FROM Contents
where ContentName = 'WP10045D'
order by Version desc

Select *
from ContentDeliveries
where ContentId = '41270D37-028E-42F4-8D34-08040C1E89B6'

-- Content cached by package ID
SELECT cd.Id, ContentID, con.ContentName, con.Size, con.NumberOfFiles, con.Version, StartTime, DeviceId, EndTime, [Percent], dev.HostName, *
FROM ContentDeliveries CD join
	 Devices Dev on cd.DeviceId = dev.Id join
	 contents con on cd.ContentId = con.Id
--where ContentId = '41270D37-028E-42F4-8D34-08040C1E89B6'
where con.ContentName = 'WP10045D' 

-- Content cached by package ID modified
SELECT dev.HostName, con.ContentName, con.Version, cd.Id, ContentID, con.Size, con.NumberOfFiles, StartTime, EndTime, [Percent] --, dev.HostName, *
FROM ContentDeliveries CD join
	 Devices Dev on cd.DeviceId = dev.Id join
	 contents con on cd.ContentId = con.Id
--where ContentId = '41270D37-028E-42F4-8D34-08040C1E89B6'
where con.ContentName = 'WP10045D'
order by HostName