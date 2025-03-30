-- Check to see if the PolicyAssignment and PoclyColMap are in sync - Should get 0 rows
Select 
            PolicyAssignment.PADBID, 
            PolicyAssignment.PolicyAssignmentID,
            PolicyAssignment.Version, 
            PolicyAssignment.PolicyID, 
            PolicyAssignment.Body, 
            PolicyAssignment.LastUpdateTime, 
            PolicyAssignment.IsTombstoned, 
            PolicyAssignment.InProcess,
            PolicyCollMap.IsTombstoned [PolicyCollMap IsTombStoned]
from PolicyAssignment join PolicyCollMap
      on PolicyAssignment.PADBID = PolicyCollMap.PADBID
where PolicyAssignment.IsTombstoned =1 and PolicyCollMap.IsTombstoned = 0

/*

-- If you get any rows back from the above query, this will fix it.

Update PolicyAssignment
set IsTombstoned = 1
from ResPolPolicyAssignmenticyMap
where PADBID in (
SELECT     PADBID
FROM         PolicyAssignment
WHERE     (IsTombstoned = 1)
) and IsTombstoned = 0
*/

-- Check to see if the PolicyAssignment and ResPolicyMap are in sync - Should get 0 rows
SELECT   
            PolicyAssignment.PADBID, 
            PolicyAssignment.PolicyAssignmentID,
            PolicyAssignment.Version, 
            PolicyAssignment.PolicyID, 
            PolicyAssignment.Body, 
            PolicyAssignment.LastUpdateTime, 
            PolicyAssignment.IsTombstoned, 
            PolicyAssignment.InProcess, 
            ResPolicyMap.LastUpdateTime AS [ResPolicyMap Update Time], 
            ResPolicyMap.TargetSourceID, 
            ResPolicyMap.IsTombstoned AS [ResPolicyMap Tombstone], 
            DATEDIFF(D,PolicyAssignment.LastUpdateTime,GETDATE()) [Days Tombstoned]
FROM    PolicyAssignment INNER JOIN
        ResPolicyMap ON PolicyAssignment.PADBID = ResPolicyMap.PADBID
WHERE   (PolicyAssignment.IsTombstoned = 1) 
            and (ResPolicyMap.IsTombstoned = 0)

/*

-- If you get any rows back from the above query, this will fix it.

Update ResPolicyMap
set IsTombstoned = 1
from ResPolicyMap
where PADBID in (
SELECT     PADBID
FROM         PolicyAssignment
WHERE     (IsTombstoned = 1)
) and IsTombstoned = 0
*/