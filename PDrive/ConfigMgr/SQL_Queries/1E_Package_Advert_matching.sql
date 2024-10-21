SELECT	COD.CompletedOrderId, MCN.MachineName, COD.PackageId, COD.AdvertId
FROM	tb_CompletedOrder COD INNER JOIN
		tb_Machine MCN ON COD.MachineId = MCN.MachineId
WHERE	(COD.DeliveryStatus = 3)