--Filtering using Where, by date range, and update needed
Select 
c.fulldomainname as [ComputerName],
substring(c.fulldomainname,0,CHARINDEX('.',c.fulldomainname)),
vu.DefaultTitle as [Update Title],
vu.SecurityBulletin,
vu.knowledgebaseArticle,
vu.ArrivalDate,
up.SummarizationState,
case when up.SummarizationState = 1 then 'Not Applicable'
when up.summarizationState = 2 then 'Required'
when up.SummarizationState = 3 then 'Downloaded'
when up.SummarizationState = 4 then 'Installed'
when up.summarizationState =5 then 'Failed'
when up.SummarizationState = 6 then 'Reboot Required'
  end as [SummarizationStateText]
from tbComputerTarget c
join tbUpdateStatusPerComputer up on c.targetid=up.targetid
join tbUpdate u on up.localupdateid = u.localupdateid
join Public_views.vupdate vu on u.updateid=vu.updateid
where
 vu.arrivaldate between '2015/09/01' and '2015/09/30' 
and  up.SummarizationState not in ('1','4')
order by computername, KnowledgebaseArticle

--using Charindex to show just the computername, not the FQDN
Select 
substring(c.fulldomainname,0,CHARINDEX('.',c.fulldomainname)) [ComputerName],
vu.DefaultTitle as [Update Title],
vu.SecurityBulletin,
vu.knowledgebaseArticle,
vu.ArrivalDate,
up.SummarizationState,
case when up.SummarizationState = 1 then 'Not Applicable'
when up.summarizationState = 2 then 'Required'
when up.SummarizationState = 3 then 'Downloaded'
when up.SummarizationState = 4 then 'Installed'
when up.summarizationState =5 then 'Failed'
when up.SummarizationState = 6 then 'Reboot Required'
  end as [SummarizationStateText]
from tbComputerTarget c
join tbUpdateStatusPerComputer up on c.targetid=up.targetid
join tbUpdate u on up.localupdateid = u.localupdateid
join Public_views.vupdate vu on u.updateid=vu.updateid
where
 vu.arrivaldate between '2015/09/01' and '2015/09/30' 
and  up.SummarizationState not in ('1','4')
order by computername, KnowledgebaseArticle

--Which Computers are the highest offenders?
Select 
substring(c.fulldomainname,0,CHARINDEX('.',c.fulldomainname)) [ComputerName]
,count(distinct vu.knowledgebasearticle) [CountMissing]
from tbComputerTarget c
join tbUpdateStatusPerComputer up on c.targetid=up.targetid
join tbUpdate u on up.localupdateid = u.localupdateid
join Public_views.vupdate vu on u.updateid=vu.updateid
where
 up.SummarizationState not in ('1','4')
group by c.FullDomainName
order by CountMissing desc

--Which computers are just waiting on a reboot?
Select 
substring(c.fulldomainname,0,CHARINDEX('.',c.fulldomainname)) [ComputerName]
,count(distinct vu.knowledgebasearticle) [CountMissing]
from tbComputerTarget c
join tbUpdateStatusPerComputer up on c.targetid=up.targetid
join tbUpdate u on up.localupdateid = u.localupdateid
join Public_views.vupdate vu on u.updateid=vu.updateid
where
 up.SummarizationState in ('6')
group by c.FullDomainName
order by CountMissing desc

--Which computers are missing the most updates...NOT waiting for a reboot?
Select 
substring(c.fulldomainname,0,CHARINDEX('.',c.fulldomainname)) [ComputerName]
,count(distinct vu.knowledgebasearticle) [CountMissing]
from tbComputerTarget c
join tbUpdateStatusPerComputer up on c.targetid=up.targetid
join tbUpdate u on up.localupdateid = u.localupdateid
join Public_views.vupdate vu on u.updateid=vu.updateid
where
 up.SummarizationState not in ('1','4')
and c.FullDomainName not in (
select c.FullDomainName from 
  tbComputerTarget c
join tbUpdateStatusPerComputer up on c.targetid=up.targetid
where up.summarizationstate =6)
group by c.FullDomainName
order by CountMissing desc

--So you have some new hire--and you want to send them off to remediate the top 10 machines...

Select top(10)
substring(c.fulldomainname,0,CHARINDEX('.',c.fulldomainname)) [ComputerName]
,count(distinct vu.knowledgebasearticle) [CountMissing]
,IIF(count(distinct vu.knowledgebasearticle) > 100, 'High','Medium') as [Boss will Yell at you Index]
from tbComputerTarget c
join tbUpdateStatusPerComputer up on c.targetid=up.targetid
join tbUpdate u on up.localupdateid = u.localupdateid
join Public_views.vupdate vu on u.updateid=vu.updateid
where
 up.SummarizationState not in ('1','4')
and c.FullDomainName not in (
select c.FullDomainName from 
  tbComputerTarget c
join tbUpdateStatusPerComputer up on c.targetid=up.targetid
where up.summarizationstate =6)
group by c.FullDomainName
order by CountMissing desc