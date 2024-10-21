select sys.Netbios_Name0, ip6.*
from v_r_system SYS LEFT JOIN
	v_GS_TCPIP6640 IP6 ON SYS.ResourceID = IP6.ResourceID
where sys.Operating_System_Name_and0 like '%workstation%'
order by Netbios_Name0

select sys.Netbios_Name0 [WKID], int.EnableDHCP0 [DHCP Enabled], int.DhcpIPAddress0 [IP], int.DhcpServer0 [DHCP], int.DhcpSubnetMask0 [Subnet Mask], int.NameServer0 [Static DNS]
from v_r_system SYS LEFT JOIN
	v_GS_interfaces0 INT ON SYS.ResourceID = INT.ResourceID
where sys.Operating_System_Name_and0 like '%workstation%' and (NameServer0 IS NOT NULL and NameServer0 != ' ')
order by Netbios_Name0