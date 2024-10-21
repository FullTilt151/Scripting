-- List of SChannel settings per machine
select distinct sys.netbios_name0,  sys.operating_system_name_and0, 
(select ClientDisabledByDefault0 from v_GS_SCHANNEL_SSLTLS tls1 where sys.ResourceID = tls1.resourceid and SChannelProtocol0 = 'SSL 2.0') [SSL 2.0 DBD],
(select ClientEnabled0 from v_GS_SCHANNEL_SSLTLS tls2 where sys.ResourceID = tls2.resourceid and SChannelProtocol0 = 'SSL 2.0') [SSL 2.0 Enabled],
(select ClientDisabledByDefault0 from v_GS_SCHANNEL_SSLTLS tls3 where sys.ResourceID = tls3.resourceid and SChannelProtocol0 = 'SSL 3.0') [SSL 3.0 DBD],
(select ClientEnabled0 from v_GS_SCHANNEL_SSLTLS tls4 where sys.ResourceID = tls4.resourceid and SChannelProtocol0 = 'SSL 3.0') [SSL 3.0 Enabled],
(select ClientDisabledByDefault0 from v_GS_SCHANNEL_SSLTLS tls5 where sys.ResourceID = tls5.resourceid and SChannelProtocol0 = 'TLS 1.0') [TLS 1.0 DBD],
(select ClientEnabled0 from v_GS_SCHANNEL_SSLTLS tls6 where sys.ResourceID = tls6.resourceid and SChannelProtocol0 = 'TLS 1.0') [TLS 1.0 Enabled],
(select ClientDisabledByDefault0 from v_GS_SCHANNEL_SSLTLS tls7 where sys.ResourceID = tls7.resourceid and SChannelProtocol0 = 'TLS 1.1') [TLS 1.1 DBD],
(select ClientEnabled0 from v_GS_SCHANNEL_SSLTLS tls8 where sys.ResourceID = tls8.resourceid and SChannelProtocol0 = 'TLS 1.1') [TLS 1.1 Enabled],
(select ClientDisabledByDefault0 from v_GS_SCHANNEL_SSLTLS tls9 where sys.ResourceID = tls9.resourceid and SChannelProtocol0 = 'TLS 1.2') [TLS 1.2 DBD],
(select ClientEnabled0 from v_GS_SCHANNEL_SSLTLS tls10 where sys.ResourceID = tls10.resourceid and SChannelProtocol0 = 'TLS 1.2') [TLS 1.2 Enabled]
from v_R_System_Valid sys join
	 v_GS_SCHANNEL_SSLTLS ssl on sys.ResourceID = ssl.ResourceID
where sys.netbios_name0 = 'wkpc0mk25m'

-- Count of SCHannel settings by OS
select case sys.operating_system_name_and0 
	   when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
	   when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
	   when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
	   end [OS], 
	   ssl.SChannelProtocol0, ssl.ClientDisabledByDefault0, ssl.ClientEnabled0, counT(*)
from v_R_System_Valid sys join
	 v_GS_SCHANNEL_SSLTLS ssl on sys.ResourceID = ssl.ResourceID
where sys.operating_system_name_and0 in ('Microsoft Windows NT Workstation 6.1','Microsoft Windows NT Workstation 6.1 (Tablet Edition)', 'Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
group by case sys.operating_system_name_and0 
	   when 'Microsoft Windows NT Workstation 6.1' then 'Win7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Win7'
	   when 'Microsoft Windows NT Workstation 10.0' then 'Win10'
	   when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Win10'
	   end, 
	   ssl.SChannelProtocol0, ssl.ClientDisabledByDefault0, ssl.ClientEnabled0
order by [OS], ssl.SChannelProtocol0, ssl.ClientDisabledByDefault0, ssl.ClientEnabled0