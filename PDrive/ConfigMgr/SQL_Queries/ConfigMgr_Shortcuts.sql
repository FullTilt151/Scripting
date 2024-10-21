select Description0, ParentName0, Product0, ShortcutKey0, ShortcutName0, TargetExecutable0
from v_GS_SOFTWARE_SHORTCUT
where ParentName0 = 'Desktop'

select ShortcutName0, TargetExecutable0, count(*)
from v_GS_SOFTWARE_SHORTCUT
where ParentName0 = 'Desktop'
group by ShortcutName0, TargetExecutable0
order by count(*) desc

select *
from v_GS_SOFTWARE_SHORTCUT
where TargetExecutable0 like '%myapps%'