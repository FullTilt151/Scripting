-- Physical machines - List
select netbios_name0 [WKID], LastHWScan, Creation_Date0 [Created], Resource_Domain_OR_Workgr0 [Domain], ad_site_name0 [AD Site], Client_Version0 [Client Version]
from v_r_system SYS left join
     v_gs_workstation_status WS on sys.resourceid = ws.resourceid
where Operating_System_Name_and0 like '%workstation%' and
	  LastHWScan IS NULL and
	  client0 = '1' and
	  Is_Virtual_Machine0 = '0'
order by sys.Creation_Date0 DESC

-- Physical machines - Trend
select Resource_Domain_OR_Workgr0 [Domain], MONTH(Creation_Date0),
	   case MONTH(Creation_Date0)
	   when '1' then 'January'
	   when '2' then 'February'
	   when '3' then 'March'
	   when '4' then 'April'
	   when '5' then 'May'
	   when '6' then 'June'
	   when '7' then 'July'
	   when '8' then 'August'
	   when '9' then 'September'
	   when '10' then 'October'
	   when '11' then 'November'
	   when '12' then 'December'
	   end as [Month],
	   YEAR(Creation_Date0) as [Year] , count(*) [Total]
from v_r_system SYS left join
     v_gs_workstation_status WS on sys.resourceid = ws.resourceid
where Operating_System_Name_and0 like '%workstation%' and
	  LastHWScan IS NULL and
	  client0 = '1' and
	  Is_Virtual_Machine0 = '0' --and
	  --Resource_Domain_OR_Workgr0 = @Domain
group by Resource_Domain_OR_Workgr0, MONTH(Creation_Date0), YEAR(Creation_Date0)
order by Domain, Year DESC, MONTH(Creation_Date0) DESC

-- VMs - List
select netbios_name0 [WKID], LastHWScan, Creation_Date0 [Created], Resource_Domain_OR_Workgr0 [Domain], ad_site_name0 [AD Site], Client_Version0 [Client Version]
from v_r_system SYS left join
     v_gs_workstation_status WS on sys.resourceid = ws.resourceid
where Operating_System_Name_and0 like '%workstation%' and
	  LastHWScan IS NULL and
	  client0 = '1' and
	  Is_Virtual_Machine0 = '1'
order by sys.Creation_Date0 DESC

-- VMs - Trend
select Resource_Domain_OR_Workgr0 [Domain], MONTH(Creation_Date0),
	   case MONTH(Creation_Date0)
	   when '1' then 'January'
	   when '2' then 'February'
	   when '3' then 'March'
	   when '4' then 'April'
	   when '5' then 'May'
	   when '6' then 'June'
	   when '7' then 'July'
	   when '8' then 'August'
	   when '9' then 'September'
	   when '10' then 'October'
	   when '11' then 'November'
	   when '12' then 'December'
	   end as [Month],
	   YEAR(Creation_Date0) as [Year] , count(*) [Total]
from v_r_system SYS left join
     v_gs_workstation_status WS on sys.resourceid = ws.resourceid
where Operating_System_Name_and0 like '%workstation%' and
	  LastHWScan IS NULL and
	  client0 = '1' and
	  Is_Virtual_Machine0 = '1' --and
	  --Resource_Domain_OR_Workgr0 = @Domain
group by Resource_Domain_OR_Workgr0, MONTH(Creation_Date0), YEAR(Creation_Date0)
order by Domain, Year DESC, MONTH(Creation_Date0) DESC

-- Domains
select Resource_Domain_OR_Workgr0 [Domain], Count(*)
from v_R_System
where Operating_System_Name_and0 like '%workstation%'
group by Resource_Domain_OR_Workgr0
having count(*) > 3
order by Resource_Domain_OR_Workgr0