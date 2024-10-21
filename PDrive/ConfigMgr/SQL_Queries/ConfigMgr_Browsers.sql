-- Count of default browsers
select case 
	  when web.BrowserProgId0 = 'IE.HTTP' then 'Internet Explorer 11'
	  when web.BrowserProgId0 in ('MSEdgeHTM','AppXq0fevzme2pys62n3e0fbqa7peapykr8v') then 'Microsoft Edge (Chromium)'
	  when web.BrowserProgId0 like 'ChromeHTML%' then 'Google Chrome'
	  when web.BrowserProgId0 like 'ChromiumHTML%' then 'Google Chrome'
	  when web.BrowserProgId0 = 'DefaultNotSet' then 'Default not set'
	  when web.BrowserProgId0 in ('MSEdgeDHTML','MSEdgeBHTML') then 'Microsoft Edge (HTML)'
	  when web.BrowserProgId0 = 'OperaStable' then 'Opera'
	  when web.BrowserProgId0 like 'FirefoxURL%' then 'Mozilla Firefox'
	  when web.BrowserProgId0 = 'OperaStable' then 'Opera'
	  else 'Other'
	  end [Default Browser], count(*) [Count]
from v_R_System_Valid sys inner join
	 v_GS_DEFAULT_BROWSER web on sys.ResourceID = web.ResourceID
where Resource_Domain_OR_Workgr0 = 'HUMAD'
group by case 
	  when web.BrowserProgId0 = 'IE.HTTP' then 'Internet Explorer 11'
	  when web.BrowserProgId0 in ('MSEdgeHTM','AppXq0fevzme2pys62n3e0fbqa7peapykr8v') then 'Microsoft Edge (Chromium)'
	  when web.BrowserProgId0 like 'ChromeHTML%' then 'Google Chrome'
	  when web.BrowserProgId0 like 'ChromiumHTML%' then 'Google Chrome'
	  when web.BrowserProgId0 = 'DefaultNotSet' then 'Default not set'
	  when web.BrowserProgId0 in ('MSEdgeDHTML','MSEdgeBHTML') then 'Microsoft Edge (HTML)'
	  when web.BrowserProgId0 = 'OperaStable' then 'Opera'
	  when web.BrowserProgId0 like 'FirefoxURL%' then 'Mozilla Firefox'
	  when web.BrowserProgId0 = 'OperaStable' then 'Opera'
	  else 'Other'
	  end
order by count(*) desc

-- List of user default browsers
select sys.Netbios_Name0, HTTP0, HTTPS0, User0
from v_r_system_valid sys inner join
	 v_GS_USER_DEFAULT_BROWSER brs on sys.ResourceID = brs.ResourceID
where brs.User0 like 'HUMAD\%'
order by Netbios_Name0, User0

-- Count of user default browsers
select case 
		when HTTP0 in ('AppXq0fevzme2pys62n3e0fbqa7peapykr8v','MSEdgeDHTML','MSEdgeHTM','MSEdgeBHTML') then 'Microsoft Edge'
		when HTTP0 like 'ChromeHTML%' then 'Google Chrome'
		when HTTP0 = 'IE.HTTP' then 'Microft Internet Explorer'
		else HTTP0
	   end [HTTP], 
	   case 
		when HTTPS0 in ('AppXq0fevzme2pys62n3e0fbqa7peapykr8v','AppX90nv6nhay5n6a98fnetv7tpk64pp35es','MSEdgeDHTML','MSEdgeHTM','MSEdgeBHTML') then 'Microsoft Edge'
		when HTTPS0 like 'ChromeHTML%' then 'Google Chrome'
		when HTTPS0 = 'IE.HTTPS' then 'Microft Internet Explorer'
		else HTTPS0
	   end [HTTPS], count(*)
from v_r_system_valid sys left join
	 v_GS_USER_DEFAULT_BROWSER brs on sys.ResourceID = brs.ResourceID
where brs.User0 like 'HUMAD\%'
group by case 
		when HTTP0 in ('AppXq0fevzme2pys62n3e0fbqa7peapykr8v','MSEdgeDHTML','MSEdgeHTM','MSEdgeBHTML') then 'Microsoft Edge'
		when HTTP0 like 'ChromeHTML%' then 'Google Chrome'
		when HTTP0 = 'IE.HTTP' then 'Microft Internet Explorer'
		else HTTP0
	   end, case 
		when HTTPS0 in ('AppXq0fevzme2pys62n3e0fbqa7peapykr8v','AppX90nv6nhay5n6a98fnetv7tpk64pp35es','MSEdgeDHTML','MSEdgeHTM','MSEdgeBHTML') then 'Microsoft Edge'
		when HTTPS0 like 'ChromeHTML%' then 'Google Chrome'
		when HTTPS0 = 'IE.HTTPS' then 'Microft Internet Explorer'
		else HTTPS0
	   end
