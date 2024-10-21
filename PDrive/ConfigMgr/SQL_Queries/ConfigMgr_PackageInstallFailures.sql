-- Advert list by package ID
select *
from v_AdvertisementInfo
where packageid = 'WQ100ABB'
order by PresentTime desc

-- WKID list with failures
select sys.Netbios_Name0, cas.LastStatusMessageIDName, cas.LastStateName, cas.LastStatusTime, cas.LastExecutionResult
from v_R_System sys inner join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID inner join
	 v_GS_INSTALLED_SOFTWARE sft on cas.ResourceID = sft.ResourceID
where AdvertisementID in (select AdvertisementID from v_AdvertisementInfo where packageid = 'WQ100ABB') and
	  LastStateName not in ('Succeeded','No messages have been received','No status') and
	  sft.ProductName0 = 'MOVE AV 4.6.0 Multi-Platform Client'
order by sys.Netbios_Name0

-- Count of failures
select cas.LastStatusMessageIDName, cas.LastStateName, cas.LastExecutionResult, count(*) [Count]
from v_R_System sys inner join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID inner join
	 v_GS_INSTALLED_SOFTWARE sft on cas.ResourceID = sft.ResourceID
where AdvertisementID in (select AdvertisementID from v_AdvertisementInfo where packageid = 'WQ100ABB') and
	  LastStateName not in ('Succeeded','No messages have been received','No status') and
	  sft.ProductName0 = 'MOVE AV 4.6.0 Multi-Platform Client'
group by cas.LastStatusMessageIDName, cas.LastStateName, cas.LastExecutionResult
order by cas.LastStatusMessageIDName, cas.LastStateName, cas.LastExecutionResult