select tb_Machine.MachineName, tb_CompletedOrder.*
from tb_CompletedOrder left join
	 tb_Machine on tb_CompletedOrder.MachineId = tb_Machine.MachineId
where MachineName not like 'WK%' and MachineName not like 'LOUXDW%' and MachineName not like 'SIMXDW%' and MachineName not like 'DSI%' and MachineName not like 'tr%' 
	  and MachineName not like 'vmm%'
	  and MachineName not like 'kmg%'
order by RequestedTimestamp desc