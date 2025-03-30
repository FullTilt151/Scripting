-- Count of expired deployments
select AssignedScheduleEnabled, ExpirationTimeEnabled, count(*) [Count]
from v_Advertisement
group by AssignedScheduleEnabled, ExpirationTimeEnabled

-- Expired pull deployments
select AdvertisementID, AdvertisementName, dep.PackageID, pkg.Name, pkg.Version, dep.ProgramName, dep.CollectionID
from v_Advertisement dep join
	 v_Package pkg on dep.PackageID = pkg.PackageID
where AssignedScheduleEnabled = 0 and ExpirationTimeEnabled = 2