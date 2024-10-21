--Last used. DMStudio.exe = Documaker. DCVS = Documaker Addin for MS Word.
SELECT
  CompanyName0 Publisher,
  ProductName0 Product,
  ProductVersion0 Version,
  LastUsedTime0 LastUsedTime
FROM v_gs_ccm_recently_Used_apps
WHERE ResourceId = 16910570 and CompanyName0 like '%oracle%'

select *
from v_GS_CCM_RECENTLY_USED_APPS
where ExplorerFileName0 = 'dcvs.exe' and ResourceID = 16910570