-- List of WKIDs
SELECT distinct SYS.Netbios_Name0 WKID, case sys.Operating_System_Name_and0 
					when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
					when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
					when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
					end [OS], sys.build01 [Build], MAX(ou.System_OU_Name0) OU, dbo.v_R_User.User_Name0 [User], dbo.v_R_User.Full_User_Name0 [Full Username], 
                        dbo.v_GS_COMPUTER_SYSTEM.Manufacturer0 [Make], dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Version0 [Model], dbo.v_GS_COMPUTER_SYSTEM.Model0 [Model Number], 
						BL.ProtectionStatus0 [Bitlocker], SYS.Is_Virtual_Machine0 [VM], OS.InstallDate0, CLI.LastActiveTime [Last Active]
FROM            dbo.v_R_System SYS INNER JOIN
                dbo.v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID INNER JOIN
                dbo.v_GS_COMPUTER_SYSTEM ON SYS.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID full join
                dbo.v_GS_COMPUTER_SYSTEM_PRODUCT ON SYS.ResourceID = dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.ResourceID full JOIN
                dbo.v_R_User ON SYS.User_Name0 = dbo.v_R_User.User_Name0 full JOIN
				dbo.v_CH_ClientSummary CLI ON SYS.ResourceID = CLI.ResourceID left join
				dbo.v_RA_System_SystemOUName OU on sys.ResourceID = ou.ResourceID left join
				dbo.v_GS_ENCRYPTABLE_VOLUME BL on sys.ResourceID = BL.ResourceID
where SYS.Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 6.2', 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)', 
										 'Microsoft Windows NT Workstation 6.3', 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)',
										 'Microsoft Windows NT Workstation 10.0', 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
group by SYS.Netbios_Name0, case sys.Operating_System_Name_and0 
					when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
					when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
					when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
					end, sys.build01, dbo.v_R_User.User_Name0, dbo.v_R_User.Full_User_Name0, 
                        dbo.v_GS_COMPUTER_SYSTEM.Manufacturer0 , dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Version0, dbo.v_GS_COMPUTER_SYSTEM.Model0, 
						bl.ProtectionStatus0, SYS.Is_Virtual_Machine0, OS.InstallDate0, CLI.LastActiveTime
order by os.InstallDate0 desc

-- Count of WKIDs
SELECT distinct case sys.Operating_System_Name_and0 
					when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
					when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
					when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
					end [OS], 
				case sys.Build01
				when '10.0.10586' then '1511'
				when '10.0.14393' then '1607'
				when '10.0.15063' then '1703'
				when '10.0.16299' then '1709'
				when '10.0.17134' then '1803'
				end [Release],
				count(sys.ResourceID) [Total]
FROM            dbo.v_R_System SYS
where Client0 = 1 and SYS.Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 6.2', 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)', 
										 'Microsoft Windows NT Workstation 6.3', 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)',
										 'Microsoft Windows NT Workstation 10.0', 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
group by case sys.Operating_System_Name_and0 
					when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
					when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
					when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
					end,
					case sys.Build01
				when '10.0.10586' then '1511'
				when '10.0.14393' then '1607'
				when '10.0.15063' then '1703'
				when '10.0.16299' then '1709'
				when '10.0.17134' then '1803'
				end
order by [OS], [Release]