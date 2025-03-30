-- Win10 settings
select CurrentSetting0, count(*)
from v_gs_lenovo_biossetting
where currentsetting0 like 'Boot Mode%' or currentsetting0 like 'CSM%' or 
	  currentsetting0 like 'OS Optim%' or currentsetting0 like 'Secure Boot%' or 
	  currentsetting0 like 'SecureBoot%' or CurrentSetting0 like 'Credential%' or 
	  CurrentSetting0 like 'Data%' or CurrentSetting0 like 'Virtual%' or CurrentSetting0 like 'UEFI%'
group by currentsetting0

-- UEFI and SecureBoot
select CurrentSetting0, count(*)
from v_gs_lenovo_biossetting
where currentsetting0 like 'Boot Mode%' or currentsetting0 like 'CSM%' or 
	  currentsetting0 like 'OS Optim%' or currentsetting0 like 'Secure Boot%' or 
	  currentsetting0 like 'SecureBoot%'
group by currentsetting0

-- UEFI and SecureBoot for a machine
select sys.Netbios_Name0, 
	(select CurrentSetting0 from v_GS_LENOVO_BIOSSETTING BIOS where bios.ResourceID = sys.ResourceID and bios.CurrentSetting0 like 'Boot Mode%'),
	(select CurrentSetting0 from v_GS_LENOVO_BIOSSETTING BIOS where bios.ResourceID = sys.ResourceID and bios.CurrentSetting0 like 'OS Optim%'),
	(select CurrentSetting0 from v_GS_LENOVO_BIOSSETTING BIOS where bios.ResourceID = sys.ResourceID and bios.CurrentSetting0 like 'CSM%'),
	(select CurrentSetting0 from v_GS_LENOVO_BIOSSETTING BIOS where bios.ResourceID = sys.ResourceID and bios.CurrentSetting0 like 'SecureBoot%'),
	(select CurrentSetting0 from v_GS_LENOVO_BIOSSETTING BIOS where bios.ResourceID = sys.ResourceID and bios.CurrentSetting0 like 'Secure Boot%'),
	(select CurrentSetting0 from v_GS_LENOVO_BIOSSETTING BIOS where bios.ResourceID = sys.ResourceID and bios.CurrentSetting0 like 'UEFIPXE%')
from v_r_system_valid sys
where Netbios_Name0 = 'WKPF0D2KG7'

-- All settings for a machine
select sys.Netbios_Name0, BIOS.CurrentSetting0
from v_r_system_valid sys left join
	 v_GS_LENOVO_BIOSSETTING BIOS on sys.ResourceID = BIOS.ResourceID
where Netbios_Name0 = 'DSIPXEWPW30' and CurrentSetting0 != ''
order by CurrentSetting0

-- All settings
select distinct BIOS.CurrentSetting0
from v_r_system_valid sys left join
	 v_GS_LENOVO_BIOSSETTING BIOS on sys.ResourceID = BIOS.ResourceID
where CurrentSetting0 like '%boot sequence%' or CurrentSetting0 like '%BootOrder%'
-- Automatic Boot Sequence,
-- BootOrder,
-- Error Boot Sequence,
-- NetworkBootOrder,
-- Primary Boot Sequence,
order by CurrentSetting0

-- UEFI and SecureBoot for a model
select csp.version0, bios.CurrentSetting0, count(*)
from v_r_system_valid sys left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on sys.ResourceID = csp.ResourceID join
	 v_GS_LENOVO_BIOSSETTING BIOS on sys.ResourceID = BIOS.ResourceID
where csp.Version0 = 'ThinkPad T460s' 
group by csp.Version0, bios.CurrentSetting0
order by bios.CurrentSetting0

-- Settings for a model
select Version0, bios.CurrentSetting0, count(*)
from v_R_System_Valid sys left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID left join
	 v_GS_LENOVO_BIOSSETTING BIOS on sys.ResourceID = bios.ResourceID
where version0 in ('ThinkPad T460') 
--and (currentsetting0 like 'Boot Mode%' or currentsetting0 like 'CSM%' or currentsetting0 like 'OS Optim%' or currentsetting0 like 'Secure Boot%' or currentsetting0 like 'SecureBoot%' or CurrentSetting0 like 'Credential%' or CurrentSetting0 like 'Data%' or CurrentSetting0 like 'Virtual%')
group by Version0, bios.CurrentSetting0
order by Version0, bios.CurrentSetting0

-- Settings for specific models
select Version0, bios.CurrentSetting0, count(*)
from v_R_System_Valid sys left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID left join
	 v_GS_LENOVO_BIOSSETTING BIOS on sys.ResourceID = bios.ResourceID
where version0 in (
'ThinkPad T550',
'ThinkPad T560','ThinkPad T560s','ThinkPad T570 W10DG',
'ThinkPad X1 Carbon 3rd','ThinkPad X1 Carbon 4th','ThinkStation P510') 
and (currentsetting0 like 'Boot Mode%' or currentsetting0 like 'CSM%' or 
	currentsetting0 like 'OS Optim%' or currentsetting0 like 'Secure Boot%' or 
	currentsetting0 like 'SecureBoot%' or CurrentSetting0 like 'Credential%' or 
	CurrentSetting0 like 'Data%' or CurrentSetting0 like 'Virtual%')
group by Version0, bios.CurrentSetting0
order by Version0, bios.CurrentSetting0

-- Boot Mode and Boot Priority
select distinct CurrentSetting0
from v_R_System_Valid sys join
	 v_GS_LENOVO_BIOSSETTING BIOS on sys.ResourceID = bios.ResourceID
where CurrentSetting0 like 'Boot Mode%' or CurrentSetting0 like 'Boot Pri%'
order by CurrentSetting0

-- Boot mode and model
select distinct version0, CurrentSetting0
from v_R_System_Valid sys join
	 v_GS_LENOVO_BIOSSETTING BIOS on sys.ResourceID = bios.ResourceID left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on sys.ResourceID = csp.ResourceID
where CurrentSetting0 like 'Boot Mode%'
order by CurrentSetting0, Version0

-- Boot priority and model
select distinct version0, CurrentSetting0
from v_R_System_Valid sys join
	 v_GS_LENOVO_BIOSSETTING BIOS on sys.ResourceID = bios.ResourceID left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT CSP on sys.ResourceID = csp.ResourceID
where CurrentSetting0 like 'Boot Prior%'
order by version0, CurrentSetting0

-- Boot Order Lock for ThinkPads
select csp.Version0, CurrentSetting0, count(*)
from v_GS_LENOVO_BIOSSETTING lbs join 
	 v_gs_computer_system_product csp on lbs.resourceid = csp.resourceid
where CurrentSetting0 in ('BootOrderLock,Disable','BootOrderLock,Enable')
group by csp.Version0,CurrentSetting0
order by csp.Version0,CurrentSetting0