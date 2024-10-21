select Netbios_name0 [Name], 
	   case 
	   when netbios_name0 like '%FAX%' then 'Prod'
	   when netbios_name0 like '%WBS%' then 'Prod'
	   when netbios_name0 like '%WPB%' then 'Prod'
	   when netbios_name0 like '%WPC%' then 'Prod'
	   when netbios_name0 like '%WPG%' then 'Prod'
	   when netbios_name0 like '%WPL%' then 'Prod'
	   when netbios_name0 like '%WPM%' then 'Prod'
	   when netbios_name0 like '%WPS%' then 'Prod'
	   when netbios_name0 like '%WPU%' then 'Prod'
	   when netbios_name0 like '%WPX%' then 'Prod'
	   when netbios_name0 like '%WPV%' then 'Prod'
	   when netbios_name0 like '%WAG%' then 'QA'
	   when netbios_name0 like '%WAL%' then 'QA'
	   when netbios_name0 like '%WAS%' then 'QA'
	   when netbios_name0 like '%WIL%' then 'QA'
	   when netbios_name0 like '%WIS%' then 'QA'
	   when netbios_name0 like '%WIX%' then 'QA'
	   when netbios_name0 like '%WQC%' then 'QA'
	   when netbios_name0 like '%WQL%' then 'QA'
	   when netbios_name0 like '%WQS%' then 'QA'
	   when netbios_name0 like '%WQX%' then 'QA'
	   when netbios_name0 like '%WSC%' then 'QA'
	   when netbios_name0 like '%WSL%' then 'QA'
	   when netbios_name0 like '%WSS%' then 'QA'
	   when netbios_name0 like '%WDC%' then 'Test/Dev'
	   when netbios_name0 like '%WDG%' then 'Test/Dev'
	   when netbios_name0 like '%WDL%' then 'Test/Dev'
	   when netbios_name0 like '%WDS%' then 'Test/Dev'
	   when netbios_name0 like '%WDX%' then 'Test/Dev'
	   when netbios_name0 like '%WEC%' then 'Test/Dev'
	   when netbios_name0 like '%WEG%' then 'Test/Dev'
	   when netbios_name0 like '%WEL%' then 'Test/Dev'
	   when netbios_name0 like '%WES%' then 'Test/Dev'
	   when netbios_name0 like '%WEX%' then 'Test/Dev'
	   when netbios_name0 like '%WTC%' then 'Test/Dev'
	   when netbios_name0 like '%WTG%' then 'Test/Dev'
	   when netbios_name0 like '%WTL%' then 'Test/Dev'
	   when netbios_name0 like '%WTS%' then 'Test/Dev'
	   when netbios_name0 like '%WTX%' then 'Test/Dev'
	   end [Environment],
	   Resource_Domain_OR_Workgr0 [Domain], client0 [Client], Client_Version0 [Client Version], Operating_System_Name_and0 [OS]
from v_r_system
where operating_system_name_and0 not in (
		'AIX 7.1 ppc',
		'Windows NT 4.0',
		'Windows 10 Enterprise 10.0',
		'Windows 10 Enterprise Insider Preview 10.0',
		'Samba 3.0.20b-3.1-SUSE',
		'Windows Workstation 6.1'
		) and
		Netbios_Name0 not like '%ESX%' and
		Operating_System_Name_and0 not like '%Linux%' and
		Operating_System_Name_and0 not like 'Microsoft Windows NT Workstation%' and
		Operating_System_Name_and0 not like 'Mac OS X%' and
		Operating_System_Name_and0 not like 'Darwin%' and
		Operating_System_Name_and0 not like 'Data Domain OS%' and
		Operating_System_Name_and0 != ' ' and
	  ((Client_Version0 != '5.00.7958.1501' and
	  Client_Version0 != '5.00.8239.1000') or
	  Client_Version0 is null)
order by Environment, Name