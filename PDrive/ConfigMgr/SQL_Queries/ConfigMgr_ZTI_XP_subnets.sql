select distinct DefaultIPGateway0, Count(ipaddress0) [Total]
from v_r_system SYS INNER JOIN
	 v_GS_NETWORK_ADAPTER_CONFIGURATION NIC ON SYS.resourceid = NIC.resourceid
where operating_system_name_and0 = 'Microsoft Windows NT Workstation 5.1' and IPEnabled0='1' and
      DefaultIPGateway0 != '133.17.0.1' and
	  DefaultIPGateway0 NOT LIKE '10.0.%' and
	  DefaultIPGateway0 NOT LIKE '10.1.%' and
	  DefaultIPGateway0 NOT LIKE '10.10.%' and
	  DefaultIPGateway0 NOT LIKE '192.168.%' 
GROUP BY DefaultIPGateway0
ORDER BY DefaultIPGateway0

select Netbios_Name0, Operating_System_Name_and0, Client0, DefaultIPGateway0, CAST(Size0/1024 as varchar) + ' GB' [Disk Size], CAST(FreeSpace0/1024 as varchar)  + ' GB' [Free Space]
from v_r_system INNER JOIN
	v_GS_NETWORK_ADAPTER_CONFIGURATION ON v_r_system.ResourceID = v_GS_NETWORK_ADAPTER_CONFIGURATION.ResourceID INNER JOIN
	v_GS_LOGICAL_DISK ON v_r_system.ResourceID = v_GS_LOGICAL_DISK.ResourceID
where DefaultIPGateway0 like '32.32.156.%' and FreeSpace0 IS NOT NULL
--where DefaultIPGateway0 like '193.80.40.%'
ORDER BY DefaultIPGateway0, DNSHostName0