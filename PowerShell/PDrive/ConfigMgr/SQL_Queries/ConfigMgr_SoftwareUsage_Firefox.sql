select *
from v_gs_ccm_recently_used_apps
where ExplorerFileName0 = 'Firefox.exe' or OriginalFileName0 = 'Firefox.exe'
order by LastUsedTime0 DESC