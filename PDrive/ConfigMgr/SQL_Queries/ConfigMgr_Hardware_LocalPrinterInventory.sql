SELECT SYS.Netbios_Name0 AS WKID, SYS.User_Name0 AS UserName, USR.Full_User_Name0 AS [Full Name], 
                      PRN.Name0 AS Name, PRN.Location0 AS Location, PRN.DriverName0 AS Driver, 
                      PRN.PortName0 AS Port, PRN.PrintProcessor0
FROM         dbo.v_R_System SYS INNER JOIN
                      dbo.v_R_User USR ON SYS.User_Name0 = USR.User_Name0 INNER JOIN
                      dbo.v_GS_PRINTER_DEVICE PRN ON SYS.ResourceID = PRN.ResourceID
where (PortName0 not like 'LPT%' 
			and PortName0 not like '%HPFAX' 
			and PortName0 not like '%rightfax\spooljob%' 
			and PortName0 not like '%TechSmith%' 
			and PortName0 not like '%pdf%' 
			and PortName0 not like 'Microsoft%:' 
			and PortName0 != 'nul:' 
			and PortName0 != 'SHRFAX:' 
			and PortName0 != 'XPSPort:' 
			and PortName0 != 'CCMS_FAX' 
			and PortName0 != 'ZETASPL:' 
			and PortName0 not like '%APDCPort%:%' 
			and PortName0 not like '%COM%:%' 
			and PortName0 not like 'c:\%' 
			and PortName0 != 'FAX:' 
			and PortName0 != 'File:' 
			and PortName0 != 'CPW2:' 
			and PortName0 != 'FXC:' 
			and PortName0 not like 'iceport%' 
			and PortName0 != 'NVK6:' 
			and PortName0 != 'WebEx Document Loader Port' 
			and PortName0 not like 'USB00%' 
			and PRN.Name0 not like '%pdf%') and
			prn.PortName0 like '193.51.117.201'
order by wkid, SYS.User_Name0