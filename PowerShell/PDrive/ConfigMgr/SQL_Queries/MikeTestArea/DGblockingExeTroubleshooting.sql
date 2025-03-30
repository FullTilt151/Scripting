select sys.Netbios_Name0, Is_Virtual_Machine0, AdvertisementID,LastAcceptanceMessageID, LastAcceptanceMessageIDName, LastAcceptanceStateName laststatename, LastExecutionResult
from v_R_System_Valid sys inner join
     v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID
where LastExecutionResult = '-532462766' --and Is_Virtual_Machine0 = 1 --sys.Netbios_Name0 = 'SIMXDWVIPA1054' and 
order by Netbios_Name0 --LastStatusTime desc

select AdvertisementID, laststatename, LastExecutionResult, count(*)
from v_R_System_Valid sys inner join
     v_ClientAdvertisementStatus cas on sys.ResourceID = cas.ResourceID
where LastExecutionResult = '-532462766'
group by AdvertisementID, laststatename, LastExecutionResult

select packageid, AdvertisementName, ProgramName, CollectionID, Comment, SourceSite
from v_Advertisement
where AdvertisementID in ('WP1212CB','WP1220FE','WP1222BF','WP12351A','WP1254D6','WP1254F3','WP125538','WP1259A2','WP125C74','WP125C9A','WP125CF5',
'WP126255','WP126258','WP12625A','WP126267','WP126289','WP1262F4','WP126360','WP126363','WP126365','WP1263D3','WP1263D7','WP1263DE','WP1263E7',
'WP126412','WP126421','WP126427','WP126479','WP1264CB','WP1264CC','WP1264FB','WP1264FC','WP1264FD')

select Manufacturer, name, version, PkgSourcePath, Description
from v_Package
where PackageID in ('WQ1000BB','WQ100250','WQ1001B8','WQ100430','WQ1009E3','WQ100AF8','WQ100ADA','WQ1000A2','WQ100BA3','WQ1008B9','WQ100BD7','WQ100C2E','WQ100C2E','WQ100C2E',
'WQ100BA9','WQ100984','WQ100C85','WQ100C85','WQ100C85','WQ100C85','WQ100C73','WQ10086F','WQ100C85','WQ1009F4','WQ100CCA','WQ100CCA','WQ100925','WQ100CD8','WQ100A0F','WQ100A0F',
'WQ100C85','WQ100C85','WQ100984')

select *
from v_Collection
where CollectionID = 'WP100312'

SELECT
  V_R_SYSTEM.Name0,
  V_R_SYSTEM.SMS_Unique_Identifier0,
  V_R_SYSTEM.Resource_Domain_OR_Workgr0,
  V_R_SYSTEM.Client0,
  V_R_SYSTEM.Client_Version0,
  count(*)
FROM V_R_System
WHERE V_R_System.Client_Version0 != '5.00.8913.1006'
group by V_R_SYSTEM.SMS_Unique_Identifier0, V_R_SYSTEM.Resource_Domain_OR_Workgr0, V_R_SYSTEM.Client0, V_R_SYSTEM.Client_Version0
--order by Client_Version0 desc