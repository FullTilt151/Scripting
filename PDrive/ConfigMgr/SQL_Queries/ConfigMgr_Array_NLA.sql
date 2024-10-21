-- List of WKIDs and deployments for a collection
select Netbios_Name0, Build01, osd.ImageInstalled0, ImageRelease0, os.InstallDate0, adv.AdvertisementName, cas.LastStateName, cas.LastStatusTime
from v_r_system sys left join
	 v_GS_OSD640 osd on sys.ResourceID = osd.ResourceID left join
	 v_GS_OPERATING_SYSTEM os on sys.ResourceID = os.ResourceID left join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID left join
	 v_Advertisement adv on cas.AdvertisementID = adv.AdvertisementID
where sys.resourceid in (select resourceid from v_cm_res_coll_wp1071ad) and LastStatusTime > '2020-08-18 00:00:00.000' and
	 LastStateName not in ('Accepted - No Further Status')

-- Count of deployments for a collection
select adv.AdvertisementName, count(*)
from v_r_system sys left join
	 v_GS_OSD640 osd on sys.ResourceID = osd.ResourceID left join
	 v_GS_OPERATING_SYSTEM os on sys.ResourceID = os.ResourceID left join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID left join
	 v_Advertisement adv on cas.AdvertisementID = adv.AdvertisementID
where sys.resourceid in (select resourceid from v_cm_res_coll_wp1071ad) and LastStatusTime > '2020-08-18 00:00:00.000' and
	 LastStateName not in ('Accepted - No Further Status')
group by adv.AdvertisementName
order by count(*) desc

-- Comparison list of WKIDs for a collection
select Netbios_Name0, 
	case Build01
	when '10.0.16299' then '1709'
	when '10.0.17134' then '1803'
	when '10.0.17763' then '1809'
	end [Build], csp.Version0, drv.DeviceName0, DriverDate0, DriverVersion0
from v_R_System sys left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID left join
	 v_GS_PNP_SIGNED_DRIVER_CUSTOM drv on sys.ResourceID = drv.ResourceID
where sys.ResourceID in (select resourceid from v_cm_res_coll_wp1071ad) and 
	  drv.DeviceClass0 = 'NET' and DeviceName0 not in ('Array Networks SSL VPN Adapter','Cisco AnyConnect Secure Mobility Client Virtual Miniport Adapter for Windows x64','Zscaler Network Adapter 1.0.2.0')

-- Comparison count of WKIDs for a collection
select case Build01
	when '10.0.16299' then '1709'
	when '10.0.17134' then '1803'
	when '10.0.17763' then '1809'
	end [Build], csp.Version0, drv.DeviceName0, DriverDate0, DriverVersion0, count(*)
from v_R_System sys left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID left join
	 v_GS_PNP_SIGNED_DRIVER_CUSTOM drv on sys.ResourceID = drv.ResourceID
where sys.ResourceID in (select resourceid from v_cm_res_coll_wp1071ad) and 
	  drv.DeviceClass0 = 'NET' and DeviceName0 not in ('Array Networks SSL VPN Adapter','Cisco AnyConnect Secure Mobility Client Virtual Miniport Adapter for Windows x64','Zscaler Network Adapter 1.0.2.0')
group by case Build01
	when '10.0.16299' then '1709'
	when '10.0.17134' then '1803'
	when '10.0.17763' then '1809'
	end, csp.Version0, drv.DeviceName0, DriverDate0, DriverVersion0