select sys.Netbios_Name0 [Name], sys.AD_Site_Name0 [AD Site], sys.Operating_System_Name_and0 [OS], ip.IP_Subnets0 [Subnet]
from v_r_system_valid sys join
	 v_GS_USB_DEVICE usb on sys.ResourceID = usb.ResourceID join
	 v_RA_System_IPSubnets IP on sys.ResourceID = ip.ResourceID
where name0 = 'EPSON USB Controller for TM/BA/EU Printers'
order by sys.Netbios_Name0