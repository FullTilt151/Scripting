-- Avaya and DG replacement
select sys.Netbios_Name0, sft.ProductName0
from v_r_system sys inner join
	 v_gs_installed_software sft on sys.resourceid = sft.resourceid left join
	 v_RA_System_System_Group_Name grp on sys.resourceid = grp.resourceid
where productname0 like 'Avaya one-x%' and System_Group_Name0 in
('HUMAD\T_CIS_GPO_DG_Pilot1',
'HUMAD\T_CIS_GPO_DG_Prod1',
'HUMAD\T_CIS_GPO_DG_Prod2',
'HUMAD\T_CIS_GPO_DG_Prod3',
'HUMAD\T_CIS_GPO_DG_Prod4',
'HUMAD\T_Client_DGReplacement')

-- List of WKIDs and delpoyment status
select sys.Netbios_Name0, cs.LastActiveTime, adv.AdvertisementName, cas.AdvertisementID, cas.LastAcceptanceStateName, 
		cas.LastAcceptanceMessageIDName, LastAcceptanceStatusTime, LastStateName, LastStatusMessageIDName, LastStatusTime,
		cas.LastExecutionResult
from v_r_system sys inner join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID inner join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID inner join
	 v_Advertisement adv on cas.AdvertisementID = adv.AdvertisementID
--where cas.advertisementid in ('WP12643C','WP126440','WP12643F','WP12643E','WP12643D')
where cas.advertisementid in ('WP126457') and LastStateName = 'Failed' and LastExecutionResult in ('69555')
order by LastStatusTime desc

-- All deployment counts
select LastStateName, LastStatusMessageIDName, count(*)
from v_r_system sys inner join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID inner join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID inner join
	 v_Advertisement adv on cas.AdvertisementID = adv.AdvertisementID
--where cas.advertisementid in ('WP12643C','WP126440','WP12643F','WP12643E','WP12643D')
where cas.advertisementid in ('WP126457')
group by LastStateName, LastStatusMessageIDName

-- Unknown deployments counts
select sys.Netbios_Name0, cs.LastActiveTime, cs.LastHW, LastStateName, LastStatusMessageIDName
from v_r_system sys inner join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID inner join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID inner join
	 v_Advertisement adv on cas.AdvertisementID = adv.AdvertisementID
where cas.advertisementid in ('WP12643C','WP126440','WP12643F','WP12643E','WP12643D') and LastStatusMessageIDName in ('No messages have been received','Program received - no further status') and
	  cs.LastActiveTime > '03/30/2020 12:00:00 am'
order by cs.LastActiveTime desc

-- Failed deployments counts
select LastStateName, LastStatusMessageIDName, cas.LastExecutionResult, count(*)
from v_r_system sys inner join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID inner join
	 v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID inner join
	 v_Advertisement adv on cas.AdvertisementID = adv.AdvertisementID
--where cas.advertisementid in ('WP12643C','WP126440','WP12643F','WP12643E','WP12643D') and LastStateName = 'Failed'
where cas.advertisementid in ('WP126457') and LastStateName = 'Failed'
group by LastStateName, LastStatusMessageIDName, cas.LastExecutionResult

-- Avaya installs - HINV
select sys.Netbios_Name0, cs.LastActiveTime, cs.lasthw, sft.ProductName0
from v_R_System sys left join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID left join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID
where sys.Resource_Domain_OR_Workgr0 = 'HUMAD' and sys.Netbios_Name0 not like 'TR%' and sys.Netbios_Name0 not like '___XDW%' and ProductName0 like 'Avaya one-x agent%'
order by lasthw desc

-- Avaya installs - filtered
select sys.Netbios_Name0, cs.LastActiveTime, cs.lasthw, 
		(select ProductName0 from v_gs_installed_software sft where sft.resourceid = sys.resourceid and ProductName0 like 'Avaya one-x%') [Avaya]
from v_R_System sys left join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID
where sys.Resource_Domain_OR_Workgr0 = 'HUMAD' and sys.Netbios_Name0 not like 'TR%' and sys.Netbios_Name0 not like '___XDW%'
	 and sys.resourceid in (select resourceid from v_cm_res_coll_wp1067f3)

-- Avaya installs counts
select sys.Netbios_Name0, cs.LastActiveTime, cs.lasthw, 
		(select ProductName0 from v_gs_installed_software sft where sft.resourceid = sys.resourceid and ProductName0 like 'Avaya one-x%') [Avaya]
from v_R_System sys left join
	 v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID
where sys.Resource_Domain_OR_Workgr0 = 'HUMAD' and sys.Netbios_Name0 not like 'TR%' and sys.Netbios_Name0 not like '___XDW%'
	 and sys.resourceid in (select resourceid from v_cm_res_coll_wp1067f3)

exec CH_SyncClientSummary