--These came from troubleshooting precache info for machine not having all the packages
Select *
from ContentDistributionJobs
where Id = '2C298F84-4532-426A-B056-7532C721A827'

select DGM.DeviceGroupId, DEV.HostName  
from DeviceGroupMembership DGM join Devices DEV on DGM.DeviceId = DEV.Id 
where DeviceGroupId='B0CD4CF4-51FB-4B65-A424-112523DD6DD7'
order by HostName

SELECT c.ContentName, c.[Version], c.Size, c.NumberOfFiles, c.[Hash] FROM Contents c
       JOIN ContentDeliveries cd
              ON c.Id = cd.ContentId
       JOIN Devices d
              ON cd.DeviceId = d.Id
       WHERE d.HostName = 'DSIPXEWPW17' --and ContentName = 'cas00f6c'
	   order by ContentName