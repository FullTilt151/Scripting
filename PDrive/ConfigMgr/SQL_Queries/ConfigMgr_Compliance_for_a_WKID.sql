SELECT
  fcm.name, ba.assignmentName, lcb.IsAssigned, cs.ComplianceState,
  CASE
    WHEN cs.ComplianceState = 1 THEN 'Compliant'
    WHEN cs.ComplianceState = 2 THEN 'Non-Compliant'
    WHEN cs.ComplianceState = 4 THEN 'Failure'
  END AS 'TextComplianceState',
  cs.IsEnforced, cs.ComplianceValidationRuleFailures, cs.errorCount, cs.ConflictCount, cs.LastComplianceMessageTime, cs.LastEnforcementMessageTime, ciinfo.DisplayName, ciinfo.description
FROM vSMS_BaselineAssignment ba JOIN 
	 v_fullcollectionmembership fcm ON fcm.collectionid = ba.collectionid JOIN 
	 fn_ListconfigurationBaselineInfo(1033) lcb ON lcb.CI_UniqueID = ba.AssignedCI_UniqueID JOIN 
	 vSMS_CombinedconfigurationItemRelations cir ON cir.FromCI_ID = lcb.CI_ID JOIN 
	 v_ConfigurationItems ci ON ci.ci_id = cir.TOCI_ID JOIN 
	 dbo.v_CICurrentComplianceStatus cs WITH (NOLOCK) ON cs.CI_ID = ci.ci_ID AND cs.Resourceid = fcm.resourceid JOIN 
	 fn_ListCIs(1033) ciinfo ON ciinfo.ci_id = cs.ci_id
WHERE --(fcm.name = 'WKR8NLR2F' or fcm.name = 'WKR89ZGZ4' orfcm.name = 'WKPBP07W1' orfcm.name = 'WKR991GRA' orfcm.name = 'WKPB0TREN' orfcm.name = 'WKPBN1GYC' orfcm.name = 'WKPBP498P') and 
AssignmentName = 'Est - Baseline - Windows member Servers - Test_All Windows Servers Limiting Collection'
AND ciinfo.DisplayName = 'EST - Script - SCCM Client check in'
--and cs.isapplicable=1 and cs.isdetected=1