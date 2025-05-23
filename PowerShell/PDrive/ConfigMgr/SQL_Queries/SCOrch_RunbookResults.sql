-- Count of instances by day
SELECT ri.Status, DATEPART(day, ri.CreationTime), count(*)
FROM [Microsoft.SystemCenter.Orchestrator.Runtime].[RunbookInstanceParameters] RIP join
	 [microsoft.systemcenter.orchestrator.runtime].runbookinstances RI on RIP.RunbookInstanceId = RI.Id
where Name = 'WKID'
group by ri.status,DATEPART(day, ri.CreationTime)

-- List of instances
SELECT Name, Value, status, CreationTime, RunbookInstanceId
FROM [Microsoft.SystemCenter.Orchestrator.Runtime].[RunbookInstanceParameters] RIP join
	 [microsoft.systemcenter.orchestrator.runtime].runbookinstances RI on RIP.RunbookInstanceId = RI.Id
where Name in ('WKID','ADOU') --and value = 'Wkpf0aqacx'
order by CreationTime DESC, Name

-- Runbook parameters
select distinct RunbookParameterId, name, Direction
from [Microsoft.SystemCenter.Orchestrator.Runtime].RunbookInstanceParameters