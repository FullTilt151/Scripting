--Get all versions of PDF Create and WKIDs from recently used apps.
select Netbios_Name0, CompanyName0, ExplorerFileName0, FileDescription0,FORMAT(LastUsedTime0, 'M/d/yyyy')[Last Used Date],ProductVersion0, FileVersion0, DATEDIFF(d,LastusedTime0,GETDATE())[Days Used],
CASE 
WHEN DATEDIFF(d,LastusedTime0,GETDATE()) <30 THEN 'Used'
WHEN DATEDIFF(d,LastusedTime0,GETDATE()) >29 and DATEDIFF(d,LastusedTime0,GETDATE()) <90 THEN 'Rarely Used'
WHEN DATEDIFF(d,LastusedTime0,GETDATE()) >89 THEN 'Unused'
ELSE 'Unknown'
END [Usage]
from v_GS_CCM_RECENTLY_USED_APPS Rec
Join v_R_System_Valid sys on rec.ResourceID = sys.ResourceID
where ExplorerFileName0 = 'winproj.exe' and FileDescription0 like 'microsoft project%' and ProductVersion0 like '15.0%'
order by [Days Used] DESC

--Get all installs from Asset Intelligence.
select distinct ProductName0, ProductVersion0, Netbios_Name0, Resource_Domain_OR_Workgr0 --count(*)[Install Numbers]
from v_r_system_valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 = 'Microsoft Project Standard 2013' --and ProductVersion0 = '15.0.4420.1017'
--group by ProductName0, ProductVersion0
order by ProductName0, ProductVersion0

select * --Netbios_Name0, ARPDisplayName0, ProductName0, ProductVersion0, InstallDate0, Publisher0
from v_R_System_Valid sys
join v_GS_INSTALLED_SOFTWARE arp on arp.ResourceID = sys.ResourceID
where  ProductName0 = 'Microsoft Project Standard 2013'
order by ProductName0

select *
from v_add_remove_programs
where Publisher0 = 'Nuance Communications, Inc' and DisplayName0 = 'Nuance PDF Create 7'

select *
from v_GS_CCM_RECENTLY_USED_APPS
where CompanyName0 = 'Nuance Communications, Inc.' and msiVersion0 = '7.00.2164'
order by FileDescription0

select *
from v_GS_INSTALLED_SOFTWARE
where ARPDisplayName0 = 'Nuance PDF Create 8'