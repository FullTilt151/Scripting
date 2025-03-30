-- Latest HINV syncs by WKID
select top 500 netbios_name0, lasthw, LastMPServerName
from v_r_system_valid sys join
	 v_ch_clientsummary cs on sys.resourceid = cs.resourceid
where Netbios_Name0 = ('WKMJ02PVX')
order by lasthw desc

-- Last HINV changes for a machine
select sys.Netbios_Name0, hinv.*
from v_R_System sys join
	 HinvChangeLog hinv on sys.ResourceID = hinv.MachineID
where sys.Netbios_Name0 = 'WKMJ02PVX'
order by TimeKey desc

-- Inventory log for the site
select top 50000 *
from InventoryLog
order by logid desc

-- Count of HINV syncs by year, month, day
select top 30 month(lasthw) [Month], day(lasthw) [Day], year(lasthw) [Year], count(*) [Count]
from v_r_system_valid sys join
	 v_ch_clientsummary cs on sys.resourceid = cs.resourceid
group by month(lasthw), day(lasthw), year(lasthw)
order by year(lasthw) desc, month(lasthw) desc, day(lasthw) desc

-- Summarize views
Exec CH_SyncClientSummary

-- Status messages for HINV
SELECT        stat.Time, stat.MachineName, stat.ProcessID, stat.ThreadID, stat.RecordID, 
				(select InsStrValue from v_StatMsgInsStrings ins1 where ins1.RecordID = stat.RecordID and ins1.InsStrIndex = 0) [0],
				(select InsStrValue from v_StatMsgInsStrings ins1 where ins1.RecordID = stat.RecordID and ins1.InsStrIndex = 1) [1],
				(select InsStrValue from v_StatMsgInsStrings ins1 where ins1.RecordID = stat.RecordID and ins1.InsStrIndex = 2) [2],
				(select InsStrValue from v_StatMsgInsStrings ins1 where ins1.RecordID = stat.RecordID and ins1.InsStrIndex = 3) [3]
FROM            v_StatusMessage AS stat LEFT OUTER JOIN
                v_StatMsgAttributes AS att ON stat.recordid = att.recordid LEFT OUTER JOIN
                v_StatMsgInsStrings AS ins ON stat.recordid = ins.recordid
WHERE        (COMPONENT = 'SMS_INVENTORY_DATA_LOADER') AND (stat.Time >= '2018/06/25 00:00:00.000') /*
			and ((select InsStrValue from v_StatMsgInsStrings ins1 where ins1.RecordID = stat.RecordID and ins1.InsStrIndex = 0) = 'H8M5FLXG.MIF'
			or (select InsStrValue from v_StatMsgInsStrings ins1 where ins1.RecordID = stat.RecordID and ins1.InsStrIndex = 1) like '%H8M5FLXG.MIF%')*/
ORDER BY stat.Time DESC

-- Count of duplicate previous GUIDs
select Previous_SMS_UUID0, COUNT(Netbios_Name0) [Count]
from v_R_System
where Previous_SMS_UUID0 is not null
group by Previous_SMS_UUID0
having count(*) > 20
order by [Count] desc

-- Count of duplicate current GUIDs
select SMS_Unique_Identifier0, COUNT(Netbios_Name0) [Count]
from v_R_System
where SMS_Unique_Identifier0 is not null
group by SMS_Unique_Identifier0
having count(*) > 1
order by [Count] desc

-- Machines with duplicate GUIDs
select Netbios_Name0, Previous_SMS_UUID0, SMS_Unique_Identifier0, SMS_UUID_Change_Date0
from v_r_system
where SMS_Unique_Identifier0 in (
select Previous_SMS_UUID0
from v_R_System
where Previous_SMS_UUID0 is not null
group by Previous_SMS_UUID0
having COUNT(Netbios_Name0) > 20)
order by Netbios_Name0

