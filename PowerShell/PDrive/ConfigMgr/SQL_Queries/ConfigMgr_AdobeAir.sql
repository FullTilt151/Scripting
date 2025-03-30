select DisplayName0 [Product], version0 [Version], count(*) [Total]
from v_add_remove_programs
where ProdID0 = 'Adobe AIR'
group by DisplayName0, Version0
order by cast('/' + replace(Version0, '.', '/') + '/' as hierarchyid)

select Netbios_Name0 [Name], LastUserName0 [User] ,  ExplorerFileName0 [File], FileDescription0 [File Description], FileVersion0 [File Version], FolderPath0 [Folder], LastUsedTime0 [Last Used]
from v_GS_CCM_RECENTLY_USED_APPS RUA join
	 v_r_system sys on RUA.resourceid = sys.resourceid
where ExplorerFileName0 like '%Adobe AIR%' and FolderPath0 like '%common%'
order by LastUsedTime0 desc