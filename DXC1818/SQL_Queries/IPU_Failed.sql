SELECT
Case	
		When RV.Netbios_Name0 LIKE 'WKMJ%'then 'Desktop'
		When RV.Netbios_Name0 LIKE 'TR%' then 'Desktop'
		When RV.Netbios_Name0 LIKE 'WKP%' then 'Laptop'
		When RV.Netbios_Name0 LIKE 'WKR%' then 'Laptop'
		When RV.Netbios_Name0 LIKE 'WKMP%' then 'Laptop'
		When RV.Netbios_Name0 LIKE 'LOUXDW%' then 'VM'
		When RV.Netbios_Name0 LIKE 'SIMXDW' then 'VM'
		Else 'Unknown'
End
Chassis,
Netbios_Name0 AS WKID,
AdvertisementID,
[LastStateName],
User_Name0 AS USERID
FROM [v_R_System_Valid] RV
JOIN [vSMS_ClientAdvertisementStatus] Numbers
ON Numbers.[ResourceID] = RV.[ResourceID]
where AdvertisementID IN ('WP126E4B','WP126E97','WP126D9D','WP126D84','WP126D99','WP126D98','WP126D97','WP126D88')
and [LastStateName] = 'Failed'
order by AdvertisementID
