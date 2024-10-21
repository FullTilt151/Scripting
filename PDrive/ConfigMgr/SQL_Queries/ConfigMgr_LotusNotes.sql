select DisplayName0, Version0, count(*) [Total]
from v_add_remove_programs
where displayname0 like '%notes%' and
	 (Publisher0 = 'IBM' or Publisher0 IS NULL)
group by displayname0, version0
order by DisplayName0, Version0

select netbios_name0, Operating_System_Name_and0, Resource_Domain_OR_Workgr0, CompanyName0, ExplorerFileName0, FileDescription0, FileSize0, FileVersion0, FolderPath0, LastUsedTime0, LastUserName0
from v_R_System SYS inner join
v_GS_CCM_RECENTLY_USED_APPS RUA ON SYS.ResourceID = RUA.ResourceID
where ExplorerFileName0 = 'Notes.exe'
order by LastUsedTime0 DESC