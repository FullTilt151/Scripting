select RequestedTimestamp, State, PackageName, DeliveryStatus, tb_user.FullName, tb_user.UserAccount , MachineName
from tb_CompletedOrder left join
	 tb_Machine on tb_CompletedOrder.MachineId = tb_machine.MachineId left join
	 tb_User on tb_CompletedOrder.UserId = tb_User.UserId
where DeliveryStatus = 0
order by RequestedTimestamp desc 