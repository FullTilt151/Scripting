SELECT   distinct     dbo.v_R_System.Netbios_Name0 WKID, dbo.v_R_System.Operating_System_Name_and0 OS, dbo.v_GS_COMPUTER_SYSTEM.Manufacturer0, 
                         dbo.v_GS_COMPUTER_SYSTEM.Model0, dbo.v_GS_X86_PC_MEMORY.TotalPhysicalMemory0 RAM, 
                         dbo.v_GS_PC_BIOS.SMBIOSBIOSVersion0 [BIOS rev], 
                         dbo.v_GS_NETWORK_ADAPTER.Name0 AS [NIC],
						 dbo.v_GS_VIDEO_CONTROLLER.name0
FROM            dbo.v_R_System full JOIN
                         dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID left JOIN
                         dbo.v_GS_NETWORK_ADAPTER ON dbo.v_R_System.ResourceID = dbo.v_GS_NETWORK_ADAPTER.ResourceID LEFT JOIN
                         dbo.v_GS_PC_BIOS ON dbo.v_R_System.ResourceID = dbo.v_GS_PC_BIOS.ResourceID LEFT JOIN
                         dbo.v_GS_X86_PC_MEMORY ON dbo.v_R_System.ResourceID = dbo.v_GS_X86_PC_MEMORY.ResourceID LEFT JOIN
                         dbo.v_GS_VIDEO_CONTROLLER ON dbo.v_R_System.ResourceID = dbo.v_GS_VIDEO_CONTROLLER.ResourceID
where v_gs_computer_system.model0 = 'Optiplex 330' and 
		AdapterType0 = 'Ethernet 802.3' and 
		v_GS_NETWORK_ADAPTER.DeviceID0 = '1' and
		v_r_system.Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1' and
		v_GS_VIDEO_CONTROLLER.name0 != 'SMART technologies inc. mirror driver' and
		v_GS_VIDEO_CONTROLLER.name0 != 'bomgar display driver' and
		v_GS_VIDEO_CONTROLLER.name0 != 'configmgr remote control driver'
order by WKID