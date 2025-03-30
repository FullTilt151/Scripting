select count(distinct resourceid)
from v_GS_IIS_APP_POOLS_CUSTOM

-- Count of AppPool recycle schedules by App Pool
select recyclingschedule0, count(distinct resourceid) [Count]
from v_GS_IIS_APP_POOLS_CUSTOM
group by recyclingschedule0
order by count(distinct resourceid) desc

-- List of servers and AppPool IIS settings
select sys.Netbios_Name0, sys.Operating_System_Name_and0, iis.applist0, iis.poolname0, iis.recyclingschedule0, iis.recyclingtime0
from v_R_System_Valid sys join
	 v_GS_IIS_APP_POOLS_CUSTOM iis on sys.ResourceID = iis.ResourceID
where applist0 not like '%humweb%' and applist0 not like '%etpservices%' and applist0 not like '%systemtools%' and applist0 not like '%ftp%' and applist0 is not null and applist0 != ''