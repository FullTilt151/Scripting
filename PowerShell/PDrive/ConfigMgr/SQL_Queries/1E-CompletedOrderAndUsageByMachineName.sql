SELECT       co.CompletedOrderId,co.RequestedTimestamp,A.DisplayName,U.UserAccount,M.MachineName, 
		CASE CO.DeliveryStatus
		  WHEN 1 THEN 'SUCCESS'
		  WHEN 0 THEN 'UPROCESSED'
		  WHEN 2 THEN 'FAILED'
		  WHEN 3 THEN 'PENDING'
		END AS OrderStatus
FROM            tb_CompletedOrder CO INNER JOIN
                         tb_Machine M ON CO.MachineId = M.MachineId INNER JOIN
                         tb_User U ON co.UserId = U.UserId INNER JOIN
                         tb_Application A ON CO.ApplicationId = A.ApplicationId
WHERE M.MachineName  like '%WKMP19TZZQ%' AND U.UserAccount like '%'  


SELECT   A.DisplayName,SI.SoftwareUsage,M.MachineName
FROM            tb_SoftwareInventoryItem SI INNER JOIN
                         tb_Machine M ON SI.MachineId = M.MachineId INNER JOIN
                         tb_Application A ON SI.RequestItemId = A.ApplicationId
WHERE M.MachineName like '%WKMP19TZZQ%' 