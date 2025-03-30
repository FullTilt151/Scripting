select sys.Netbios_Name0, uss.ScanTime, ScanPackageVersion, LastScanState, LastErrorCode, LastWUAVersion
from v_r_system_valid sys join
	 v_GS_COMPUTER_SYSTEM cs on sys.ResourceID = cs.ResourceID join
	 v_UpdateScanStatus uss on sys.ResourceID = uss.ResourceID
where sys.Resource_Domain_OR_Workgr0 = 'RX1AD' and sys.Operating_System_Name_and0 in (
'Microsoft Windows NT Workstation 6.1',
'Microsoft Windows NT Workstation 6.1 (Tablet Edition)'
) and cs.SystemType0 = 'X86-based PC'
--and LastWUAVersion not in ('7.6.7601.24085','7.6.7601.23806')
order by Netbios_Name0