having count(*) > 1
order by HTTP, HTTPS

-- List of default browsers
select sys.Netbios_Name0, BrowserProgId0
from v_R_System sys left join
	 v_gs_default_browser bwsr on sys.ResourceID = bwsr.ResourceID
where sys.Resource_Domain_OR_Workgr0 = 'HUMAD' and
	  --Netbios_Name0 in ('wkmj064ach','simxdwtssa1074', 'wkpc0kum0n', 'cispxewqw01') or 
	  BrowserProgId0 like 'AppXq0fevzme2pys62n3e0fbqa7peapykr8v'

-- List of Edge Canary, Dev, Beta
select sys.Netbios_Name0, cdr.PrimaryUser, cdr.LastLogonUser, ProductName0, ProductVersion0
from v_R_System sys left join
	 v_CombinedDeviceResources cdr on sys.ResourceID = cdr.MachineID left join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 in ('Microsoft Edge Dev','Microsoft Edge Beta','Microsoft Edge Canary')
order by ProductName0, ProductVersion0, Netbios_Name0

-- List of browser usage summary
select sys.Netbios_Name0, bu.TimeStamp, bu.BrowserName0, bu.UsagePercentage0
from v_r_system_valid sys left join
	 v_GS_BROWSER_USAGE bu on sys.ResourceID = bu.ResourceID
where BrowserName0 = 'chrome' and UsagePercentage0 = 0
	 and Resource_Domain_OR_Workgr0 in ('HUMAD','LOUTMS')
order by Netbios_Name0

-- List of Browser usage and default
select sys.Netbios_Name0, rua.ExplorerFileName0, rua.FolderPath0, rua.ProductVersion0, rua.LastUsedTime0, rua.LastUserName0, db.BrowserProgId0
from v_r_system sys left join
	 v_GS_CCM_RECENTLY_USED_APPS rua on sys.ResourceID = rua.ResourceID left join
	 v_GS_DEFAULT_BROWSER db on sys.ResourceID = db.ResourceID
where Netbios_Name0 in ('SIMXDWSTDB8606','LOUXDWSTDB4107') 
	  and rua.ExplorerFileName0 in ('chrome.exe','iexplore.exe','msedge.exe')
order by Netbios_Name0, LastUsedTime0 desc

-- Browser usage - Chrome used recently
select distinct count(sys.ResourceID)
from v_R_System_Valid sys left join
	 v_gs_ccm_recently_used_apps rua on sys.ResourceID = rua.ResourceID
where explorerfilename0 = 'chrome.exe' and LastUsedTime0 > DATEADD(dd,-30, GETDATE()) and sys.ResourceID in (
select ResourceID from v_GS_INSTALLED_SOFTWARE where ProductName0 = 'Google Chrome')

-- Browser usage - Chrome not used
select sys.Netbios_Name0
from v_R_System_Valid sys left join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 = 'Google Chrome' and sys.Resource_Domain_OR_Workgr0 = 'HUMAD' and 
	sys.ResourceID not in (
select distinct ResourceID from v_gs_ccm_recently_used_apps where explorerfilename0 = 'chrome.exe' and LastUsedTime0 is not null and LastUsedTime0 > DATEADD(dd,-90, GETDATE())) and 
	sys.ResourceID in (
select sys.ResourceID
from v_r_system_valid sys inner join
	 v_GS_OSD640 osd on sys.ResourceID = osd.ResourceID
where Resource_Domain_OR_Workgr0 in ('HUMAD','LOUTMS') and ImageInstalled0 is not null and ImageInstalled0 < DATEADD(dd,-30, GETDATE()))
order by Netbios_Name0

-- Browser usage - Edge
select distinct count(sys.ResourceID)
from v_R_System_Valid sys inner join
	 v_gs_ccm_recently_used_apps rua on sys.ResourceID = rua.ResourceID
where explorerfilename0 = 'msedge.exe' and LastUsedTime0 > DATEADD(dd,-30, GETDATE())

-- Count of Safari
select sys.Netbios_Name0, sys.User_Name0, sft.Publisher0, sft.ProductName0, sft.ProductVersion0
from v_r_system sys left join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 like '%safari%'

select sys.Netbios_Name0, sf.*
from v_r_system sys left join 
	 v_GS_SoftwareFile sf on sys.ResourceID = sf.ResourceID
where FileName = 'safarisetup.exe' or filename = 'safari.exe'