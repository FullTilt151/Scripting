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
where ExplorerFileName0 like 'pdfcreate%hook.exe'
order by [Days Used] DESC

--Get all installs from Asset Intelligence.
select ProductName0, ProductVersion0, count(*)[Install Numbers]
from v_r_system_valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 like '%PDF Create%' 
--and Netbios_Name0 = 'WKPBDNEHB'
group by ProductName0, ProductVersion0
order by ProductName0, ProductVersion0

