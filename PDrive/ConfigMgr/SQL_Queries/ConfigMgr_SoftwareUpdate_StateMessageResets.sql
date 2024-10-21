with TotalPatchesReported as (
SELECT css.ResourceID, 
  COUNT(css.ResourceID) AS PatchCount
FROM 
    v_UpdateComplianceStatus AS css 
    Inner join v_UpdateInfo AS ui ON ui.CI_ID = css.CI_ID  INNER JOIN
    v_CICategories_All AS cat ON ui.CI_ID = cat.CI_ID  AND 
    ui.CI_UniqueID NOT LIKE  'Scope%' AND 
	cat.CategoryTypeName = 'UpdateClassification' AND
	cat.CategoryInstanceID = '31'
GROUP BY css.ResourceID
)
select TotalPatchesReported.ResourceID, sys.Netbios_Name0, sys.Operating_System_Name_and0, sys.Client_Version0, TotalPatchesReported.PatchCount
from TotalPatchesReported inner join
	 v_R_System_Valid SYS on TotalPatchesReported.ResourceID = sys.ResourceID
where TotalPatchesReported.PatchCount < 60
order by PatchCount