SELECT	U.FullName as Shopper,
		M.MachineName,
		A.DisplayName,
		CO.CompletedTimeStamp,
		CO.PackageID,
		CO.PackageName,
		CO.ProgramName,
		CO.Cost 
FROM	tb_CompletedOrder CO
			INNER JOIN tb_User U ON CO.UserId = U.UserId 
			INNER JOIN tb_Machine M ON M.MachineId = CO.MachineId 
			INNER JOIN tb_Application A ON A.ApplicationId = CO.ApplicationId 
WHERE	U.FullName = 'Michael  Cook'
--AND		CO.RequestedTimeStamp >= @RequestedDate
--AND		CO.CompletedTimeStamp < @CompletedDate
--AND		A.DisplayName = @DisplayName
ORDER BY CompletedTimestamp


select fullname
from tb_User
where fullname like '%cook%'

select *
from tb_CompletedOrder

