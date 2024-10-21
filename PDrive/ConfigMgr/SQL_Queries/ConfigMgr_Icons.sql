select Name0, FileName0, count(*)
from v_GS_SHORTCUT_FILE
group by Name0, FileName0
having count(*) > 5
order by Name0, FileName0