SELECT
  tb_CompletedOrder.CompletedOrderId,
  tb_Machine.MachineName,
  tb_CompletedOrder.AdvertId,
  tb_CompletedOrder.PackageId,
  tb_CompletedOrder.OrderType,
  tb_User.FullName,
  tb_user.UserAccount,
  tb_User.UserEmail,
  tb_Application.DisplayName,
  tb_Application.ApplicationRef,
  tb_CompletedOrder.DeliveryStatus
FROM tb_CompletedOrder
INNER JOIN tb_Machine
  ON tb_CompletedOrder.MachineId = tb_Machine.MachineId
INNER JOIN tb_User
  ON tb_CompletedOrder.UserId = tb_User.UserId
INNER JOIN tb_Application
  ON tb_CompletedOrder.ApplicationId = tb_Application.ApplicationId
LEFT JOIN Humana_Status_Email_Sent EMS
  ON EMS.CompletedOrderID = tb_CompletedOrder.CompletedOrderId
WHERE ((tb_CompletedOrder.DeliveryStatus = 1) /*Installed*/
OR (tb_CompletedOrder.DeliveryStatus = 3))  /*Pending Install*/
AND (tb_CompletedOrder.AdvertId <> '')
AND (tb_CompletedOrder.ProgramName <> 'AppModel')
AND (DATEDIFF(DAY, RequestedTimestamp, GETDATE()) < 3)
AND ((EMS.mailsent IS NULL)
OR (EMS.mailsent <> tb_completedorder.deliverystatus))
ORDER BY tb_CompletedOrder.CompletedOrderId