-- Workstations in All Non-HGB Physical Workstations Security Collection
select Netbios_Name0, Creation_Date0, Operating_System_Name_and0, Resource_Domain_OR_Workgr0, sys.Is_Virtual_Machine0, LastHW, syst.SystemRole0
from v_R_System_Valid sys left join
	 v_CH_ClientSummary CS on sys.ResourceID = cs.ResourceID left join
	 v_GS_SYSTEM SYST on sys.ResourceID = syst.ResourceID
where sys.ResourceID in (select resourceid from v_CM_RES_COLL_WP100017)
	  and lasthw is null
order by Creation_Date0 desc

-- Workstations not in All Non-HGB Physical Workstations Security Collection
select Netbios_Name0, Creation_Date0, Client0, Operating_System_Name_and0, Resource_Domain_OR_Workgr0, sys.Is_Virtual_Machine0, LastHW, syst.SystemRole0
from v_R_System sys left join
	 v_CH_ClientSummary CS on sys.ResourceID = cs.ResourceID left join
	 v_GS_SYSTEM SYST on sys.ResourceID = syst.ResourceID
where sys.ResourceID not in (select resourceid from v_CM_RES_COLL_WP100017)
	  and (sys.Operating_System_Name_and0 like '%Workstation%'
	  or syst.SystemRole0 = 'Workstation' 
	  or syst.SystemRole0 IS NULL)
	  and client0 = 1
	  and Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' 
	  and Resource_Domain_OR_Workgr0 != 'HMHSCHAMP.humad.com' 
	  and (Is_Virtual_Machine0 = 0 or Is_Virtual_Machine0 is null)
order by Creation_Date0 desc

-- Servers not in All Windows Servers Security Collection
select Netbios_Name0, Creation_Date0, Client0, Operating_System_Name_and0, Resource_Domain_OR_Workgr0, sys.Is_Virtual_Machine0, LastHW, syst.SystemRole0
from v_R_System sys left join
	 v_CH_ClientSummary CS on sys.ResourceID = cs.ResourceID left join
	 v_GS_SYSTEM SYST on sys.ResourceID = syst.ResourceID
where sys.ResourceID not in (select resourceid from v_CM_RES_COLL_SP10001F)
	  and sys.Operating_System_Name_and0 like '%Windows%Server%'
	  and client0 = 1
order by Creation_Date0 desc

-- Devices with specific GUIDs
select resourceid, Netbios_Name0, SMS_Unique_Identifier0, Previous_SMS_UUID0, SMS_UUID_Change_Date0, Client0
from v_R_System where (SMS_Unique_Identifier0 = 'GUID:B5717FBD-00D8-46B0-9D75-004F7DB36D86' or Previous_SMS_UUID0 = 'GUID:B5717FBD-00D8-46B0-9D75-004F7DB36D86')
--and Netbios_Name0 like 'LOUXDWHGB%T00%'

-- Devices with Duplicate GUIDs
SELECT resourceid, 
       netbios_name0, 
       sms_unique_identifier0, 
       previous_sms_uuid0, 
       sms_uuid_change_date0, 
       client0 
FROM   v_r_system 
WHERE  ( sms_unique_identifier0 IN (SELECT previous_sms_uuid0 
                                    FROM   v_r_system 
                                    WHERE  previous_sms_uuid0 IS NOT NULL 
                                    GROUP  BY previous_sms_uuid0 
                                    HAVING Count(*) > 20) ) 
order by ResourceID

-- Devices with Duplicate previous GUIDs
SELECT resourceid, 
       netbios_name0, 
       sms_unique_identifier0, 
       previous_sms_uuid0, 
       sms_uuid_change_date0, 
       client0 
FROM   v_r_system 
WHERE  previous_sms_uuid0 IN (SELECT previous_sms_uuid0 
                                FROM   v_r_system 
                                WHERE  previous_sms_uuid0 IS NOT NULL 
								AND Previous_SMS_UUID0 != 'Unknown'
                                GROUP  BY previous_sms_uuid0 
                                HAVING Count(*) > 20) 