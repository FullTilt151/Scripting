-- List of status
select UserAccount, FullName, MachineName, PackageName, AdvertID,
	   case DeliveryStatus
	   when 0 then 'Pending Deployment'
	   when 1 then 'Installed'
	   when 2 then 'Failed Install'
	   when 3 then 'Pending Install'
	   end [DelivertStatus], 
	   DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp) [RequestedTimestamp], 
	   DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), DateInstalled) [DateInstalled], 
	   CAST(DATEDIFF(mi, RequestedTimestamp, DateInstalled) as varchar) + ' minutes' [Install Time]
from tb_CompletedOrder full join
	 tb_Machine on tb_CompletedOrder.MachineId = tb_machine.MachineId full join
	 tb_User on tb_CompletedOrder.TargetUserId = tb_user.UserId
where PackageName = 'Internet Explorer 11'
order by RequestedTimestamp DESC

-- Count of status
select case DeliveryStatus
	   when 0 then 'Pending Deployment'
	   when 1 then 'Installed'
	   when 2 then 'Failed Install'
	   when 3 then 'Pending Install'
	   end [DeliveryStatus], count(*) [Total]
from tb_CompletedOrder
where PackageName = 'Internet Explorer 11'
group by DeliveryStatus

-- Trending
select PackageName, 
	   case
	   DATEPART(month,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp)) 
	   when '1' then 'January'
	   when '2' then 'February'
	   when '3' then 'March'
	   when '4' then 'April'
	   when '5' then 'May'
	   when '6' then 'June'
	   end [Month], 
	   DATEPART(day,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp)) [Day]
from tb_CompletedOrder full join
	 tb_Machine on tb_CompletedOrder.MachineId = tb_machine.MachineId full join
	 tb_User on tb_CompletedOrder.TargetUserId = tb_user.UserId
where PackageName = 'Internet Explorer 11'
order by RequestedTimestamp DESC