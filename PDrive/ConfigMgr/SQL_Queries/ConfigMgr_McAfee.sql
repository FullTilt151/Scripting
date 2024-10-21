-- All VMs with VSE
select Netbios_Name0, Operating_System_Name_and0, Resource_Domain_OR_Workgr0, DisplayName0, Version0
from v_r_system SYS join
	 v_Add_Remove_Programs ARP on sys.ResourceID = arp.ResourceID
where client0 = '1' and
	  is_virtual_machine0 = '1' and
	  arp.DisplayName0 = 'McAfee VirusScan Enterprise'
order by Resource_Domain_OR_Workgr0, Netbios_Name0

-- Workstation VMs with VSE
select Netbios_Name0, Operating_System_Name_and0, Resource_Domain_OR_Workgr0, DisplayName0, Version0
from v_r_system SYS join
	 v_Add_Remove_Programs ARP on sys.ResourceID = arp.ResourceID
where client0 = '1' and
	  is_virtual_machine0 = '1' and
	  arp.DisplayName0 = 'McAfee VirusScan Enterprise' and
	  operating_system_name_and0 like '%workstation%'
order by Resource_Domain_OR_Workgr0, Netbios_Name0

-- Server VMs with VSE
select Netbios_Name0, Operating_System_Name_and0, Resource_Domain_OR_Workgr0, DisplayName0, Version0
from v_r_system SYS join
	 v_Add_Remove_Programs ARP on sys.ResourceID = arp.ResourceID
where client0 = '1' and
	  is_virtual_machine0 = '1' and
	  arp.DisplayName0 = 'McAfee VirusScan Enterprise' and 
	  Operating_System_Name_and0 not like '%workstation%'
order by Resource_Domain_OR_Workgr0, Netbios_Name0

-- Count of McAfee Agent, VSE, and Move versions
select distinct DisplayName0, Version0, count(*)
from v_Add_Remove_Programs
where (DisplayName0 = 'McAfee VirusScan Enterprise' or
	  DisplayName0 = 'McAfee Agent' or
	  DisplayName0 like 'MOVE AV%') and
	  DisplayName0 != 'MOVE AV 2.6 [ Multi-Platform ] Offload Scan Server'
group by DisplayName0, Version0
order by DisplayName0, Version0




