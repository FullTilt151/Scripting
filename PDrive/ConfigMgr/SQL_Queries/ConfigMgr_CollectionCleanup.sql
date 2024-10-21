-- SMS_Collection properties
-- https://msdn.microsoft.com/en-us/library/hh442671.aspx

/* Refresh types
1 - MANUAL (No schedule)
2 - PERIODIC (Schedule)
4 - CONSTANT (Incremental)
6 - BOTH (Schedule and Incremental)
*/

-- Find collections without query rules, but with incremental or schedule updates
select *
from v_Collection
where CollectionID not in (
select CollectionID
from v_CollectionRuleQuery)
and collectiontype = 2 and RefreshType in (2,4,6) and Name not like '%Limiting collection' and Name not like '%Security collection'

-- Find Shopping collections with DNR and RDP queries
select rulename, QueryExpression, count(*)
from v_CollectionRuleQuery
group by rulename, QueryExpression
order by count(*) desc

-- Coll Dependency Chain
select top 100 *
from vCollectionDependencyChain

-- Clustered Collection Schedules
Select * from v_Collections where Schedule != ''

Select CG.CollectionName, CG.SITEID AS [Collection ID], 
CASE VC.CollectionType
WHEN 0 THEN 'Other'
WHEN 1 THEN 'User'
WHEN 2 THEN 'Device'
ELSE 'Unknown' END AS CollectionType,
CG.schedule, case
WHEN CG.Schedule like '%000102000' THEN 'Every 1 minute'
WHEN CG.Schedule like '%00010A000' THEN 'Every 5 mins'
WHEN CG.Schedule like '%000114000' THEN 'Every 10 mins'
WHEN CG.Schedule like '%00011E000' THEN 'Every 15 mins'
WHEN CG.Schedule like '%000128000' THEN 'Every 20 mins'
WHEN CG.Schedule like '%000132000' THEN 'Every 25 mins'
WHEN CG.Schedule like '%00013C000' THEN 'Every 30 mins'
WHEN CG.Schedule like '%000150000' THEN 'Every 40 mins'
WHEN CG.Schedule like '%00015A000' THEN 'Every 45 mins'
WHEN CG.Schedule like '%000100100' THEN 'Every 1 hour'
WHEN CG.Schedule like '%000100200' THEN 'Every 2 hours'
WHEN CG.Schedule like '%000100300' THEN 'Every 3 hours'
WHEN CG.Schedule like '%000100400' THEN 'Every 4 hours'
WHEN CG.Schedule like '%000100500' THEN 'Every 5 hours'
WHEN CG.Schedule like '%000100600' THEN 'Every 6 hours'
WHEN CG.Schedule like '%000100700' THEN 'Every 7 hours'
WHEN CG.Schedule like '%000100B00' THEN 'Every 11 Hours'
WHEN CG.Schedule like '%000100C00' THEN 'Every 12 Hours'
WHEN CG.Schedule like '%000101000' THEN 'Every 16 Hours'
WHEN CG.Schedule like '%000100008' THEN 'Every 1 days'
WHEN CG.Schedule like '%000100010' THEN 'Every 2 days'
WHEN CG.Schedule like '%000100028' THEN 'Every 5 days'
WHEN CG.Schedule like '%000100038' THEN 'Every 7 Days'
WHEN CG.Schedule like '%000192000' THEN '1 week'
WHEN CG.Schedule like '%000080000' THEN 'Update Once'
WHEN CG.SChedule = '' THEN 'Manual'
END AS [Update Schedule], VC.EvaluationStartTime,	
Case VC.RefreshType
when 1 then 'Manual'
when 2 then 'Scheduled'
when 4 then 'Incremental'
when 6 then 'Scheduled and Incremental'
else 'Unknown'
end as RefreshType, VC.MemberCount
from dbo.collections_g CG
left join v_collections VC on VC.SiteID = CG.SiteID
--Where CG.CollectionName like '%minutes'
order by CG.Schedule DESC
