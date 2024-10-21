select convert(varchar, RequestedTimestamp, 22)[Time Requested], convert(varchar, CompletedTimestamp, 22)[Time Completed], State, PackageName, PackageID, case DeliveryStatus
	   when 0 then 'Pending Deployment'
	   when 1 then 'Installed'
	   when 2 then 'Failed Install'
	   when 3 then 'Pending Install'
	   end [DeliveryStatus], tb_user.FullName, tb_user.UserAccount , DomainName, MachineName
from tb_CompletedOrder left join
	 tb_Machine on tb_CompletedOrder.MachineId = tb_machine.MachineId left join
	 tb_User on tb_CompletedOrder.UserId = tb_User.UserId
	 where MachineName = 'WKR90NQM6S'
order by RequestedTimestamp desc
----


select MachineName, tb_Processing.State, PackageName, PackageId, AdvertId, DeliveryStatus, DateInstalled, FailureEmailSent, NeedsInventoryUpdate
from tb_CompletedOrder left join
	tb_Machine on tb_CompletedOrder.MachineId = tb_machine.MachineId left join
	tb_Processing on tb_CompletedOrder.MachineId = tb_Processing.MachineId
where MachineName = ''


select * --RequestTimestamp, MachineName, state, ShopperComments
from tb_Processing pro
join tb_machine mac on pro.MachineId = mac.MachineId
where MachineName = ''
order by RequestTimestamp desc

select *
from tb_Application app
join tb_CompletedOrder co on app.ApplicationId = co.ApplicationId


-- Citrix server requests
select mac.MachineName, co.*
from tb_CompletedOrder CO join
	 tb_machine MAC on CO.MachineId = mac.MachineId
where machinename like '%cmf%'
order by RequestedTimestamp desc


/*
delete from
tb_Machine
where MachineName = 'WKMJ39P6H'

delete from
tb_osdWizard
where machineID = 20698
*/
