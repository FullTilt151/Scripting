select sys.Netbios_Name0, ip.IP_Addresses0, drv.DeviceClass0, DeviceName0, DriverVersion0
from v_R_system sys left join
	 v_RA_System_IPAddresses IP on sys.ResourceID = ip.ResourceID left join
	 v_GS_PNP_SIGNED_DRIVER_CUSTOM DRV on sys.ResourceID = drv.ResourceID
where sys.Netbios_Name0 like 'WKMP05223G'


	  and DeviceClass0 in ('NET', 'DISPLAY', 'HDC')