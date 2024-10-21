select netbios_name0, DriverDesc0, DriverVersion0, CSP. Vendor0, CSP.Version0
from v_r_system SYS INNER JOIN
	 v_GS_NETWORK_DRIVERS NIC ON SYS.resourceid = NIC.Resourceid INNER JOIN
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON SYS.ResourceID = CSP.ResourceID
where DriverDesc0 like '%centrino%'


select CSP. Vendor0, CSP.Version0,DriverDesc0, DriverVersion0,  Count(*) [Count]
from v_r_system SYS INNER JOIN
	 v_GS_NETWORK_DRIVERS NIC ON SYS.resourceid = NIC.Resourceid INNER JOIN
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON SYS.ResourceID = CSP.ResourceID
where DriverDesc0 like '%centrino%' and DriverVersion0  NOT LIKE '15%' and Vendor0 = 'LENOVO'
GROUP BY DriverDesc0, DriverVersion0, CSP. Vendor0, CSP.Version0
order by Vendor0, Version0, DriverDesc0, DriverVersion0