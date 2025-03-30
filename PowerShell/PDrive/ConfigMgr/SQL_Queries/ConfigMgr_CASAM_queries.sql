/*
select org_level_2.name as org_level_2_name,locations.name as locations_name,users.first_name as users_first_name, users.last_name as users_last_name,contracts.description as contracts_description,
	   device_statuses.name as device_statuses_name, data_sources.description as data_sources_description,devices.org_level_2_id,devices.device_status_id,devices.location_id, devices.user_id,
	   devices.contract_id,devices.data_source_id,devices.ip_address,devices.delivery_date,devices.installation_date, devices.inventory_date as last_run_date,devices.cpu_socket_count,
	   devices.cpu_chip_count,devices.cpu_core_count,devices.cpu_name, devices.cpu_speed,devices.graphics,devices.bios,devices.remarks,devices.cust_col_1 as last_logon_user 
from devices LEFT OUTER JOIN 
	 org_level_2 on devices.org_level_2_id = org_level_2.org_level_2_id LEFT OUTER JOIN 
	 locations on devices.location_id = locations.location_id LEFT OUTER JOIN 
	 users on devices.user_id = users.user_id LEFT OUTER JOIN 
	 contracts on devices.contract_id = contracts.contract_id LEFT OUTER JOIN 
	 device_statuses on devices.device_status_id = device_statuses.device_status_id LEFT OUTER JOIN 
	 data_sources on devices.data_source_id = data_sources.data_source_id 
where device_key ='AUSNASWPS01'
*/


SELECT RS.Netbios_Name0 AS import_id, 'humana_sccm' AS import_data_source_id, Computer_System_DATA.Name0 AS device_key, 'default' AS import_org_level_2_id, COALESCE(Computer_System_DATA.Name0, '') AS device_name, 
	   COALESCE(Computer_System_DATA.Manufacturer0, '') AS device_manufacturer, COALESCE(Computer_System_DATA.Model0, '') AS device_model, COALESCE('sccm_' + System_Enclosure_DATA.ChassisTypes0, '') AS import_device_type_id, 
	   COALESCE( STUFF (( SELECT ',' + v_GS_NETWORK_ADAPTER_CONFIGUR.IPAddress0 
						  FROM v_GS_NETWORK_ADAPTER_CONFIGUR 
						  WHERE v_GS_NETWORK_ADAPTER_CONFIGUR.IPEnabled0 = 1 AND 
							    v_GS_NETWORK_ADAPTER_CONFIGUR.ResourceID = Computer_System_DATA.ResourceID FOR XML PATH('')),1,1,''),'') AS ip_address, 
	   COALESCE( STUFF (( SELECT ',' + v_GS_NETWORK_ADAPTER_CONFIGUR.MACAddress0 
						  FROM v_GS_NETWORK_ADAPTER_CONFIGUR 
						  WHERE v_GS_NETWORK_ADAPTER_CONFIGUR.IPEnabled0 = 1 AND 
						  v_GS_NETWORK_ADAPTER_CONFIGUR.ResourceID = Computer_System_DATA.ResourceID FOR XML PATH('')),1,1,''),'') AS mac_address,	
	   COALESCE(System_Enclosure_DATA.SMBIOSAssetTag0, '') AS inventory_number, COALESCE(PC_BIOS_DATA.SerialNumber0, '') AS serial_number, 
	   COALESCE(LEFT(CONVERT(VARCHAR, Operating_System_DATA.InstallDate0, 101), 11), '') AS installation_date, COALESCE(LTRIM(Processor_DATA.Name0), '') AS cpu_name, 
	   COALESCE(LTRIM(Processor_DATA.Name0), '') AS import_cpu_type_id, COALESCE(LTRIM(Processor_DATA.NormSpeed0), '') AS cpu_speed, COALESCE(PC_Memory_DATA.TotalPhysicalMemory0 / 1024, '') AS ram, 
	   COALESCE(Disk_DATA.Size0 / 1024, '') AS storage, COALESCE(Video_Controller_DATA.Description0, '') AS graphics, 'AD Site Name: ' + RS.AD_Site_Name0 AS network, 
	   COALESCE(PC_BIOS_DATA.Description0, '') AS bios, 
	   COALESCE(Operating_System_Data.Caption0, '') + ' ' + COALESCE(Operating_System_Data.CSDVersion0, '') + ' ' + COALESCE(Operating_System_Data.Version0, '') AS operating_system, COALESCE(cpus.cpu_count, '') AS cpu_chip_count, 
	   COALESCE(UserName0, '') AS cust_col_1, COALESCE(NumberOfCores0, '') AS cpu_core_count, COALESCE(Domain0, '') AS fqdn, COALESCE(LastHWScan, '') AS inventory_date 
