-- Count of crashes by month and year
select year(TimeCreated0) [Year], month(timecreated0) [Month], count(distinct Netbios_Name0) [Total]
from v_r_system_valid sys join
	 v_gs_system_errors err on sys.ResourceID = err.ResourceID
group by year(TimeCreated0), month(timecreated0)
order by year(TimeCreated0) desc, month(timecreated0) desc

--Count of crashes by day
select year(TimeCreated0) [Year], month(timecreated0) [Month], Day(timecreated0) [Day], count(distinct Netbios_Name0) [Total]
from v_r_system_valid sys join
	 v_gs_system_errors err on sys.ResourceID = err.ResourceID
--where sys.ResourceID in (select resourceid from v_R_System where Build01 = '10.0.18363')
group by year(TimeCreated0), month(timecreated0), Day(timecreated0)
order by year(TimeCreated0) desc, month(timecreated0) desc, Day(timecreated0) desc

-- Count of crashes by WKID
select Netbios_Name0, count(*)
from v_R_System_Valid sys join
	 v_GS_SYSTEM_ERRORS err on sys.ResourceID = err.ResourceID
where sys.ResourceID in (select resourceid from v_R_System where Build01 = '10.0.18363')
group by Netbios_Name0
order by count(*) desc

-- List of all crashes
select Netbios_Name0, err.Message0, TimeCreated0
from v_R_System_Valid sys inner join
	 v_GS_SYSTEM_ERRORS err on sys.ResourceID = err.ResourceID
--where sys.ResourceID in (select resourceid from v_R_System where Build01 = '10.0.18363')
order by CAST(timecreated0 as datetime) desc

-- List of crashes for specific WKIDs
select Netbios_Name0, err.Message0, TimeCreated0
from v_R_System_Valid sys join
	 v_GS_SYSTEM_ERRORS err on sys.ResourceID = err.ResourceID
where netbios_name0 in (
'WKR90NSTVP',
'WKPC0SWH0E'
)
order by netbios_name0, CAST(timecreated0 as datetime)

select *
from v_GS_SYSTEM_ERRORS