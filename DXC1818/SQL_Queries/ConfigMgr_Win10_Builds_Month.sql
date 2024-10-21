-- List of WKIDs last 30 days
SELECT DISTINCT SYS.Netbios_Name0 [WKID], sys.AD_Site_Name0 [Site], cs.Manufacturer0, dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Name0 As Model0,
                dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Version0 As Model1, usr3.Full_User_Name0 [InstalledByName], OSD.ImageInstalled0 [InstallDate]
FROM            dbo.v_R_System SYS INNER JOIN
                dbo.v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID INNER JOIN
                dbo.v_GS_COMPUTER_SYSTEM CS ON SYS.ResourceID = cs.ResourceID full join
                dbo.v_GS_COMPUTER_SYSTEM_PRODUCT ON SYS.ResourceID = dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.ResourceID full JOIN
				dbo.v_CH_ClientSummary CLI ON SYS.ResourceID = CLI.ResourceID left join
				dbo.v_GS_OSD640 osd on sys.ResourceID = osd.ResourceID full join
				dbo.v_R_User usr3 on osd.DeployedBy0 = usr3.User_Name0
where SYS.Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 6.2', 'Microsoft Windows NT Workstation 6.2 (Tablet Edition)', 
										 'Microsoft Windows NT Workstation 6.3', 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)',
										 'Microsoft Windows NT Workstation 10.0', 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
		and sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' 
		and OSD.ImageInstalled0 BETWEEN '10/1/2021' and '10/31/2021'
		group by SYS.Netbios_Name0, sys.AD_Site_Name0, sys.build01, cs.UserName0,
                        cs.Manufacturer0, dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Name0, dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Version0, usr3.Full_User_Name0,
						OSD.ImageInstalled0, CLI.LastActiveTime
order by OSD.ImageInstalled0 Asc