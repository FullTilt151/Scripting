select * 
from v_Add_Remove_Programs
where DisplayName0 like 'Socialcast Desktop'

select *
from v_GS_CCM_RECENTLY_USED_APPS
where ExplorerFileName0 = 'Socialcast Desktop.exe'
order by LastUsedTime0 desc