-- Selecting from 1 table (should use views where possible)
select count(tbUpdateStatusPerComputer.localupdateid)
from tbUpdateStatusPerComputer
--624,500 rows

-- Eliminating Duplicates, use "distinct"
select count(distinct tbUpdateStatusPerComputer.localupdateid)
from tbUpdateStatusPerComputer
--1,663 rows; aka, the # of unique updates which computers have reported on)

-- Alias the view, and column names
select count(distinct PerCompStatus.localupdateid) [Count Unique Updates]
from tbUpdateStatusPerComputer PerCompStatus

-- Grouping
select PerCompStatus.localupdateid [InComprehensible Unique LocalUpdateID],
PerCompStatus.SummarizationState [SummarizationState],
Count(*) as [Count per Update in specific states]
from tbUpdateStatusPerComputer PerCompStatus
group by PerCompStatus.LocalupdateID, PerCompStatus.SummarizationState
order by PerCompStatus.SummarizationState

-- interesting... but incomprehensible. English, please!
--Case statements, and more than 1 table or view

select PerCompStatus.localupdateid [InComprehensible Unique LocalUpdateID],
vu.DefaultTitle [Title],
vu.SecurityBulletin,
vu.KnowledgebaseArticle,
vu.ArrivalDate,
PerCompStatus.SummarizationState [SummarizationState],
case when PerCompStatus.SummarizationState = 1 then 'Not Applicable'
when PerCompStatus.summarizationState = 2 then 'Required'
when PerCompStatus.SummarizationState = 3 then 'Downloaded'
when PerCompStatus.SummarizationState = 4 then 'Installed'
when PerCompStatus.summarizationState =5 then 'Failed'
when PerCompStatus.SummarizationState = 6 then 'Reboot Required'
  end as [SummarizationStateText],
Count(*) as [Count per Update in specific states]
from tbUpdateStatusPerComputer PerCompStatus 
join tbUpdate u on PerCompStatus.localupdateid = u.localupdateid
join Public_views.vupdate vu on u.updateid=vu.updateid
group by PerCompStatus.LocalupdateID, PerCompStatus.SummarizationState
,vu.DefaultTitle,vu.SecurityBulletin,vu.KnowledgebaseArticle,vu.ArrivalDate
order by [Count per Update in specific states] desc

--Ok, that's "just about everything", but all management really wants to know is "who isn't compliant"
--   for things released in 2014, or before a certain date, or in the last xx days
--Let's add conditions.
select PerCompStatus.localupdateid [InComprehensible Unique LocalUpdateID],
vu.DefaultTitle [Title],
vu.SecurityBulletin,
vu.KnowledgebaseArticle,
datediff(d,vu.arrivaldate, GETDATE()) as [Age in Days],
vu.ArrivalDate,
PerCompStatus.SummarizationState [SummarizationState],
case when PerCompStatus.SummarizationState = 1 then 'Not Applicable'
when PerCompStatus.summarizationState = 2 then 'Required'
when PerCompStatus.SummarizationState = 3 then 'Downloaded'
when PerCompStatus.SummarizationState = 4 then 'Installed'
when PerCompStatus.summarizationState =5 then 'Failed'
when PerCompStatus.SummarizationState = 6 then 'Reboot Required'
  end as [SummarizationStateText],
Count(*) as [Count per Update in specific states]
from tbUpdateStatusPerComputer PerCompStatus 
join tbUpdate u on PerCompStatus.localupdateid = u.localupdateid
join Public_views.vupdate vu on u.updateid=vu.updateid
where  
vu.arrivaldate between '2014/01/01' and '2014/12/31' 
--or... we want older than January 2014 release date
--vu.arrivaldate < '2014/01/01'
--or... we want only the updates as released in the last 120 days
--  datediff(d,vu.arrivaldate, GETDATE()) <120
and  PerCompStatus.SummarizationState not in ('1','4')
group by PerCompStatus.LocalupdateID, PerCompStatus.SummarizationState
,vu.DefaultTitle,vu.SecurityBulletin,vu.KnowledgebaseArticle,vu.ArrivalDate
order by [Count per Update in specific states] desc, vu.ArrivalDate
