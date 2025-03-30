select Netbios_Name0 [WKID], sys.Build01, Version0 [Model], disk.FreeSpace0, TSP.Name [Task Sequence], ExecutionTime, ActionName,  
		ExitCode, master.dbo.fn_varbintohexstr(CONVERT(VARBINARY(8), ExitCode)) [ExitCodeHex]
from v_taskexecutionstatus TS full join
     v_r_system SYS ON TS.ResourceID = sys.ResourceID full join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID full join
	 v_AdvertisementInfo ADV ON TS.AdvertisementID = adv.AdvertisementID full join
	 v_TaskSequencePackage TSP ON adv.PackageID = tsp.PackageID join
	 v_GS_LOGICAL_DISK disk on sys.ResourceID = disk.ResourceID
where sys.Build01 in ('10.0.14393','10.0.15063','10.0.16299') and disk.DeviceID0 = 'C:' and
	 tsp.name in ('Windows 10 - ZTI - In-Place Upgrade 1703') and
		(ActionName = 'Upgrade Operating System' or ActionName = 'Check Readiness for Upgrade') and 
		ExitCode != 0
order by ExecutionTime DESC