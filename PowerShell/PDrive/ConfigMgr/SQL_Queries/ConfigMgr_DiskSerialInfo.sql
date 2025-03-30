SELECT     sys.Netbios_Name0 [Name], se.SerialNumber0 [Serial], disk.Caption0 [Disk], 
			case 
			when disk.Caption0 like 'ST%' then 'Seagate'
			when disk.Caption0 like 'WDC%' then 'Western Digital'
			when disk.Caption0 like 'HITACHI%' then 'Hitachi'
			when disk.Caption0 like 'Toshiba%' then 'Toshiba'
			end [Mfg],
			disk.size0 [Disk Size], disk.DeviceID0 [Disk Device ID], pm.SerialNumber0 [Disk Serial]
FROM         v_R_System SYS JOIN
             v_GS_DISK DISK ON sys.ResourceID = DISK.ResourceID left JOIN
			 v_GS_CUSTOM_PHYSICAL_MEDIA0 PM on sys.ResourceID = pm.ResourceID and disk.DeviceID0 = pm.Tag0 left join
			 v_GS_SYSTEM_ENCLOSURE SE on sys.ResourceID = se.ResourceID
where disk.Caption0 != 'VMware Virtual disk SCSI Disk Device' and Netbios_Name0 like @Var
order by Netbios_Name0, disk.Caption0