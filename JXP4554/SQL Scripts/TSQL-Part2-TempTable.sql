--Using Temp Tables
--will sometimes make sql run a query faster
--and they are useful to combine 1 or more tables; to use later.

If(OBJECT_ID('tempdb..#TableTemp') Is Not Null)
Begin
  Drop Table #TableTemp
End

Create table #TableTemp (
 TargetID int PRIMARY KEY,
 ComputerName nvarchar (256),
 FQDN nvarchar (256),
 Make nvarchar (256),
 Model nvarchar (256),
 IsVirtual int
);

INSERT INTO #TableTemp
Select distinct
 c.TargetID as [TargetID],
 substring(c.fulldomainname,0,CHARINDEX('.',c.fulldomainname)) as [ComputerName],
 c.fulldomainname as [FQDN],
 td.ComputerMake,
 td.ComputerModel,
 case when ComputerModel like '%virtual%' then 1
   else 0 end as [IsVirtual]
from tbComputerTarget c
 left join tbcomputertargetdetail td on td.targetid=c.targetid

Select top(10)
#TableTemp.ComputerName,
#TableTemp.IsVirtual,
#tableTemp.make, #TableTemp.model,
count(distinct vu.knowledgebasearticle) [CountMissing]
,IIF(count(distinct vu.knowledgebasearticle) > 100, 'High','Medium') as [Boss will Yell at you Index]
from #TableTemp 
join tbUpdateStatusPerComputer up on #TableTemp.targetid=up.targetid
join tbUpdate u on up.localupdateid = u.localupdateid
join Public_views.vupdate vu on u.updateid=vu.updateid
where
 up.SummarizationState not in ('1','4')
and #TableTemp.targetid not in (
select targetid from 
   tbUpdateStatusPerComputer up
where up.summarizationstate =6)
group by #TableTemp.computername, #TableTemp.IsVirtual
,#tableTemp.make, #tabletemp.model
order by CountMissing desc


If(OBJECT_ID('tempdb..#TableTemp') Is Not Null)
Begin
  Drop Table #TableTemp
End