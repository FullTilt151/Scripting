select Netbios_Name0 [WKID], sys.AD_Site_Name0 [AD site], max(ip.IP_Addresses0) [IP], Caption0 [Printer]
from v_r_system_valid sys join
	 v_GS_USB_DEVICE usb on sys.ResourceID = usb.ResourceID join
	 v_RA_System_IPAddresses ip on sys.ResourceID = ip.ResourceID
where name0 = 'EPSON USB Controller for TM/BA/EU Printers'
group by Netbios_Name0, AD_Site_Name0, Caption0
order by Netbios_Name0