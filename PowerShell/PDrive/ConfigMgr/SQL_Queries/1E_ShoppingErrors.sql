-- List of WKIDS and Shopping status
select sys.Netbios_Name0, cas.AdvertisementID, adv.PackageID, PackageManufacturer, PackageName, PackageVersion, ProgramName, CollectionID, CollectionName,
	cas.LastAcceptanceMessageIDName, LastAcceptanceStateName, LastAcceptanceStatusTime, LastStatusMessageIDName, LastStateName, LastStatusTime, LastExecutionResult
from v_r_system sys left join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID left join
	 v_AdvertisementInfo adv on cas.AdvertisementID = adv.AdvertisementID
where cas.AdvertisementID in (
select distinct cas.AdvertisementID
from v_r_system sys left join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID left join
	 v_AdvertisementInfo adv on cas.AdvertisementID = adv.AdvertisementID
where CollectionName like 'WP1%' and PackageName = 'Visio Professional')