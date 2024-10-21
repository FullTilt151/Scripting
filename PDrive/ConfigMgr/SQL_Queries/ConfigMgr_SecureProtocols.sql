-- Count of SecureProtocols
select case Operating_System_Name_and0 
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
	   when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
	   end [OS], 
	  case user0
	   when 'WinHttp32' then 'WinHttp32'
	   when 'WinHttp64' then 'WinHttp64'
	   when 'IE64' then 'IE64' 
	   else 'User'
	   end [User], 
	   case 
	   when SecureProtocols0 like '{%}' then 'Null'
	   else SecureProtocols0
	   end [SecureProtocols], count(*)
from v_R_System_Valid sys join
	 v_GS_SECURE_PROTOCOLS sp on sys.ResourceID = sp.ResourceID
group by case Operating_System_Name_and0 
	   when 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
	   when 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
	   when 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
	   end, 
	   case user0
	   when 'WinHttp32' then 'WinHttp32'
	   when 'WinHttp64' then 'WinHttp64'
	   when 'IE64' then 'IE64' 
	   else 'User'
	   end, case 
	   when SecureProtocols0 like '{%}' then 'Null'
	   else SecureProtocols0
	   end
order by [OS], [User], [SecureProtocols]

-- List of machines missing user keys
select netbios_name0
from v_r_system_valid sys
where sys.Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 6.1','Microsoft Windows NT Workstation 6.1 (Tablet Edition)') and sys.Resource_Domain_OR_Workgr0 = 'HUMAD' and sys.ResourceID not in (
select distinct sys.resourceid
from v_R_System_Valid sys left join
	 v_GS_SECURE_PROTOCOLS sp on sys.ResourceID = sp.ResourceID
where sys.Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 6.1','Microsoft Windows NT Workstation 6.1 (Tablet Edition)') and user0 not in ('WinHttp32','WinHttp64','IE64'))
order by Netbios_Name0

-- Different values inventoried
select distinct SecureProtocols0
from v_GS_SECURE_PROTOCOLS
where ISNUMERIC(SecureProtocols0) = 1
order by SecureProtocols0

-- SecureProtocols for a specific machine
select sys.Netbios_Name0, ssl.User0, ssl.SecureProtocols0
from v_R_System_Valid sys join
	 v_GS_SECURE_PROTOCOLS ssl on sys.ResourceID = ssl.ResourceID
where sys.Netbios_Name0 = 'WKPC0J25ED'
order by User0

/*
40 - SSL 2.0, SSL 3.0
128 - TLS 1.0
160 - SSL 3.0,TLS 1.0
168 - SSL 2.0, SSL 3.0,TLS 1.0
672 - SSL 3.0, TLS 1.0, TLS 1.1
2088 - SSL 2.0, SSL 3.0,TLS 1.2
2560 - TLS 1.1, TLS 1.2
2600 - SSL 2.0, SSL 3.0, TLS 1.1, TLS 1.2
2688 - TLS 1.0, TLS 1.1, TLS 1.2
2696 - SSL 2.0, TLS 1.0, TLS 1.1, TLS 1.2
2720 - SSL 3.0, TLS 1.0, TLS 1.1, TLS 1.2
2728 - SSL 2.0, SSL 3.0, TLS 1.0, TLS 1.1, TLS 1.2
*/

-- https://support.microsoft.com/en-us/help/3140245/update-to-enable-tls-1.1-and-tls-1.2-as-a-default-secure-protocols-in-winhttp-in-windows

/*
0x00000008 SSL 2.0
0x00000020 SSL 3.0
0x00000080 TLS 1.0
0x00000200 TLS 1.1
0x00000800 TLS 1.2
*/