-- All build info
SELECT 'ConfigMgr ' + CONVERT(nvarchar(255), UpdateTag) AS 'Build Name',
  UpdateType =
              CASE
                WHEN UpdateType = 0 THEN 'RTM'
                WHEN UpdateType = 2 THEN 'HFRU'
              END,
  'DOC INFO' =
              CASE
                WHEN UpdateType = 0 THEN MoreInfoLink
                WHEN UpdateType = 2 THEN 'KB ' + SUBSTRING(MoreInfoLink, LEN(MoreInfoLink) - 6, 7)
              END,
  FullVersion AS 'Build Version',  CONVERT(date, DateReleased) AS 'Release Date',  ISNULL(ClientVersion, 'No Client Change') AS 'Client Version'
FROM CM_UpdatePackages
WHERE UpdateTag IS NOT NULL AND State != '393213'
ORDER BY DateReleased DESC

-- Client build info
select distinct UpdateTag, ClientVersion
FROM CM_UpdatePackages
where UpdateTag is not null and ClientVersion is not null
order by UpdateTag desc, ClientVersion desc

-- Client build info - auto
select (select distinct updatetag from cm_updatePackages up where up.ClientVersion = sys.Client_Version0) [Name], sys.Client_Version0 [Version], count(*) [Count]
from v_R_System_Valid sys
where sys.Resource_Domain_OR_Workgr0 in (select distinct Resource_Domain_OR_Workgr0 [Domain] from v_R_System_Valid) and sys.is_virtual_machine0 = 1
group by sys.Client_Version0
order by sys.Client_Version0 desc

select distinct Resource_Domain_OR_Workgr0 [Domain] 
from v_R_System_Valid 
order by Resource_Domain_OR_Workgr0

-- Client build info - manual
select Client_Version0 [Version], 
	   case Client_Version0
	   when '5.00.7804.0000' then '2012 SP1'
	   when '5.00.7804.1400' then '2012 SP1 CU3'
	   when '5.00.7958.1254' then '2012 R2 CU3'
	   when '5.00.7958.1501' then '2012 R2 CU4'
	   when '5.00.8325.0000' then '1511'
	   when '5.00.8355.1000' then '1602'
	   when '5.00.8355.1307' then '1602 w/KB'
	   when '5.00.8412.1000' then '1606'
	   when '5.00.8412.1007' then '1606 w/KB'
	   when '5.00.8412.1307' then '1606 w/KB'
	   when '5.00.8458.1000' then '1610'
	   when '5.00.8458.1007' then '1610 w/KB'
	   when '5.00.8498.1008' then '1702'
	   when '5.00.8498.1711' then '1702 w/KB'
	   when '5.00.8540.1000' then '1706'
	   when '5.00.8540.1003' then '1706 w/KB'
	   when '5.00.8540.1004' then '1706 w/KB'
	   when '5.00.8540.1007' then '1706 w/KB'
	   when '5.00.8540.1611' then '1706 w/KB'
	   when '5.00.8577.1003' then '1710'
	   when '5.00.8577.1005' then '1710 w/KB'
	   when '5.00.8577.1115' then '1710 w/KB'
	   when '5.00.8634.1007' then '1802'
	   when '5.00.8634.1813' then '1802 w/KB'
	   when '5.00.8634.1814' then '1802 w/KB'
	   when '5.00.8692.1003' then '1806'
	   when '5.00.8692.1008' then '1806 w/KB'
	   when '5.00.8692.1509' then '1806 w/KB'
	   when '5.00.8740.1012' then '1810'
	   when '5.00.8740.1031' then '1810 w/KB'
	   when '5.00.8790.1007' then '1902'
	   when '5.00.8790.1025' then '1902 w/KB'
	   when '5.00.8853.1006' then '1906'
	   when '5.00.8853.1020' then '1906 w/KB'
	   when '5.00.8913.1012' then '1910 w/KB'
	   end [Name], COUNT(*) [Count]
from v_R_System_Valid sys
--where sys.Resource_Domain_OR_Workgr0 = 'HMHSCHAMP'
group by Client_Version0,case Client_Version0
	   when '5.00.7804.0000' then '2012 SP1'
	   when '5.00.7804.1400' then '2012 SP1 CU3'
	   when '5.00.7958.1254' then '2012 R2 CU3'
	   when '5.00.7958.1501' then '2012 R2 CU4'
	   when '5.00.8325.0000' then '1511'
	   when '5.00.8355.1000' then '1602'
	   when '5.00.8355.1307' then '1602 w/KB'
	   when '5.00.8412.1000' then '1606'
	   when '5.00.8412.1007' then '1606 w/KB'
	   when '5.00.8412.1307' then '1606 w/KB'
	   when '5.00.8458.1000' then '1610'
	   when '5.00.8458.1007' then '1610 w/KB'
	   when '5.00.8498.1008' then '1702'
	   when '5.00.8498.1711' then '1702 w/KB'
	   when '5.00.8540.1000' then '1706'
	   when '5.00.8540.1003' then '1706 w/KB'
	   when '5.00.8540.1004' then '1706 w/KB'
	   when '5.00.8540.1007' then '1706 w/KB'
	   when '5.00.8540.1611' then '1706 w/KB'
	   when '5.00.8577.1003' then '1710'
	   when '5.00.8577.1005' then '1710 w/KB'
	   when '5.00.8577.1115' then '1710 w/KB'
	   when '5.00.8634.1007' then '1802'
	   when '5.00.8634.1813' then '1802 w/KB'
	   when '5.00.8634.1814' then '1802 w/KB'
	   when '5.00.8692.1003' then '1806'
	   when '5.00.8692.1008' then '1806 w/KB'
	   when '5.00.8692.1509' then '1806 w/KB'
	   when '5.00.8740.1012' then '1810'
	   when '5.00.8740.1031' then '1810 w/KB'
	   when '5.00.8790.1007' then '1902'
	   when '5.00.8790.1025' then '1902 w/KB'
	   when '5.00.8853.1006' then '1906'
	   when '5.00.8853.1020' then '1906 w/KB'
	   when '5.00.8913.1012' then '1910 w/KB'
	   end 
order by Client_Version0