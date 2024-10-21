SELECT        PolicyAssignment.PADBID, PolicyAssignment.PolicyAssignmentID, PolicyAssignment.Version, PolicyAssignment.PolicyID, PolicyAssignment.Body, PolicyAssignment.LastUpdateTime, 
                         PolicyAssignment.IsTombstoned, PolicyAssignment.InProcess, ResPolicyMap.LastUpdateTime AS Expr1, ResPolicyMap.TargetSourceID, ResPolicyMap.IsTombstoned AS [ResMap Tombstoned]
FROM            PolicyAssignment INNER JOIN
                         ResPolicyMap ON PolicyAssignment.PADBID = ResPolicyMap.PADBID
WHERE        (PolicyAssignment.IsTombstoned = 1) AND (ResPolicyMap.IsTombstoned = 0)

--
select *
from PolicyAssignment
where PADBID not in (select padbid from ResPolicyMap)
and PolicyAssignmentID = '{5906b4f9-4db7-4fd4-a9af-3a8fc4ac1671}'

select *
from ResPolicyMap
where PADBID not in (select padbid from PolicyAssignment)
and PADBID = '19135458'

select *
from SoftwarePolicy
where PADBID not in (select padbid from ResPolicyMap)
and PolicyAssignmentID = '{5906b4f9-4db7-4fd4-a9af-3a8fc4ac1671}'

select *
from SoftwarePolicy
where PADBID not in (select padbid from PolicyAssignment)
	  and PolicyAssignmentID = '{5906b4f9-4db7-4fd4-a9af-3a8fc4ac1671}'