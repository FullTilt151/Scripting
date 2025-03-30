select case 
        when LastState=0 then LastAcceptanceStateName 
        when LastState=-1 then LastAcceptanceStateName 
        else LastStateName 
        end as Status, 
       COUNT(*) as Count,  
       Advert.AdvertisementID, Advert.PackageName, OSD.SMSTSRole0 [Build]
from v_ClientAdvertisementStatus CAS left join
	dbo.v_AdvertisementInfo Advert on CAS.AdvertisementID = Advert.AdvertisementID left join
	v_GS_OSD640 OSD ON CAS.ResourceID = OSD.resourceid
where PackageName like 'Windows 7 - %' and 
	  PackageName not like '%Base Image%' and 
	  PackageName not like '%Build and Capture%' and 
	  DATEDIFF(hh,LastStatusTime, GetDate()) < 24
group by case 
        when LastState=0 then LastAcceptanceStateName 
        when LastState=-1 then LastAcceptanceStateName 
        else LastStateName 
        end, Advert.AdvertisementID, Advert.PackageName, OSD.SMSTSRole0