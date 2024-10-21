-- Count of all store apps
select uwp.ApplicationName0, count(distinct Netbios_Name0)
from v_r_system sys inner join
	 v_GS_WINDOWS8_APPLICATION uwp on sys.ResourceID = uwp.ResourceID
where Resource_Domain_OR_Workgr0 = 'HUMAD'
group by uwp.ApplicationName0
order by uwp.ApplicationName0

-- List of store apps installs
select sys.Netbios_Name0, sys.Build01, sys.User_Name0, sys.resource_domain_or_workgr0, uwp.*
from v_R_System sys inner join
	 v_GS_WINDOWS8_APPLICATION uwp on sys.ResourceID = uwp.ResourceID
where --uwp.ApplicationName0 = 'Microsoft.Whiteboard' and 
	  Resource_Domain_OR_Workgr0 = 'HUMAD' and sys.Netbios_Name0 = 'WKPC13L2C7'
order by Netbios_Name0
--where uwp.ApplicationName0 in ('Microsoft.HEVCVideoExtension')

-- List of store apps installs user
select sys.Netbios_Name0, app.FullName0, app.InstallState0, app.UserAccountName0
from v_R_System sys inner join
	 v_GS_WINDOWS8_APPLICATION_USER_INFO app on sys.ResourceID = app.ResourceID
where FullName0 like 'Microsoft.Whiteboard%' and sys.Netbios_Name0 = 'WKPC13L2C7'
order by FullName0

-- Count of store apps installs user
select app.InstallState0, count(*)
from v_R_System sys inner join
	 v_GS_WINDOWS8_APPLICATION_USER_INFO app on sys.ResourceID = app.ResourceID
where FullName0 like 'Microsoft.Whiteboard%'
group by app.InstallState0

-- Count of store app versions
select uwp.ApplicationName0, Version0, count(distinct Netbios_Name0)
from v_R_System sys inner join
	 v_GS_WINDOWS8_APPLICATION uwp on sys.ResourceID = uwp.ResourceID
where uwp.ApplicationName0 in ('Microsoft.Whiteboard')
group by uwp.ApplicationName0, Version0
order by Version0 desc

-- Software usage
select *
from v_GS_CCM_RECENTLY_USED_APPS
where ExplorerFileName0 = 'whiteboard.exe'