SELECT
  SMI.smio_MachineName AS 'Machine Name',
  SMI.smio_UniqueGuid AS 'Machine Guid',
  P.[prd_product] AS 'Product Name',
  [prl_rel_name] AS 'Release Version',
  MPH.mpch_completeddate_utc AS 'Reclaim Date',
  MPH.mpch_status AS 'Status',
  CASE
    WHEN MPH.mpch_status = 0 THEN 'User request Remove Software Now'
    WHEN MPH.mpch_status = 1 THEN 'Product Uninstalled'
    WHEN MPH.mpch_status = 2 THEN 'Uninstall Failed but Retry'
    WHEN MPH.mpch_status = 3 THEN 'Uninstall Failed Do not Retry'
    WHEN MPH.mpch_status = 5 THEN 'User Opted Out'
    WHEN MPH.mpch_status = 6 THEN 'UserDeferred'
  END
FROM [Release] AS R
INNER JOIN dbo.MachinePolicyHistory AS MPH
  ON R.prl_id = MPH.mpch_prl_id
INNER JOIN dbo.Product AS P
  ON MPH.mpch_prd_id = P.prd_id
INNER JOIN dbo.SiteMachineInfo AS SMI
  ON MPH.mpch_smio_id = SMI.smio_id



SELECT
  SMI.smio_MachineName AS 'Machine Name',
  PRD.[prd_product] AS 'Product Name',
  REL.[prl_rel_name] AS 'Release Version',
  MPH.mpch_completeddate_utc AS 'Reclaim Date',
  MPH.mpch_status AS 'status',
  CASE
    WHEN PRS.[sprx_possible_reclaim_action] = 1 THEN 'OptionalUninstall'
    WHEN PRS.[sprx_possible_reclaim_action] = 2 THEN 'MandatoryUninstall'
    ELSE 'DoNotUninstall'
  END AS 'Policy - Rarely Used',
  CASE
    WHEN PRS.[sprx_recommended_reclaim_action] = 1 THEN 'OptionalUninstall'
    WHEN PRS.[sprx_recommended_reclaim_action] = 2 THEN 'MandatoryUninstall'
    ELSE 'DoNotUninstall'
  END AS 'Policy - Unused',
  CASE
    WHEN PRS.[sprx_used_reclaim_action] = 1 THEN 'OptionalUninstall'
    WHEN PRS.[sprx_used_reclaim_action] = 2 THEN 'MandatoryUninstall'
    ELSE 'DoNotUninstall'
  END AS 'Policy - Used',
  CASE
    WHEN MPH.mpch_status = 0 THEN 'User request Remove Software Now'
    WHEN MPH.mpch_status = 1 THEN 'Product Uninstalled'
    WHEN MPH.mpch_status = 2 THEN 'Uninstall Failed but Retry'
    WHEN MPH.mpch_status = 3 THEN 'Uninstall Failed Do not Retry'
    WHEN MPH.mpch_status = 5 THEN 'User Opted Out'
    ELSE 'User Deferred Uninstall'
  END AS 'Reclaim Action'

FROM MachinePolicyHistory AS MPH
INNER JOIN SiteMachineInfo AS SMI
  ON MPH.mpch_id = SMI.smio_id
INNER JOIN Product AS PRD
  ON MPH.mpch_prd_id = PRD.prd_id
INNER JOIN Release AS REL
  ON MPH.mpch_prl_id = REL.prl_id
LEFT JOIN ManagementGroup AS MGRP
  ON MPH.mpch_mgrp_id = MGRP.mgrp_id
LEFT JOIN ProductReclaimSettings AS PRS
  ON (MPH.mpch_prd_id = PRS.sprx_prd_id)
  AND (MGRP.mgrp_id = PRS.sprx_mgrp_id)

WHERE MPH.mpch_status IN (1, 0, 3, 2, 4, 5)