FROM v_gs_Computer_System Computer_System_DATA LEFT JOIN 
	 v_GS_NETWORK_ADAPTER_CONFIGUR Network_DATA ON (Computer_System_DATA.Resourceid = Network_DATA.Resourceid AND Network_DATA.Index0 = 1) LEFT JOIN 
	 v_gs_Network_adapter netcard_DATA ON (Computer_System_DATA.Resourceid = Netcard_DATA.Resourceid AND Netcard_DATA.DeviceID0 = '1') LEFT JOIN 
	 v_gs_Operating_System Operating_System_Data ON (Computer_System_DATA.Resourceid = Operating_System_DATA.Resourceid AND Operating_System_DATA.BootDevice0 = '\Device\HarddiskVolume1') LEFT JOIN 
	 v_gs_Processor Processor_DATA ON (Computer_System_DATA.Resourceid = Processor_DATA.Resourceid AND Processor_DATA.DeviceID0 = 'CPU0') LEFT JOIN 
	 v_GS_X86_PC_MEMORY pc_memory_DATA ON (Computer_System_DATA.Resourceid = PC_Memory_DATA.Resourceid) LEFT JOIN 
	 v_gs_Disk disk_DATA ON (Computer_System_DATA.Resourceid = Disk_DATA.Resourceid AND Disk_DATA.Index0 = 0) LEFT JOIN 
	 v_gs_Video_Controller Video_Controller_DATA ON (Computer_System_DATA.Resourceid = Video_Controller_DATA.Resourceid AND Video_Controller_DATA.DeviceID0 = 'VideoController1') LEFT JOIN 
	 v_gs_PC_BIOS PC_BIOS_DATA ON (Computer_System_DATA.Resourceid = PC_BIOS_DATA.Resourceid) LEFT JOIN 
	 ( SELECT ResourceID, COUNT(*) AS cpu_count FROM v_gs_Processor GROUP BY resourceID ) cpus ON (Computer_System_DATA.Resourceid = cpus.Resourceid) LEFT JOIN 
	 v_gs_System_Enclosure System_Enclosure_data ON (Computer_System_DATA.Resourceid = System_Enclosure_DATA.Resourceid AND System_Enclosure_DATA.GroupID = 1) LEFT JOIN 
	 v_R_System_valid RS ON (Computer_System_DATA.Resourceid = RS.ResourceID) LEFT JOIN v_GS_WORKSTATION_STATUS WS ON (RS.ResourceID = WS.ResourceID) LEFT JOIN 
	 v_CH_ClientSummary CS ON (RS.ResourceID = CS.ResourceID) 
WHERE DateDiff(dd, WS.LastHWScan, getdate()) <= '30' /* Only systems that have recently reported back */
GROUP BY Computer_System_DATA.Resourceid, Computer_System_DATA.Name0, Computer_System_DATA.UserName0, Network_DATA.IPAddress0, Netcard_DATA.MACAddress0, 
		 Operating_System_DATA.InstallDate0, Processor_DATA.Name0, Processor_DATA.NormSpeed0, PC_Memory_DATA.TotalPhysicalMemory0, Disk_DATA.Size0, 
		 Video_Controller_DATA.Description0, Netcard_DATA.Description0, PC_BIOS_DATA.Description0, System_Enclosure_DATA.ChassisTypes0, Operating_System_Data.Caption0, 
		 Operating_System_Data.CSDVersion0, Operating_System_Data.Version0, cpus.cpu_count, System_Enclosure_DATA.SMBIOSAssetTag0, Processor_DATA.DeviceID0, 
		 Computer_System_DATA.Manufacturer0, Computer_System_DATA.Model0, System_Enclosure_DATA.SerialNumber0, PC_BIOS_DATA.SerialNumber0, RS.AD_Site_Name0, 
		 RS.Netbios_Name0, NumberOfCores0, Domain0, LastHWScan

SELECT DISTINCT CONVERT(VARCHAR(32), HASHBYTES('MD5', LOWER( COALESCE(app.Publisher0, '') + '_' + COALESCE(app.DisplayName0, '') + '_' + COALESCE(app.Version0, '') + '_' + RS.Netbios_Name0 )), 2) AS import_id , 
	   'humana_sccm' AS import_data_source_id , COALESCE(app.Publisher0, '') AS publisher , COALESCE(app.DisplayName0, '') AS product , COALESCE(app.Version0, '') AS product_version , 
	   RS.Netbios_Name0 AS import_device_id 
FROM v_GS_ADD_REMOVE_PROGRAMS app JOIN 
	 v_R_System_valid RS ON app.ResourceID = RS.ResourceID 
WHERE app.DisplayName0 IS NOT NULL /* Hotfix filtering */ AND app.DisplayName0 NOT LIKE '%KB[0-9][0-9][0-9][0-9]%' 
UNION 
SELECT DISTINCT CONVERT(VARCHAR(32), HASHBYTES('MD5', LOWER( COALESCE(app.Publisher0, '') + '_' + COALESCE(app.DisplayName0, '') + '_' + COALESCE(app.Version0, '') + '_' + RS.Netbios_Name0 )), 2) AS import_id , 
	  'humana_sccm' AS import_data_source_id , COALESCE(app.Publisher0, '') AS publisher , COALESCE(app.DisplayName0, '') AS product , COALESCE(app.Version0, '') AS product_version , 
	  RS.Netbios_Name0 AS import_device_id 
FROM v_GS_ADD_REMOVE_PROGRAMS_64 app JOIN 
	 v_r_system_valid RS ON app.ResourceID = RS.ResourceID 
WHERE app.DisplayName0 IS NOT NULL /* Hotfix filtering */ AND app.DisplayName0 NOT LIKE '%KB[0-9][0-9][0-9][0-9]%'