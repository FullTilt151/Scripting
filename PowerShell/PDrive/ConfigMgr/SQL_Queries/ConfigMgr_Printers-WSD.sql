-- Count of WSD printers
select distinct prt.Caption0, prt.DriverName0, prt.PortName0, count(*)
from v_R_System_Valid sys join
	 v_GS_PRINTER_DEVICE prt on sys.resourceid = prt.ResourceID
where Operating_System_Name_and0 like '%10.0%' and PortName0 like 'WSD%'
group by prt.Caption0, prt.DriverName0, prt.PortName0
order by prt.Caption0, prt.DriverName0, prt.PortName0

-- Workstations with WSD ports
select distinct netbios_name0
from v_R_System_Valid sys join
	 v_GS_PRINTER_DEVICE prt on sys.resourceid = prt.ResourceID
where Operating_System_Name_and0 like '%10.0%' and PortName0 like 'WSD%'
order by Netbios_Name0

-- Workstations and WSD port info
select netbios_name0, prt.Caption0, prt.DriverName0, prt.PortName0
from v_R_System_Valid sys join
	 v_GS_PRINTER_DEVICE prt on sys.resourceid = prt.ResourceID
where Operating_System_Name_and0 like '%10.0%' and PortName0 like 'WSD%'
order by Netbios_Name0, prt.Caption0, prt.DriverName0, prt.PortName0