-- Network card driver list
select distinct DriverDesc0 [Driver]
from v_r_system SYS join
	 v_GS_NETWORK_drivers NET ON sys.ResourceID = NET.ResourceID
where Operating_System_Name_and0 like '%workstation%' and
	  DriverDesc0 NOT LIKE '%WAN Miniport%' and
	  DriverDesc0 != 'RAS Async Adapter' and
	  DriverDesc0 != 'Packet Scheduler Miniport' and
	  DriverDesc0 != 'Array Networks SSL VPN Adapter' and
	  DriverDesc0 NOT LIKE '%VPN%' and
	  DriverDesc0 NOT LIKE '%Microsoft%' and
	  DriverDesc0 NOT LIKE '%bluetooth%' and
	  DriverDesc0 NOT LIKE '%juniper%' and
	  DriverDesc0 NOT LIKE '%apple%' and
	  DriverDesc0 NOT LIKE '%blackberry%' and
	  DriverDesc0 NOT LIKE '%wwan%' and
	  DriverDesc0 NOT LIKE '%lte%' and
	  DriverDesc0 NOT LIKE '%ndis%' and
	  DriverDesc0 NOT LIKE '%sierra wireless%' and
	  DriverDesc0 NOT LIKE '%virtual%' and
	  DriverDesc0 NOT LIKE '%vmware%' and
	  DriverDesc0 != 'vmxnet3 Ethernet Adapter' and
	  DriverDesc0 NOT LIKE '%USB%' and
	  DriverDesc0 != 'Direct Parallel' and
	  DriverDesc0 != 'ThinkPad OneLink Pro Dock Giga Ethernet' and
	  DriverDesc0 != '1394 Net Adapter' and
	  DriverDesc0 NOT LIKE '%HUAWEI%' and
	  MediaType0 != '3'
order by DriverDesc0

-- Network card and driver List
select sys.Netbios_Name0 [WKID], CS.Manufacturer0 [Mfg], CS.Model0 [Model Number], CSP.Version0 [Model Name], 
	   case SYS.operating_system_name_and0 
	   WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
	   WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
	   WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
	   WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
	   end as [OS]
	   , DriverDesc0 [Driver], DriverVersion0 [Driver Version]
from v_r_system SYS join
	 v_GS_NETWORK_drivers NET ON sys.ResourceID = NET.ResourceID join
	 v_GS_COMPUTER_SYSTEM CS ON SYS.ResourceID = CS.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = CSP.ResourceID
where Operating_System_Name_and0 like '%workstation%' and
	  DriverDesc0 NOT LIKE '%WAN Miniport%' and
	  DriverDesc0 != 'RAS Async Adapter' and
	  DriverDesc0 != 'Packet Scheduler Miniport' and
	  DriverDesc0 != 'Array Networks SSL VPN Adapter' and
	  DriverDesc0 NOT LIKE '%VPN%' and
	  DriverDesc0 NOT LIKE '%Microsoft%' and
	  DriverDesc0 NOT LIKE '%bluetooth%' and
	  DriverDesc0 NOT LIKE '%juniper%' and
	  DriverDesc0 NOT LIKE '%apple%' and
	  DriverDesc0 NOT LIKE '%blackberry%' and
	  DriverDesc0 NOT LIKE '%wwan%' and
	  DriverDesc0 NOT LIKE '%lte%' and
	  DriverDesc0 NOT LIKE '%ndis%' and
	  DriverDesc0 NOT LIKE '%sierra wireless%' and
	  DriverDesc0 NOT LIKE '%virtual%' and
	  DriverDesc0 NOT LIKE '%vmware%' and
	  DriverDesc0 != 'vmxnet3 Ethernet Adapter' and
	  DriverDesc0 NOT LIKE '%USB%' and
	  DriverDesc0 != 'Direct Parallel' and
	  DriverDesc0 != 'ThinkPad OneLink Pro Dock Giga Ethernet' and
	  DriverDesc0 != '1394 Net Adapter' and
	  DriverDesc0 NOT LIKE '%HUAWEI%' and
	  MediaType0 != '3'
order by DriverDesc0, DriverVersion0, Version0, Model0, netbios_name0

-- Network card and driver COUNT
select CS.Manufacturer0, CS.Model0, CSP.Version0, 
	   case SYS.operating_system_name_and0 
	   WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
	   WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
	   WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
	   WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
	   end as [OS]
	   , DriverDesc0 [Driver], DriverVersion0 [Driver Version], count(*) [Total]
from v_r_system SYS join
	 v_GS_NETWORK_drivers NET ON sys.ResourceID = NET.ResourceID join
	 v_GS_COMPUTER_SYSTEM CS ON SYS.ResourceID = CS.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = CSP.ResourceID
