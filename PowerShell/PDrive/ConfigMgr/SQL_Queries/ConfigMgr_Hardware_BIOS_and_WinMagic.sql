select sys.Netbios_Name0, sft.ProductName0, sft.ProductVersion0, csp.Version0, bios.SMBIOSBIOSVersion0, bios.ReleaseDate0
from v_r_system_valid sys join
	 v_gs_installed_software sft on sys.ResourceID = sft.ResourceID join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID join
	 v_GS_PC_BIOS bios on sys.ResourceID = bios.ResourceID
where ProductName0 = 'SecureDoc Disk Encryption (x64) 7.5' and sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP' and csp.Version0 in (
'Lenovo Product',
'ThinkCentre M700',
'ThinkCentre M710q',
'ThinkCentre M800',
'ThinkCentre M81',
'ThinkCentre M82',
'ThinkCentre M83',
'ThinkCentre M900',
'ThinkCentre M910q',
'ThinkCentre M910s',
'ThinkCentre M91p',
'ThinkCentre M92p',
'ThinkCentre M93p',
'ThinkCentre M93z',
'ThinkStation P500',
'ThinkStation P510',
'ThinkStation S30'
)
order by Netbios_Name0