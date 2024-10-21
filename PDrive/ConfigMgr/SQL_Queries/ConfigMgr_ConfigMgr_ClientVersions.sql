-- List of clients not updated
select netbios_name0, operating_system_name_and0, Resource_Domain_OR_Workgr0, Client_Version0
from v_r_system_valid
where Client_Version0 < '5.00.8540.1004'
order by Client_Version0

-- Count of clients not updated
select case Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
	   when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
	   when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
	   else 'Unknown'
	   end [OS], 
	   Resource_Domain_OR_Workgr0 [Domain], Client_Version0 [Client Version], count(*)
from v_r_system_valid
where Client_Version0 < '5.00.8540.1004' and Operating_System_Name_and0 not like 'Mac OS X%' and Operating_System_Name_and0 not like '%server%'
group by case Operating_System_Name_and0
	   when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
	   when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
	   when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
	   else 'Unknown'
	   end, Resource_Domain_OR_Workgr0, Client_Version0
order by Resource_Domain_OR_Workgr0, Client_Version0, [OS]

-- Count of clients by version - dynamic
select (select distinct updatetag from cm_updatePackages up where up.ClientVersion = sys.Client_Version0) [Name], sys.Client_Version0 [Version], count(*) [Count]
from v_R_System_Valid sys
--where sys.Resource_Domain_OR_Workgr0 in (@Domains)
group by sys.Client_Version0
order by sys.Client_Version0 desc

-- Count of clients by version - manual
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
	   end 
order by Client_Version0