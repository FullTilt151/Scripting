select resourceid, SizeEstimate0, DateTime0
from v_GS_USMT_ESTIMATE
order by resourceid

-- Temp table method
select resourceid, max(DateTime0) DateTimeZero into #Temp 
from v_GS_USMT_ESTIMATE 
group by resourceid

select SizeEstimate0
from #temp a inner join 
v_GS_USMT_ESTIMATE b on a.resourceid = b.resourceid and a.DateTimeZero = b.DateTime0
order by SizeEstimate0 desc

-- Subselect method using PARTITION
select resourceid, SizeEstimate0, DateTime0 from 
(
select resourceid, SizeEstimate0, DateTime0
,ROW_NUMBER() OVER (PARTITION BY resourceid ORDER BY DateTime0 DESC) RN 
from v_GS_USMT_ESTIMATE
) T where RN = 1

--CTE method
 WITH CTE_Max 
 AS (SELECT resourceid, MAX(DateTime0) AS max_dt
 FROM v_GS_USMT_ESTIMATE
 GROUP BY resourceid)
 SELECT o.resourceid, o.SizeEstimate0/1024, o.DateTime0
 FROM CTE_Max m,v_GS_USMT_ESTIMATE o
 WHERE m.resourceid = o.resourceid
	   AND m.max_dt = o.DateTime0
 order by SizeEstimate0 desc