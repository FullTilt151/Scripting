/*
Update tb_CompletedOrder
Set DeliveryStatus = 0
From tb_CompletedOrder COD
join tb_Machine MAC on COD.MachineId = MAC.MachineId
where MAC.MachineName in ('LOUXDWSTDB0940', 'LOUXDWSTDB0941', 'LOUXDWSTDB0942', 'LOUXDWSTDB0943', 'LOUXDWSTDB0944', 'LOUXDWSTDB0945') and DeliveryStatus = 3
*/

SELECT COD.CompletedOrderId, COD.MachineId, MAC.MachineName, COD.State, COD.PackageName, COD.PackageId, COD.AdvertId, COD.DeliveryStatus, COD.DateInstalled
from tb_CompletedOrder COD 
join tb_Machine MAC on COD.MachineId = MAC.MachineId
where MAC.MachineName = 'WKMJLTWRW'

--update tb_Machine
--set ResourceGuid = 'GUID:CF6BD3F1-1BA2-4915-BEED-8A76A7B66B8E'
--where MachineName = 'LOUXDWSTDB0945'

select MachineName,ResourceGuid
from tb_Machine
where MachineName in ('LOUXDWSTDB0942', 'LOUXDWSTDB0943', 'LOUXDWSTDB0944', 'LOUXDWSTDB0945')
order by MachineName
