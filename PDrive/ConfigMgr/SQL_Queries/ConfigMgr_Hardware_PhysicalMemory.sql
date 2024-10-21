-- List of machines
select distinct Netbios_Name0 [WKID], sys.user_name0 [User], usr.Full_User_Name0 [Friendly Name], 
                (select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [MB RAM], 
                (select count(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [DIMM Count]
from v_gs_physical_memory mem join
	 v_r_system sys on mem.ResourceID = sys.ResourceID join
	 v_r_user USR ON sys.User_Name0 = usr.User_Name0
where Operating_System_Name_and0 like '%workstation%'
order by [WKID]

-- Count of machines
With MemoryCounts (resourceid, [MB RAM], [DIMM Count])
as
(select distinct sys.resourceid, (select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [MB RAM], 
	            (select count(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [DIMM Count]		 
from v_gs_physical_memory mem join
	 v_r_system sys on mem.ResourceID = sys.ResourceID
where Operating_System_Name_and0 like '%workstation%')
select [MB RAM], [DIMM Count], Count(*) [Total]
from MemoryCounts
group by [MB RAM], [DIMM Count]
having count(*) > 10
order by [MB RAM], [Dimm Count]

-- List of VMs and vCPU and RAM
select distinct sys.Netbios_Name0, ((select count(cpu1.DeviceID0)
	   from v_GS_PROCESSOR CPU1
	   where sys.ResourceID = cpu1.ResourceID) * cpu.NumberOfLogicalProcessors0) [vCPU], 
	   (select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [MB RAM]
from v_R_System_Valid sys left join
	 v_gs_processor cpu on sys.resourceid = cpu.resourceid
where is_virtual_machine0 = 1 and Resource_Domain_OR_Workgr0 = 'HUMAD' and (Netbios_Name0 like 'SIMXDW%' or Netbios_Name0 like 'LOUXDW%')

-- Count of VMs and vCPU and RAM
select ((select count(cpu1.DeviceID0)
	   from v_GS_PROCESSOR CPU1
	   where sys.ResourceID = cpu1.ResourceID) * cpu.NumberOfLogicalProcessors0) [vCPU], 
	   (select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [MB RAM], count(*)
from v_R_System_Valid sys left join
	 v_gs_processor cpu on sys.resourceid = cpu.resourceid
where is_virtual_machine0 = 1 and Resource_Domain_OR_Workgr0 = 'HUMAD' and (Netbios_Name0 like 'SIMXDW%' or Netbios_Name0 like 'LOUXDW%')
group by [vCPU],[MB RAM]


With MemoryCounts (resourceid, [MB RAM])
as
(select distinct sys.resourceid, (select sum(capacity0) from v_GS_PHYSICAL_MEMORY where v_GS_PHYSICAL_MEMORY.ResourceID = sys.ResourceID) [MB RAM]
from v_gs_physical_memory mem join
	 v_r_system sys on mem.ResourceID = sys.ResourceID
where Operating_System_Name_and0 like '%workstation%')
select [MB RAM], Count(*) [Total]
from MemoryCounts
group by [MB RAM]
having count(*)