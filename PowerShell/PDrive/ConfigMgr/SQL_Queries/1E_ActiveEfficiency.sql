-- Devices in AE
SELECT *
FROM Devices

-- Precache jobs
SELECT cdj.*, dg.externalid [Collection], cg.Name [PkgName], cg.ExternalId [PkgID]
FROM ContentDistributionJobs CDJ join
	 DeviceGroups DG on CDJ.DeviceGroupId = DG.Id join
	 ContentGroups CG on CDJ.ContentGroupId = CG.Id	 

-- Content information by package ID
SELECT *
FROM Contents
where ContentName = 'WQ1001CD'
order by Version desc

-- Content cached by package ID
SELECT cd.Id, ContentID, con.ContentName, con.Size, con.NumberOfFiles, con.Version, StartTime, DeviceId, EndTime, [Percent], dev.HostName, *
FROM ContentDeliveries CD join
	 Devices Dev on cd.DeviceId = dev.Id join
	 contents con on cd.ContentId = con.Id
--where ContentId = '0C66E578-9FFF-4B25-AA0D-4723E8C1975B'
where con.ContentName = 'WP10023A' 

-- Content cached on a subnet
select *
from reporting.NomadDeploymentSummary
where IPSubnet = '193.81.75.0'

-- AE locations
select * from Locationswhere Subnet = '193.81.75.0/24' 