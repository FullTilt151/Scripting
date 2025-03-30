SELECT	U.FullName as Shopper,
		M.MachineName,
		A.DisplayName,
		COA.DateTimeStamp As ApprovedTimeStamp, 
		COA.ApproverAccount As Approver, 
		CO.CompletedTimeStamp,
		CO.PackageID,
		CO.PackageName,
		CO.ProgramName,
		CO.Cost 
FROM	tb_CompletedOrder_Approvers COA
			INNER JOIN tb_CompletedOrder CO ON COA.CompletedOrderID = CO.CompletedOrderId
			INNER JOIN tb_User U ON CO.UserId = U.UserId 
			INNER JOIN tb_Machine M ON M.MachineId = CO.MachineId 
			INNER JOIN tb_Application A ON A.ApplicationId = CO.ApplicationId 
WHERE	CO.State = 'APPROVED'
--AND		CO.RequestedTimeStamp >= @RequestedDate
--AND		CO.CompletedTimeStamp < @CompletedDate
--AND		A.DisplayName = @DisplayName
ORDER BY Shopper, M.MachineName


select distinct u.fullname 
from tb_user u
order by FullName