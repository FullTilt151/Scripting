DECLARE @Disk VARCHAR(255)

SET @Disk = 'Toshiba%'

SELECT sys.Netbios_Name0 [Name],
	se.SerialNumber0 [Serial],
	DISK.Caption0 [Disk],
	DISK.size0 [Disk Size],
	DISK.DeviceID0 [Disk Device ID],
	COALESCE(MDSK.AdapterSerialNumber0, pm.SerialNumber0) [Disk Serial]
FROM v_R_System SYS
JOIN v_GS_DISK DISK
	ON sys.ResourceID = DISK.ResourceID
LEFT JOIN v_GS_CUSTOM_PHYSICAL_MEDIA0 PM
	ON sys.ResourceID = pm.ResourceID
		AND DISK.DeviceID0 = pm.Tag0
LEFT JOIN v_GS_SYSTEM_ENCLOSURE SE
	ON sys.ResourceID = se.ResourceID
LEFT JOIN v_GS_MSFT_DISK MDSK
	ON sys.resourceID = mdsk.resourceID
WHERE DISK.Caption0 LIKE @Disk
ORDER by sys.Netbios_Name0