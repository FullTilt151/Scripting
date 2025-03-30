select sys.Netbios_Name0, sys.Operating_System_Name_and0 , csp.Version0, SMBIOSBIOSVersion0, 
		(select currentsetting0 from v_GS_LENOVO_BIOSSETTING where CurrentSetting0 like 'Boot Mode%' and ResourceID = sys.resourceid),
		(select currentsetting0 from v_GS_LENOVO_BIOSSETTING where CurrentSetting0 like 'Boot Prio%' and ResourceID = sys.resourceid),
		(select currentsetting0 from v_GS_LENOVO_BIOSSETTING where CurrentSetting0 like 'OS Opt%' and ResourceID = sys.resourceid)
from v_R_System_Valid sys left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on sys.ResourceID = csp.ResourceID left join
	 v_GS_PC_BIOS bios on sys.ResourceID = bios.ResourceID
where sys.Netbios_Name0 in (
'WKMJ055E6', -- Todd Gupton
'WKMJ02EH4K', -- Matthew Steele
'WKMJ02HR2T', -- Tim Renshaw
'WKMJ57B2F', -- David Rak
'WKMJ39P5R', -- Darrell Dillon
'WKMJ745BZ', -- Jason Luckey TEST
'WKMJWDGLG', -- Dan Stinson
'WKMJ002RJP', -- Chad Jensen
'WKMJ02LCL4', -- Dave McAfee
'WKMJRTBZD' -- Bozz TEST
)