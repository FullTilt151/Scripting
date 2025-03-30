SELECT distinct top 1000 att1.AttributeTime, stat.*, ins.*, att1.*, att2.*, ins2.*, ins3.*
FROM        v_StatusMessage AS stat FULL JOIN
            v_StatMsgInsStrings AS ins ON ins.RecordID = stat.RecordID FULL JOIN
            v_StatMsgAttributes AS att1 ON att1.RecordID = stat.RecordID FULL JOIN
            v_StatMsgAttributes AS att2 ON att2.RecordID = stat.RecordID FULL JOIN
			v_StatMsgWithInsStrings as ins2 on att1.RecordID = ins2.RecordID FULL JOIN
			v_StatMsgWithInsStrings as ins3 on att2.RecordID = ins2.RecordID
WHERE        att2.AttributeValue in ('16777867','16777866','16777865') --and stat.Component not in ('Software Distribution','SMS_OFFER_MANAGER')
ORDER BY att1.AttributeTime DESC

select stat.*, ins.*, att1.*, att1.AttributeTime 
from v_StatusMessage as stat left join 
v_StatMsgInsStrings as ins on stat.RecordID = ins.RecordID left join 
v_StatMsgAttributes as att1 on stat.RecordID = att1.RecordID inner join 
v_StatMsgAttributes as att2 on stat.RecordID = att2.RecordID 
where att2.AttributeID = 401 and att2.AttributeValue in('{F91F679A-17D6-46BE-893F-DC28D5AB3D38}') and stat.SiteCode = 'SP1' and att2.AttributeTime >= '2017/12/21 00:00:00.000' 
	  --and stat.Component != 'Software Distribution'
order by att1.AttributeTime desc

select stat.*, ins.*, att1.*, stat.Time 
from v_StatusMessage as stat left join 
	 v_StatMsgInsStrings as ins on stat.RecordID = ins.RecordID left join 
	 v_StatMsgAttributes as att1 on stat.RecordID = att1.RecordID 
where stat.Component = 'Microsoft.ConfigurationManagement.exe' and stat.SiteCode = 'SP1' and stat.Time >= '2017/12/21 12:00:00.000'
order by stat.Time desc

-- Patches installed on a certain day
select STM.Netbios_Name0 [WKID], QFE.HotFixID0, QFE.InstalledOn0
from v_GS_QUICK_FIX_ENGINEERING QFE
join v_r_system STM on QFE.ResourceID = STM.ResourceID
order by InstalledOn0

-- Patches installed on a certain day - Unique
select distinct STM.Netbios_Name0 [WKID]
from v_GS_QUICK_FIX_ENGINEERING QFE
join v_r_system STM on QFE.ResourceID = STM.ResourceID
where InstalledOn0 = '12/21/2017' or InstalledOn0 = '12/22/2017'