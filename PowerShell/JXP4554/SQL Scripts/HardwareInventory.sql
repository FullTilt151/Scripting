SELECT STM.Netbios_Name0 [WKID],
	COALESCE(DSK.AdapterSerialNumber0, DSK2.SerialNumber0) [Calculated Serial Number],
	--These two lines should not be in the report, but are to confirm we are getting correct data
	DSK.AdapterSerialNumber0 [Adapter Serial Number],
	dsk2.SerialNumber0 [Serial Number]
FROM V_R_System_Valid STM
JOIN v_GS_MSFT_DISK DSK
	ON STM.ResourceID = DSK.ResourceID
JOIN v_GS_CUSTOM_PHYSICAL_MEDIA0 DSK2
	ON STM.ResourceID = DSK2.ResourceID