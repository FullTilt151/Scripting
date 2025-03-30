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
where ExplorerFileName0 = 'winproj.exe' and Netbios_Name0 in ('LOUXDWDEVC3130','LOUXDWTSSA1154','SIMXDWWTSA0019','TRMJCCYTZ','WKHGBLA0020563','WKHGBLA0020700','WKHGBLA0021565','WKHGBLA0031141','WKHGBLA0035504','WKMJ00ADJ4','WKMJ03CTYP','WKMJ04FEJY','WKMJ055E6','WKMJ05B5VF','WKMJ05SSLW','WKMJMCEZW','WKMP04WC12','WKMP05W4A5','WKMP07UBMD','WKMPMP185ZFR','WKPB6HYA7','WKPB8BGGG','WKPBBERM9','WKPBF1L70','WKPBP565A','WKPBY595Y','WKPC0DSE9J','WKPC0DW650','WKPC0DWRDG','WKPC0E2YZD','WKPC0E63PV','WKPC0F0Z9T','WKPC0FESC8','WKPC0G3Q08','WKPC0G4Z2F','WKPC0G4Z2M','WKPC0G7ZSK','WKPC0HPU2M','WKPC0J27KC','WKPC0J28BR','WKPC0J28TX','WKPC0J4RST','WKPC0J4SYY','WKPC0J4T1F','WKPC0J4T2J','WKPC0JZG9J','WKPC0KFT3R','WKPC0KULZ3','WKPC0KULZ9','WKPC0KULZR','WKPC0L2LD1','WKPC0LN9WN','WKPC0MK21Y','WKPC0MK24S','WKPC0MK24V','WKPC0MTDFM','WKPC0N86Y5','WKPC0N86YJ','WKPC0N86YV','WKPC0N870K','WKPC0NFN5L','WKPC0PCR5B','WKPC0Q7KFC','WKPC0Q7KGM','WKPF04TTB7','WKPF095L05','WKPF0DMNNQ','WKPF0DTBTA','WKPF0FAPQ8','WKPF0FX0TZ','WKPF0I37MV','WKR8K6ZZB','WKR9011BB9','WKR9016DVF','WKR901HX8B','WKR901HX8E','WKR901HXV9','WKR901NAH9','WKR9025K3Y','WKR9029RML','WKR902RT4M','WKR903092G','WKR9035M0Y','WKR90ACHRB','WKR90ACHRZ','WKR90B8B31','WKR90FB5P8','WKR90FBBZV','WKR90FBC0U','WKR90FBC7D','WKR90FBC85','WKR90FR6QB','WKR90FSG90','WKR90LDWHL','WKR90P6BSX','WKR90PQ2D4','WKTNEX110826','WKTNEX110830')
order by [Days Used] DESC

--Get all installs from Asset Intelligence.
select distinct Netbios_Name0, User_Name0, Publisher0, ARPDisplayName0,  ProductName0, ProductVersion0, InstalledLocation0,  VersionMajor0, VersionMinor0
from v_r_system_valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ARPDisplayName0 = 'After Effects CC 2015'
and Netbios_Name0 = 'WKMJ050X3W'
order by VersionMajor0

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