-- Count of Avaya by OS
select case DeviceOS
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
	   end [OS], sft.ProductName0, count(*)
from vsms_combineddeviceresources sys inner join
	 v_GS_INSTALLED_SOFTWARE sft on sys.machineid = sft.ResourceID
where sft.ProductName0 = 'Avaya Proactive Contact Supervisor 5.1'
group by case DeviceOS
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
	   end, sft.ProductName0

select Name, case DeviceOS
		when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
		when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
		when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
		when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
	   end [OS], sft.ProductName0
from vsms_combineddeviceresources sys inner join
	 v_GS_INSTALLED_SOFTWARE sft on sys.machineid = sft.ResourceID
where sft.ProductName0 = 'Avaya Proactive Contact Supervisor 5.1'
order by [OS], name

-- WKID network info
select distinct name,nad.Description0 , nac.IPAddress0
from vSMS_CombinedDeviceResources sys left join
	 v_GS_NETWORK_ADAPTER nad on sys.MachineID = nad.ResourceID left join
	 v_GS_NETWORK_ADAPTER_CONFIGURATION nac on nad.DeviceID0 = nac.Index0 and sys.machineid = nac.ResourceID
where Name in (
'LOUHVMWFP0401','LOUHVMWFP3202','LOUHVMWFP3203','LOUXDWDEVA0332',
'LOUXDWDEVB2837','SIMXDWDEVB2876','SIMXDWDEVC2715','SIMXDWSTDB8349',
'SIMXDWSTDB8484','SIMXDWSTDB8487','SIMXDWSTDB8490','WKMJ04LTE2',
'WKMJ04WJUS','WKMJ04X2P6','WKMJ04X2QC','WKMJ05RNA0',
'WKMJ0661KQ','WKMJRYHEL','WKPC0G4WKE','WKPC0UQ1R1',
'WKPC0UQ236','WKPF09JSBF','WKPF0ALRVG','WKPF0E92TN',
'WKPF0ERVN7','WKPF0F4BAK','WKPF0IYBYT','WKR900MGTR',
'WKR900P13L','WKR9023NNE','WKR9023NXK','WKR902LZ03',
'WKR907ECVU','WKR90B9BCV','WKR90HRLY0') and adaptertype0 = 'Ethernet 802.3' and nac.IPAddress0 is not null
order by Name, IPAddress0