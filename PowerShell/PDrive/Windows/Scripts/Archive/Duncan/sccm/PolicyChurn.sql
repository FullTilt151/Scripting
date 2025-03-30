Set NoCount ON;
Select  distinct stat.RecordID,
stat.SiteCode,
(insPid.InsStrValue + ' - ' + insN.InsStrValue) as Pkg
into #tmpRecords
from v_StatusMessage as stat
left outer join v_StatMsgAttributes as att on stat.recordid = att.recordid 
left outer join v_StatMsgInsStrings as insN on stat.recordid = insN.recordid 
left outer join v_StatMsgInsStrings as insPid on stat.recordid = insPid.recordid 

WHERE (COMPONENT='SMS_POLICY_PROVIDER')
AND (stat.Time>=DATEADD(HOUR, +3, SYSDATETIME())) 
and stat.MessageID = 5101
and insN.InsStrIndex = 0
and insPid.InsStrIndex = 1;

Set NoCount Off;
select SiteCode, Pkg, count(*) as Total
from #tmpRecords
group by SiteCode, Pkg
order by count(*) desc;
drop table #tmpRecords;
