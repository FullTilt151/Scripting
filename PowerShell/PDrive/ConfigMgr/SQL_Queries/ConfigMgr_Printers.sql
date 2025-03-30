-- List of potential remote printers for printnightmare CVE-2021-34527
select distinct DeviceID0, DriverName0, Name0, PortName0
from v_GS_PRINTER_DEVICE
where Name0 not in ('Fax', 'Humana Cloud Printer Win7','Microsoft XPS Document Writer', 'WebEx Document Loader','Adobe PDF','Adobe PDF Converter',
				'Print2Fax','RightFax Fax Printer','Humana Cloud Printer','Microsoft Print to PDF','Contract Logix PDF Writer','OneNote (Desktop)')
		and Name0 not like 'Snagit%'
		and Name0 not like 'Send to OneNote%'
		and PortName0 not in ('USB','NUL','nul:','BLUEBEAMPDFPORT','COM1:','Documents\*.pdf','FILE:','LPT1:','Webex Document Loader Port')
		and PortName0 not like 'USB00%'
		and PortName0 not like 'TS%'
		and PortName0 not like 'Client:%'
order by portname0, DriverName0, Name0

-- POS machine printers
select distinct DeviceID0, DriverName0, Name0, PortName0
from v_R_System_Valid sys left join
	 v_GS_PRINTER_DEVICE pr on sys.ResourceID = pr.ResourceID
where sys.Netbios_Name0 like 'POS%'
order by portname0, DriverName0, Name0