where Operating_System_Name_and0 like '%workstation%' and
	  DriverDesc0 NOT LIKE '%WAN Miniport%' and
	  DriverDesc0 != 'RAS Async Adapter' and
	  DriverDesc0 != 'Packet Scheduler Miniport' and
	  DriverDesc0 != 'Array Networks SSL VPN Adapter' and
	  DriverDesc0 NOT LIKE '%VPN%' and
	  DriverDesc0 NOT LIKE '%Microsoft%' and
	  DriverDesc0 NOT LIKE '%bluetooth%' and
	  DriverDesc0 NOT LIKE '%juniper%' and
	  DriverDesc0 NOT LIKE '%apple%' and
	  DriverDesc0 NOT LIKE '%blackberry%' and
	  DriverDesc0 NOT LIKE '%wwan%' and
	  DriverDesc0 NOT LIKE '%lte%' and
	  DriverDesc0 NOT LIKE '%ndis%' and
	  DriverDesc0 NOT LIKE '%sierra wireless%' and
	  DriverDesc0 NOT LIKE '%virtual%' and
	  DriverDesc0 NOT LIKE '%vmware%' and
	  DriverDesc0 != 'vmxnet3 Ethernet Adapter' and
	  DriverDesc0 NOT LIKE '%USB%' and
	  DriverDesc0 != 'Direct Parallel' and
	  DriverDesc0 != 'ThinkPad OneLink Pro Dock Giga Ethernet' and
	  DriverDesc0 != '1394 Net Adapter' and
	  DriverDesc0 NOT LIKE '%HUAWEI%' and
	  MediaType0 != '3'
group by CS.Manufacturer0, CS.Model0, CSP.Version0,
	   case SYS.operating_system_name_and0 
	   WHEN 'Microsoft Windows NT Workstation 5.1' THEN 'Windows XP'
	   WHEN 'Microsoft Windows NT Workstation 6.1' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' THEN 'Windows 7'
	   WHEN 'Microsoft Windows NT Workstation 6.2' THEN 'Windows 8'
	   WHEN 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' THEN 'Windows 8.1'
	   WHEN 'Microsoft Windows NT Workstation 6.3' THEN 'Windows 8.1'
	   end, 
	   DriverDesc0,DriverVersion0
order by DriverDesc0, DriverVersion0, Version0, Model0

-- Video card and driver
select Name0, VideoProcessor0, DeviceID0,  DriverVersion0, DriverDate0, InstalledDisplayDrivers0
from v_GS_VIDEO_CONTROLLER

-- Sound card, NO DRIVERS
select Manufacturer0, Name0, DeviceID0
from v_GS_sound_device

-- All hardware, NO DRIVERS
select SystemName0, Manufacturer0, Name0, ClassGuid0, DeviceID0, Service0, Status0
from v_GS_PNP_DEVICE_DRIVER
where SystemName0 like 'WKMPMP3Y455' 
	  and status0 = 'OK' 
	  and Manufacturer0 NOT LIKE '(%'
	  and Manufacturer0 != 'Microsoft'
order by Name0

-- All hardware, NO DRIVERS
select SystemName0, DisplayName0, Name0, PathName0
from v_GS_SYSTEM_DRIVER

-- All network drivers list
select DeviceClass0, DeviceName0, DriverDate0, DriverProviderName0, DriverVersion0
from v_gs_pnp_signed_driver_custom
where DeviceClass0 = 'NET' and
	  DeviceName0 != 'Array Networks SSL VPN Adapter'

-- All LAN network drivers count
select DeviceName0 [Name], DriverVersion0 [Version], count(*) [Total]
from v_gs_pnp_signed_driver_custom
where DeviceClass0 = 'NET' and 
	  DriverProviderName0 in (
	  'Broadcom',
	  'Intel',
	  'Marvell',
	  'Microsoft Corporation',
	  'Realtek',
	  'Realtek Semiconductor Corp.') and
	  DeviceName0 not in (
	  'ThinkPad OneLink Pro Dock Giga Ethernet',
	  'Thinkpad USB 3.0 Ethernet Adapter',
	  'Microsoft Windows Mobile Remote Adapter',
	  'Remote NDIS based Internet Sharing Device') and (
	  DeviceName0 not like '%Wireless%' and
	  DeviceName0 not like '%WLAN%' and
	  DeviceName0 not like '%Centrino%' and
	  DeviceName0 not like '%WiFi%')
group by DeviceName0, DriverProviderName0, DriverVersion0
order by DriverProviderName0, DeviceName0, DriverVersion0

-- All WLAN network drivers count
select DeviceName0 [Name], DriverVersion0 [Version], count(*) [Total]
from v_gs_pnp_signed_driver_custom
where DeviceClass0 = 'NET' and 
	  DriverProviderName0 in (
	  'Broadcom',
	  'Intel',
	  'Marvell',
	  'Microsoft Corporation',
	  'Realtek',
	  'Realtek Semiconductor Corp.') and
	  DeviceName0 not in (
	  'ThinkPad OneLink Pro Dock Giga Ethernet',
	  'Thinkpad USB 3.0 Ethernet Adapter',
	  'Microsoft Windows Mobile Remote Adapter',
	  'Remote NDIS based Internet Sharing Device') and (
	  DeviceName0 like '%Wireless%' or
	  DeviceName0 like '%WLAN%' or
	  DeviceName0 like '%Centrino%' or
	  DeviceName0 like '%WiFi%')
group by DeviceName0, DriverProviderName0, DriverVersion0
order by DriverProviderName0, DeviceName0, DriverVersion0