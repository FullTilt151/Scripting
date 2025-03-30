select DATEPART(year,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp)) [Year], 
	   DATEPART(month,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp)) [MonthSort], 
	   case
	   DATEPART(month,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp)) 
	   when '1' then 'January'
	   when '2' then 'February'
	   when '3' then 'March'
	   when '4' then 'April'
	   when '5' then 'May'
	   when '6' then 'June'
	   when '7' then 'July'
	   when '8' then 'August'
	   when '9' then 'September'
	   when '10' then 'October'
	   when '11' then 'November'
	   when '12' then 'December'
	   end [Month], 

	   case DeliveryStatus
	   when 0 then 'Pending Install'
	   when 1 then 'Installed'
	   when 2 then 'Failed Install'
	   when 3 then 'Pending Install'
	   end [DeliveryStatus], 

	   case DeliveryStatus
	   when 1 then 1
	   when 0 then 2
	   when 2 then 3
	   when 3 then 2
	   end [StatusSort],   
	   count(*) [Total]

from tb_CompletedOrder full join
	 tb_Machine on tb_CompletedOrder.MachineId = tb_machine.MachineId full join
	 tb_User on tb_CompletedOrder.TargetUserId = tb_user.UserId

where DeliveryStatus is not NULL and DATEPART(year,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp)) = '2016'
GROUP BY DATEPART(year,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp)), 
		 DATEPART(month,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp)) ,
		 case DeliveryStatus
	     when 0 then 'Pending Install'
	     when 1 then 'Installed'
	     when 2 then 'Failed Install'
	     when 3 then 'Pending Install'
	     end,
		 case DeliveryStatus
	     when 1 then 1
	     when 0 then 2
	     when 2 then 3
	     when 3 then 2
	     end		 
order by DATEPART(month,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp)), 
		 DATEPART(year,DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), RequestedTimestamp))