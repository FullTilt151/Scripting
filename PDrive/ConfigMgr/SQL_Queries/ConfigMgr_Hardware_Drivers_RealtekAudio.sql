select csp.Version0, DeviceName0, DriverVersion0, count(*)
from v_R_System_Valid sys join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on sys.ResourceID = csp.ResourceID join
	 v_GS_PNP_SIGNED_DRIVER_CUSTOM dvr on sys.ResourceID = dvr.ResourceID
where DeviceName0 = 'Realtek High Definition Audio'
group by csp.Vendor0, csp.Version0, DeviceName0, DriverVersion0
order by Version0, DriverVersion0