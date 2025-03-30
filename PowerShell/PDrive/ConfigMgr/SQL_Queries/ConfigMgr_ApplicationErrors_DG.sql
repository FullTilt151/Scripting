-- List of DG machines
select sys.Netbios_Name0, modulepath0, Module0,ProcessPath0,  Process0, TimeCreated0, dg.Agentversion0
from v_r_system_valid sys join
	 v_GS_APPLICATION_ERRORS ERR on sys.ResourceID = err.ResourceID left join
	 v_GS_VDG640 dg on sys.ResourceID = dg.ResourceID
where cast(TimeCreated0 as datetime) > DATEADD(dd,-7, getdate())
order by cast(TimeCreated0 as datetime) desc

-- Count of DG errors by version
select modulepath0, Module0,ProcessPath0,  Process0, dg.Agentversion0, count(*)
from v_r_system_valid sys join
	 v_GS_APPLICATION_ERRORS ERR on sys.ResourceID = err.ResourceID left join
	 v_GS_VDG640 dg on sys.ResourceID = dg.ResourceID
where ModulePath0 like 'C:\Program Files\DGAgent%' and ProcessPath0 not in (
'C:\Program Files\DGAgent',
'C:\Program Files\DGAgent\DgUpdate'
)
group by modulepath0, Module0,ProcessPath0,  Process0, dg.Agentversion0
order by Process0, ProcessPath0

-- Count of DG errors User Experience by time
select modulepath0, Module0,ProcessPath0,  Process0,  year(timecreated0) [Year], month(timecreated0) [Month], count(*)
from v_r_system_valid sys join
	 v_GS_APPLICATION_ERRORS ERR on sys.ResourceID = err.ResourceID
where ModulePath0 like 'C:\Program Files\DGAgent%' and Process0 in (
'DllHost.exe',
'EXCEL.EXE',
'Explorer.EXE',
'IEXPLORE.EXE',
'lync.exe',
'ONENOTE.EXE',
'ONENOTEM.EXE',
'OUTLOOK.EXE',
'POWERPNT.EXE',
'TpFnF5.exe',
'TPHKSVC.exe',
'TpKnrres.exe',
'TPONSCR.EXE',
'WINWORD.EXE')
group by modulepath0, Module0,ProcessPath0,  Process0, year(timecreated0), month(timecreated0)
order by year(timecreated0) desc, month(timecreated0) desc