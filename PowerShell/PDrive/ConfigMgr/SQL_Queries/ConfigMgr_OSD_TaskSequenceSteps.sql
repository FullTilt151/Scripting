--Count of AppMapping failures
SELECT DISTINCT tse.ExitCode, tse.ActionOutput, COUNT(*) AS Totals
FROM            dbo.v_TaskExecutionStatus AS tse INNER JOIN
                         dbo.v_R_System AS sys ON tse.ResourceID = sys.ResourceID
WHERE     tse.ExitCode not in (0) and ActionName = 'Install Mapped Packages' and ActionOutput like 'PACKAGEID = %'
GROUP BY  tse.exitcode, tse.ActionOutput
ORDER BY Totals DESC

-- List of AppMapping installs
SELECT DISTINCT Netbios_Name0, ExecutionTime, ExitCode, tse.ActionOutput
FROM            dbo.v_TaskExecutionStatus AS tse INNER JOIN
                         dbo.v_R_System AS sys ON tse.ResourceID = sys.ResourceID
WHERE     ActionName = 'Install Mapped Packages' and ActionOutput like 'PACKAGEID = %' 
and (ActionOutput like '%HUM00115%'
or ActionOutput like '%CAS00E25%'
or ActionOutput like '%CAS00E26%'
or ActionOutput like '%CAS004B6%'
or ActionOutput like '%WQ10000F%'
or ActionOutput like '%WQ1001DF%'
or ActionOutput like '%HUM004EC%')
order by ExecutionTime desc

--List of RDP user errors
SELECT DISTINCT Netbios_Name0, ExecutionTime, ExitCode, tse.ActionOutput
FROM            dbo.v_TaskExecutionStatus AS tse INNER JOIN
                         dbo.v_R_System AS sys ON tse.ResourceID = sys.ResourceID
WHERE     ActionName = 'Restore RDP access'
order by ExecutionTime desc

--Task Sequence columns
select top 5 AdvertisementID, ResourceID, ExecutionTime, Step, ActionName, GroupName, LastStatusMessageID, LastStatusMessageIDName, ExitCode, ActionOutput
from v_taskexecutionstatus

-- Verify Domain Join builds
select Netbios_Name0 [WKID], Version0 [Model], TSP.Name [Task Sequence], ExecutionTime, ActionName, LastStatusMessageID [ID], LastStatusMessageIDName [ID Name], ExitCode
from v_taskexecutionstatus join
     v_r_system SYS ON v_TaskExecutionStatus.ResourceID = sys.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID join
	 v_AdvertisementInfo ADV ON v_TaskExecutionStatus.AdvertisementID = adv.AdvertisementID join
	 v_TaskSequencePackage TSP ON adv.PackageID = tsp.PackageID
where ActionName = 'Verify Domain Join' and LastStatusMessageID = '11134'
order by ExecutionTime DESC

-- All OSD tasks filtered
select Netbios_Name0 [WKID], Version0 [Model], sys.Build01 [Build], osd.SMSTSRole0, TSP.Name [Task Sequence], dateadd(hh,-4, ExecutionTime) [Time], GroupName, ActionName, LastStatusMessageID [ID], 
		LastStatusMessageIDName [ID Name], ExitCode, CONVERT(VARBINARY(8), ExitCode) [ExitCodeHex], ActionOutput
from v_taskexecutionstatus TS full join
     v_r_system SYS ON TS.ResourceID = sys.ResourceID full join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID full join
	 v_AdvertisementInfo ADV ON TS.AdvertisementID = adv.AdvertisementID full join
	 v_TaskSequencePackage TSP ON adv.PackageID = tsp.PackageID full join
	 v_GS_OSD640 OSD on sys.ResourceID = osd.ResourceID
where --tsp.name in ('Windows 10 - Standard Build','Windows 7 - BITS') and
	  tsp.name = 'Windows 10 - In-Place Upgrade 1909' and
	  --LastStatusMessageIDName = 'The task sequence execution engine failed execution of a task sequence'
	  --LastStatusMessageIDName != 'The task sequence execution engine ignored execution failure of an action'
	  --ExitCode not in (0,3010,1460,4, 200, 2) and
	  --ActionName not in ('Copy Sample Pictures','Install Software Updates','Run OSD Results') and
	  --ActionName not in ('The task sequence execution engine failed execution of a task sequence','Apply Driver Package','Install KB4462918','Dynamic Driver Installation','Run Setup Diag',
	  --'Show - FailedStepName MessageBox','Copy SetupDiag to Temp','Show - PreCheck Agent MessageBox','Fail - Task Sequence') --and
	  --ActionName in ('Uninstall .NET 3.5','Citrix Virtual Delivery Agent 7.15 CU1') and
	  --ActionName = 'Upgrade Operating System' and
	  --Version0 = 'ThinkPad Yoga 260' and
	  --sys.Netbios_Name0 = 'WKPC0W9MHS'
	  --LastStatusMessageID in ('11134')
	  --'Validate USMT-Estimate size < 20GB') and
	  --ExitCode != 0 and
	  --dateadd(hh,-4, ExecutionTime) > DATEADD(hh, -24, getdate())
	  sys.ResourceID in (select resourceid from v_cm_res_coll_WP107118)
order by ExecutionTime DESC

-- All IPUs during the day
select Netbios_Name0 [WKID], TSP.Name [Task Sequence], dateadd(hh,-4, ExecutionTime) [Time], ActionName
from v_taskexecutionstatus TS full join
     v_r_system SYS ON TS.ResourceID = sys.ResourceID full join
	 v_AdvertisementInfo ADV ON TS.AdvertisementID = adv.AdvertisementID full join
	 v_TaskSequencePackage TSP ON adv.PackageID = tsp.PackageID
where tsp.name in (@TSList) and
	  ActionName = 'Upgrade Operating System' and
	  LastStatusMessageID in ('11134') and 
	  datepart(hh,dateadd(hh,-4, ExecutionTime)) in (8,9,10,11,12,13,14,15,16,17)
order by ExecutionTime DESC

-- All steps for a WKID
select Netbios_Name0 [WKID], Version0 [Model], TSP.Name [Task Sequence], ExecutionTime, GroupName, ActionName, LastStatusMessageID [ID], LastStatusMessageIDName [ID Name], ExitCode
from v_taskexecutionstatus join
     v_r_system SYS ON v_TaskExecutionStatus.ResourceID = sys.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP ON sys.ResourceID = csp.ResourceID join
	 v_AdvertisementInfo ADV ON v_TaskExecutionStatus.AdvertisementID = adv.AdvertisementID join
	 v_TaskSequencePackage TSP ON adv.PackageID = tsp.PackageID
where Netbios_Name0 = 'WKMJ04LZ3X'
order by ExecutionTime DESC

-- All TS Steps
select top 100 *
from v_TaskExecutionStatus

--Advert info
select *
from v_AdvertisementInfo

--Package list
select PackageID, Manufacturer, Name, Version
from v_package

-- All TS status messages
select distinct tes.LastStatusMessageID, tes.LastStatusMessageIDName, cas.LastStatusMessageID, cas.LastStatusMessageIDName
from v_taskexecutionstatus TES full join
	 v_ClientAdvertisementStatus CAS on TES.LastStatusMessageID = CAS.LastStatusMessageID
order by LastStatusMessageID, LastStatusMessageIDName