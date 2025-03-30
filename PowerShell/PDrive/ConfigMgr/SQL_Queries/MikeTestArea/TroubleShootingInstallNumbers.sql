--Get all versions of PDF Create and WKIDs from recently used apps.
select Netbios_Name0, CompanyName0, ExplorerFileName0, FileDescription0,FORMAT(LastUsedTime0, 'M/d/yyyy')[Last Used Date],ProductVersion0, fileversion0,  DATEDIFF(d,LastusedTime0,GETDATE())[Days Used],
CASE 
WHEN DATEDIFF(d,LastusedTime0,GETDATE()) <30 THEN 'Used'
WHEN DATEDIFF(d,LastusedTime0,GETDATE()) >29 and DATEDIFF(d,LastusedTime0,GETDATE()) <90 THEN 'Rarely Used'
WHEN DATEDIFF(d,LastusedTime0,GETDATE()) >89 THEN 'Unused'
ELSE 'Unknown'
END [Usage]
from v_GS_CCM_RECENTLY_USED_APPS Rec
Join v_R_System_Valid sys on rec.ResourceID = sys.ResourceID
where CompanyName0 like '%Alteryx%'
order by Netbios_Name0

select *
from v_R_System_Valid Sys
join v_GS_NomadBranch_640 nb on sys.ResourceID = nb.ResourceID
where Netbios_Name0 = 'wkmj08nq1a'

--Get all installs from Asset Intelligence.
select distinct Netbios_Name0, User_Name0, Publisher0, ARPDisplayName0,  ProductName0, ProductVersion0, InstalledLocation0 
from v_r_system_valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 like '1E Client%'
order by Publisher0

select *
from v_GS_CCM_RECENTLY_USED_APPS
where ResourceID = 17050545 --and CompanyName0 like '%information%'
order by CompanyName0

Select *
from v_GS_NETWORK_ADAPTER_CONFIGUR

select *
from v_GS_ADD_REMOVE_PROGRAMS
where Publisher0 like 'Nuance%'
order by DisplayName0

select *
from v_add_remove_programs arp
join v_R_System_Valid sys on arp.ResourceID = sys.ResourceID
where Netbios_Name0 = 'WKPF0CKK9Q' --and Publisher0 = 'Nuance Communications, Inc' and DisplayName0 = 'Nuance PDF Create 7'
order by DisplayName0

select *
from v_GS_CCM_RECENTLY_USED_APPS
where CompanyName0 = 'Nuance Communications, Inc.' and msiVersion0 = '7.00.2164'
order by FileDescription0


select Netbios_Name0, BlockSize0, CacheCleanCycleHrs0, CompatibilityFlags0, DpNotAvailableCodes0, InstallationDirectory0, LocalCachePath0, MultiCastMADCAPScope0, NomadInhibitedADSites0, NomadInhibitedSubnets0, P2P_Port0, P2Penabled0, ProductVersion0, SpecialNetShare0, SSDEnabled0, SSPBAEnabled0
from v_R_System sys 
	join v_GS_NomadBranch_640 NB on sys.ResourceID = NB.ResourceID
where InstallationDirectory0 is not null and Netbios_Name0 = 

select *
from v_GS_NomadBranch_640
where LocalCachePath0 is not null
