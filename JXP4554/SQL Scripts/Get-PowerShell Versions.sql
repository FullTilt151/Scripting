SELECT STM.Netbios_Name0 [WKID],
	POSH.PowerShellVersion0 [Version],
	Posh.RuntimeVersion0 [RunTime]
FROM V_R_SYSTEM_vALID STM
JOIN v_GS_PowerShell0 POSH ON STM.resourceID = PoSH.ResourceID
