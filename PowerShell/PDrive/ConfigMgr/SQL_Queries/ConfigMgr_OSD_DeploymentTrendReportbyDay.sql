Declare @Timeframe int
set @Timeframe = 45

select	CONVERT(char(10),laststatustime,126) as [Date],
		case 
                when LastState=0 then LastAcceptanceStateName 
                when LastState=-1 then LastAcceptanceStateName 
                else LastStateName 
                end as [Status], 
       COUNT(*) as Count
from v_ClientAdvertisementStatus inner join
                dbo.v_AdvertisementInfo Advert on v_ClientAdvertisementStatus.AdvertisementID = Advert.AdvertisementID
where PackageName like 'Windows 7 - %' and PackageName not like '%Base Image%' and PackageName not like '%Build and Capture%' and DATEDIFF(DD,LastStatusTime, GetDate()) < @Timeframe
group by CONVERT(char(10),laststatustime,126), case 
                when LastState=0 then LastAcceptanceStateName 
                when LastState=-1 then LastAcceptanceStateName 
                else LastStateName 
                end
Order by CONVERT(char(10),laststatustime,126) desc
