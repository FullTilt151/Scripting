--Get all versions of PDF Create and WKIDs from recently used apps.
select Netbios_Name0, FileDescription0,FORMAT(LastUsedTime0, 'M/d/yyyy')[Last Used Date],ProductVersion0, fileversion0,  DATEDIFF(d,LastusedTime0,GETDATE())[Days Used],
CASE 
WHEN DATEDIFF(d,LastusedTime0,GETDATE()) <30 THEN 'Used'
WHEN DATEDIFF(d,LastusedTime0,GETDATE()) >29 and DATEDIFF(d,LastusedTime0,GETDATE()) <90 THEN 'Rarely Used'
WHEN DATEDIFF(d,LastusedTime0,GETDATE()) >89 THEN 'Unused'
ELSE 'Unknown'
END [Usage]
from v_GS_CCM_RECENTLY_USED_APPS Rec
Join v_R_System_Valid sys on rec.ResourceID = sys.ResourceID
where FileDescription0 = 'SecureFX FTP client' and DATEDIFF(d,LastusedTime0,GETDATE()) <90
order by Usage


--Get all installs from Asset Intelligence.
select distinct * --Netbios_Name0, User_Name0, Publisher0, ARPDisplayName0,  ProductName0, ProductVersion0, InstalledLocation0 
from v_r_system_valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where Netbios_Name0 = 'WKPC13L2E7' and ARPDisplayName0 = '1E Nomadbranch x64'
order by ProductVersion0


select distinct Netbios_Name0, User_Name0, Publisher0, ARPDisplayName0,  ProductName0, ProductVersion0, InstalledLocation0 
from v_r_system_valid sys join
v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ARPDisplayName0 like 'VanDyke Software SecureFX%'
order by ProductVersion0
