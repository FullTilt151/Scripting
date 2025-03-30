-- List of VMWare Workstation users
select distinct sys.Name [WKID], sys.UserName, sys.currentlogonuser, sys.PrimaryUser, usr.Full_User_Name0, usr.title0, usr.department0,
				case sys.DeviceOS
				when 'Microsoft Windows NT Server 6.3' then 'Server 2012 R2'
				when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
				when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
				when 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
				when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
				when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
				end [OS],
				 sft.ProductName0 [Product], sft.ProductVersion0 [Version], 
	            (select MAX(lastusedtime0)
				from v_GS_CCM_RECENTLY_USED_APPS RUA
				where ExplorerFileName0 = 'vmware.exe' and sys.MachineID = rua.ResourceID) [Last Used]
from vSMS_CombinedDeviceResources sys inner join
	 v_GS_INSTALLED_SOFTWARE sft on sys.MachineID = sft.resourceid left join
	 v_R_User usr on sys.UserName = usr.User_Name0 and Full_Domain_Name0 = 'HUMAD.COM'
where ProductName0 = 'VMware Workstation'
order by department0, title0, sys.name

-- Uninstall info
select arpdisplayname0,/*ProductVersion0,*/ UninstallString0, count(*)
from v_gs_installed_software
where arpdisplayname0 = 'VMWare Workstation'
group by arpdisplayname0,/*ProductVersion0,*/ UninstallString0
order by  UninstallString0

-- Software Inventory
select ExplorerFileName0, FileDescription0, FileVersion0, FolderPath0, ProductName0, rua.LastUsedTime0, rua.LastUserName0
from v_GS_CCM_RECENTLY_USED_APPS rua
where  ExplorerFileName0 = 'vmware.exe'
order by LastUsedTime0 desc