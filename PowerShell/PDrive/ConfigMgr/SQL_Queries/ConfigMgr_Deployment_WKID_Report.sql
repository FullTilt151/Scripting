--Deployment count
select AdvertisementID, LastAcceptanceMessageIDName, LastAcceptanceStateName, LastStatusMessageIDName, LastStateName, count(*)
from v_ClientAdvertisementStatus join
	 v_r_system SYS ON v_ClientAdvertisementStatus.ResourceID = sys.ResourceID
where AdvertisementID = 'CAS23183'
group by AdvertisementID, LastAcceptanceMessageIDName, LastAcceptanceStateName, LastStatusMessageIDName, LastStateName

--Deployment List
select AdvertisementID, sys.Netbios_Name0, LastStatusMessageIDName, LastStateName, DATEADD(HOUR,-5, LastStatusTime) [LastStatusTime]
from v_ClientAdvertisementStatus join
	 v_r_system SYS ON v_ClientAdvertisementStatus.ResourceID = sys.ResourceID
where (Netbios_Name0 = 'KMGPB76T0P') AND
	  (AdvertisementID = 'CAS23183'
	  or AdvertisementID = 'CAS23184'
	  or AdvertisementID = 'CAS23185'
	  or AdvertisementID = 'CAS23186'
	  or AdvertisementID = 'CAS23187')
	  --and LastStateName != 'Succeeded'
order by AdvertisementID, LastStatusMessageIDName, Netbios_Name0

--Deployment List - Dups removed
select sys.Netbios_Name0, LastStatusMessageIDName, LastStateName, DATEADD(HOUR,-5, LastStatusTime) [LastStatusTime]
from v_ClientAdvertisementStatus join
	 v_r_system SYS ON v_ClientAdvertisementStatus.ResourceID = sys.ResourceID
where v_ClientAdvertisementStatus.ResourceID in 
		(
		SELECT     ResourceID
		FROM         v_ClientAdvertisementStatus
		WHERE     (
						AdvertisementID = 'CAS23183' OR
						AdvertisementID = 'CAS23184' OR
						AdvertisementID = 'CAS23185' OR
						AdvertisementID = 'CAS23186' OR
						AdvertisementID = 'CAS23187')
				   and LastStateName = 'Succeeded')
    and LastStateName = 'Succeeded'
    AND (
		AdvertisementID = 'CAS23183' OR
		AdvertisementID = 'CAS23184' OR
		AdvertisementID = 'CAS23185' OR
		AdvertisementID = 'CAS23186' OR
		AdvertisementID = 'CAS23187')
union
SELECT    DISTINCT sys.Netbios_Name0, LastStatusMessageIDName, LastStateName, DATEADD(HOUR,-5, LastStatusTime) [LastStatusTime]
FROM         v_ClientAdvertisementStatus CAS
join	v_R_System sys on sys.ResourceID = CAS.ResourceID
WHERE     (
				AdvertisementID = 'CAS23183' OR
				AdvertisementID = 'CAS23184' OR
                AdvertisementID = 'CAS23185' OR
                AdvertisementID = 'CAS23186' OR
                AdvertisementID = 'CAS23187')
           and cas.ResourceID not in (SELECT     ResourceID
FROM         v_ClientAdvertisementStatus
WHERE     (
				AdvertisementID = 'CAS23183' OR
				AdvertisementID = 'CAS23184' OR
                AdvertisementID = 'CAS23185' OR
                AdvertisementID = 'CAS23186' OR
                AdvertisementID = 'CAS23187')
           and LastStateName = 'Succeeded')
order by LastStateName, Netbios_Name0