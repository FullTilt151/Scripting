-- List of Win10 VIPs
SELECT distinct SYS.Netbios_Name0 WKID, sys.AD_Site_Name0, sys.build01 [Build], usr1.User_Name0 [Last User 1], usr1.Full_User_Name0 [Full User 1], replace(cs.UserName0, 'HUMAD\','') [Last User 2], 
				usr2.Full_User_Name0 [Full User 2], usr2.title0 [Title], usr2.department0 [Dept], usr2.telephonenumber0 [Phone],
                dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Version0 [Model], usr3.Full_User_Name0 [InstalledByName],
				OS.InstallDate0, CLI.LastActiveTime [Last Active]
FROM            dbo.v_R_System SYS INNER JOIN
                dbo.v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID INNER JOIN
                dbo.v_GS_COMPUTER_SYSTEM CS ON SYS.ResourceID = cs.ResourceID full join
                dbo.v_GS_COMPUTER_SYSTEM_PRODUCT ON SYS.ResourceID = dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.ResourceID full JOIN
                dbo.v_R_User usr1 ON SYS.User_Name0 = usr1.User_Name0 full JOIN
				dbo.v_R_User usr2 ON replace(cs.UserName0,'HUMAD\','') = usr2.User_Name0 full join
				dbo.v_CH_ClientSummary CLI ON SYS.ResourceID = CLI.ResourceID left join
				dbo.v_GS_OSD640 osd on sys.ResourceID = osd.ResourceID full join
				dbo.v_R_User usr3 on osd.DeployedBy0 = usr3.User_Name0
where   sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and 
		(--usr2.title0 like 'Associate VP%' or
		usr2.title0 like 'Chief%' or
		usr2.title0 like 'VP%' or
		usr2.title0 like 'SVP%' or
		usr2.title0 like 'Market VP%' or
		usr2.title0 like 'Regional Vice President%' or
		usr2.title0 like 'Regional VP%')
group by SYS.Netbios_Name0, sys.AD_Site_Name0, sys.build01, usr1.User_Name0, usr1.Full_User_Name0, cs.UserName0, usr2.Full_User_Name0, usr2.title0, usr2.department0,usr2.telephonenumber0,
                        cs.Manufacturer0 , dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.Version0, usr3.Full_User_Name0,
						OS.InstallDate0, CLI.LastActiveTime
order by wkid

-- List of titles
SELECT distinct  usr2.title0 [Title]
FROM            dbo.v_R_System SYS INNER JOIN
                dbo.v_GS_OPERATING_SYSTEM OS ON SYS.ResourceID = OS.ResourceID INNER JOIN
                dbo.v_GS_COMPUTER_SYSTEM CS ON SYS.ResourceID = cs.ResourceID full join
                dbo.v_GS_COMPUTER_SYSTEM_PRODUCT ON SYS.ResourceID = dbo.v_GS_COMPUTER_SYSTEM_PRODUCT.ResourceID full JOIN
                dbo.v_R_User usr1 ON SYS.User_Name0 = usr1.User_Name0 full JOIN
				dbo.v_R_User usr2 ON replace(cs.UserName0,'HUMAD\','') = usr2.User_Name0 full join
				dbo.v_CH_ClientSummary CLI ON SYS.ResourceID = CLI.ResourceID left join
				dbo.v_GS_OSD640 osd on sys.ResourceID = osd.ResourceID full join
				dbo.v_R_User usr3 on osd.DeployedBy0 = usr3.User_Name0
where sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP'
group by usr2.title0
order by usr2.title0