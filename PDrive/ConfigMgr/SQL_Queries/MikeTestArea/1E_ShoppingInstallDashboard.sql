SELECT 
  UserAccount, FullName, MachineName,
  CASE
    WHEN OSVersion = '6.1.7601' THEN 'Windows 7'
    WHEN OSVersion LIKE '10.0%' THEN 'Windows 10'
  END [OS], PackageName, AdvertID,
  CASE DeliveryStatus
    WHEN 0 THEN 'Pending Deployment'
    WHEN 1 THEN 'Installed'
    WHEN 2 THEN 'Failed Install'
    WHEN 3 THEN 'Pending Install'
  END [DelivertStatus],
  DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp) [RequestedTimestamp],
  DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), DateInstalled) [DateInstalled],
 CASE 
	WHEN CAST(DATEDIFF(mi, RequestedTimestamp, DateInstalled) AS varchar) < 60 THEN CAST(DATEDIFF(mi, RequestedTimestamp, DateInstalled) AS varchar) + ' minute(s)'
	WHEN CAST(DATEDIFF(mi, RequestedTimestamp, DateInstalled) AS varchar) >= 60 AND CAST(DATEDIFF(mi, RequestedTimestamp, DateInstalled) AS varchar) < 1440 THEN CAST(DATEDIFF(mi, RequestedTimestamp, DateInstalled)/60 AS varchar) + ' hour(s)'
	WHEN CAST(DATEDIFF(mi, RequestedTimestamp, DateInstalled) AS varchar) >= 1440 THEN CAST(DATEDIFF(mi, RequestedTimestamp, DateInstalled)/60/24 AS varchar) + ' day(s)'
  END [Install Time]
	
FROM tb_CompletedOrder
FULL JOIN tb_Machine
  ON tb_CompletedOrder.MachineId = tb_machine.MachineId
FULL JOIN tb_User
  ON tb_CompletedOrder.TargetUserId = tb_user.UserId
WHERE PackageName = @Application
ORDER BY RequestedTimestamp DESC