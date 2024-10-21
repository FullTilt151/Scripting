SELECT     dbo.v_R_System.Netbios_Name0 AS WKID, dbo.v_R_System.User_Name0 AS UserName, dbo.v_R_User.Full_User_Name0 AS [Full User Name], 
                      dbo.v_GS_OPERATING_SYSTEM.Caption0 AS OS, dbo.v_GS_COMPUTER_SYSTEM.Manufacturer0 as Make, dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Version0 as Model, dbo.v_GS_COMPUTER_SYSTEM.Model0 as [Model Number], 
                      Round(dbo.v_GS_X86_PC_MEMORY.TotalPhysicalMemory0/1024,2) AS [RAM in MB], dbo.v_GS_PROCESSOR.Is64Bit0 as [x64 CPU]
FROM         dbo.v_R_System INNER JOIN
                      dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID INNER JOIN
                      dbo.v_GS_COMPUTER_SYSTEM_PRODUCT ON dbo.v_R_System.ResourceID = dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.ResourceID INNER JOIN
                      dbo.v_GS_X86_PC_MEMORY ON dbo.v_R_System.ResourceID = dbo.v_GS_X86_PC_MEMORY.ResourceID INNER JOIN
                      dbo.v_R_User ON dbo.v_R_System.User_Name0 = dbo.v_R_User.User_Name0 INNER JOIN
                      dbo.v_GS_PROCESSOR ON dbo.v_R_System.ResourceID = dbo.v_GS_PROCESSOR.ResourceID
where (dbo.v_GS_OPERATING_SYSTEM.Caption0 = 'Microsoft Windows XP Professional') and (v_GS_COMPUTER_SYSTEM.Manufacturer0 != 'VMWare, Inc.')
order by WKID