-- OneDrive version counts
select FileVersion, count(resourceid)
from v_gs_softwarefile
where filename in ('onedrive.exe')
group by FileVersion

-- OneDrive setup version counts
select FileVersion, count(resourceid)
from v_gs_softwarefile
where filename in ('onedrivesetup.exe') and FilePath = 'C:\Windows\SysWOW64\'
group by FileVersion

-- OneDrive setup and file versions for a list of WKIDs
select sys.Name, sft.FileName, sft.FileVersion, sft.FilePath
from vSMS_CombinedDeviceResources sys left join
	 v_GS_SoftwareFile sft on sys.MachineID = sft.ResourceID
where sft.FileName in ('onedrivesetup.exe','onedrive.exe') and
	  sys.Name in ('WKPC0MTJ6D','SIMXDWTSSA1229', 'SIMXDWTSSA1074', 'WKPC0MTJ67')
order by sys.name, sft.FileName, sft.FilePath

-- OneDrive usage for a list of users
select usr.User_Name0, usr.full_user_name0, usr.title0, usr.department0, (select top 1 LastUsedTime0 from v_GS_CCM_RECENTLY_USED_APPS rua 
where ExplorerFileName0 = 'onedrive.exe' and LastUserName0 = usr.unique_user_name0
order by LastUsedTime0 desc)
from v_R_User usr
where Windows_NT_Domain0 = 'HUMAD' and usr.User_Name0 in
('CCM5521','GXK9084','AXB9171','NXB5866','PXH7029','JXL6341','MXC4183','DXR5354','JEC6932','DXH8296',
'JXV6168','DXC1818','jsb2493','CAW6893','RBG7399','SAG3456','BRD2880','VXK9684','DXM7040','AXC9862',
'CXK1600','JXS2999','TCG9442','KGE2947','WXN7804','DXH8296','MXF6852','JXV6168','DSB9324','KAW1986',
'JGM0348','PGD7821','tcg2523','TXP7681','HEH3784','RXP5853','KMH7275','JAY8452','JXT4105','GXS5831',
'BKW5388','MXA1393','TPB4047','WES2848','DSM9619','MYY5296','JXS8649','SXF2570','CXP7240','EXA9226',
'KXW4596','JXH7194','MXB0699','AWH5240','JCS3243','DRC2830','JGM0348','TSO2673','MGC7999')
order by title0, Full_User_Name0

-- OneDrive usage for a single user
select LastUsedTime0 from v_GS_CCM_RECENTLY_USED_APPS rua 
where ExplorerFileName0 = 'onedrive.exe' and LastUserName0 = 'HUMAD\JAY8452'
order by LastUsedTime0 desc

-- OneDrive PCFB sizes
SELECT Netbios_Name0 [WKID], UserName [User], 
		case ci.ConfigurationItemName
		when 'Script - Windows - Inventory Desktop size' then 'Desktop'
		when 'Script - Windows - Inventory Documents size' then 'Documents'
		when 'Script - Windows - Inventory Pictures size' then 'Pictures'
		end [Folder], ci.CurrentValue [Size (MB)], LastComplianceMessageTime [Timestamp]
FROM v_CIComplianceStatusDetail ci
where ConfigurationItemName in ('Script - Windows - Inventory Desktop size','Script - Windows - Inventory Documents size','Script - Windows - Inventory Pictures size')
	  and (Netbios_Name0 = 'WKPC0UQ1ZJ' or UserName = 'JAL7829')
order by WKID