select SYS.netbios_name0 WKID, SD.itemkey ResourceID, MAC.MAC_Addresses0, SD.SMS_Unique_Identifier0,SD.Hardware_ID0,SD.Name0,SD.Unknown0,SD.Obsolete0,SD.Active0,SD.Decommissioned0,SD.Creation_Date0,SD.SMBIOS_GUID0
from System_DISC SD FULL JOIN
	 v_r_system SYS ON SD.itemkey = SYS.resourceid FULL JOIN
	 System_MAC_Addres_ARR MAC ON SD.itemkey = MAC.ItemKey
--where SD.Unknown0 = 1
where MAC_Addresses0 = '54:ee:75:1f:15:04' OR SD.SMBIOS_GUID0 = ''

select * from Network_DATA
where MACAddress00 = '00:00:00:00:00:00'