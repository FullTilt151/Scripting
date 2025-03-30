select Netbios_Name0, CompanyName0, ExplorerFileName0, FileDescription0,FORMAT(LastUsedTime0, 'M/d/yyyy')[Date],ProductVersion0
from v_GS_CCM_RECENTLY_USED_APPS Rec
Join v_R_System_Valid sys on rec.ResourceID = sys.ResourceID
--where LastUsedTime0 <= '2017-03-18'
where CompanyName0 = '1E'
--where  Netbios_Name0 = 'WKPBM8M5F'
order by LastUsedTime0

select Netbios_Name0[Workstation], CompanyName0[Vendor],FileDescription0[App],FORMAT(LastUsedTime0, 'M/d/yyyy')[Last Run Date],ProductVersion0[Version]
from v_GS_CCM_RECENTLY_USED_APPS Rec
Join v_R_System_Valid sys on rec.ResourceID = sys.ResourceID
--where Netbios_Name0 = 'WKPBM8M5F'

select *
from v_R_System_Valid
where Netbios_Name0 = 'WKPBM8M5F'