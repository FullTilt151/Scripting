SELECT     tb_CompletedOrder.CompletedOrderId, tb_Machine.MachineName, tb_CompletedOrder.AdvertId, tb_User.UserEmail, tb_Application.DisplayName, tb_CompletedOrder.CompletedTimestamp,
CASE DeliveryStatus
	   when 0 then 'Pending Deployment'
	   when 1 then 'Installed'
	   when 2 then 'Failed Install'
	   when 3 then 'Pending Install'
	   end [DeliveryStatus]
FROM         tb_CompletedOrder INNER JOIN
                      tb_Machine ON tb_CompletedOrder.MachineId = tb_Machine.MachineId INNER JOIN
                      tb_User ON tb_CompletedOrder.UserId = tb_User.UserId INNER JOIN
                      tb_Application ON tb_CompletedOrder.ApplicationId = tb_Application.ApplicationId
WHERE     (tb_CompletedOrder.AdvertId <> '' AND tb_CompletedOrder.ProgramName <> 'AppModel')
ORDER BY tb_CompletedOrder.CompletedTimestamp DESC