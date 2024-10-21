select sys.netbios_name0, Operating_System_Name_and0, 
(select ProductName0 + ' ' + ProductVersion0 from v_GS_INSTALLED_SOFTWARE sft where ProductName0 = 'McAfee Agent' and sft.ResourceID = sys.resourceid) [Agent],
(select ProductName0 + ' ' + ProductVersion0 from v_GS_INSTALLED_SOFTWARE sft where ProductName0 = 'McAfee VirusScan Enterprise' and sft.ResourceID = sys.resourceid) [VSE],
(select ProductName0 + ' ' + ProductVersion0 from v_GS_INSTALLED_SOFTWARE sft where ProductName0 = 'McAfee Endpoint Security Platform' and sft.ResourceID = sys.resourceid) [ENS],
(select ProductName0 + ' ' + ProductVersion0 from v_GS_INSTALLED_SOFTWARE sft where ProductName0 like 'Move AV%' and sft.ResourceID = sys.resourceid) [Move],
(select AgentVersion0 from v_GS_VDG640 dg where dg.ResourceID = sys.resourceid) [DG Reg]
from v_r_system_valid sys
where operating_system_name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0')
order by Netbios_Name0