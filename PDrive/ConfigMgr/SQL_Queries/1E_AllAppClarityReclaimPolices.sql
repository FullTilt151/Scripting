SELECT
  d.mgrp_name AS [Management Group],
  e.pub_name AS [Publisher],
  b.prd_product AS [Product],
  b.prd_edition AS [Edition],
  c.prl_rel_name AS [Release],
  CASE A.sprx_recommended_reclaim_action
    WHEN 0 THEN 'Do Not Uninstall'
    WHEN 1 THEN 'Optional Uninstall'
    WHEN 2 THEN 'Mandatory Uninstall'
  END AS [Unused],
  CASE A.sprx_possible_reclaim_action
    WHEN 0 THEN 'Do Not Uninstall'
    WHEN 1 THEN 'Optional Uninstall'
    WHEN 2 THEN 'Mandatory Uninstall'
  END AS [Rarely Used],
  CASE A.sprx_used_reclaim_action
    WHEN 0 THEN 'Do Not Uninstall'
    WHEN 1 THEN 'Optional Uninstall'
    WHEN 2 THEN 'Mandatory Uninstall'
  END AS [Used],

  CASE A.sprx_unknown_reclaim_action
    WHEN 0 THEN 'Do Not Uninstall'
    WHEN 1 THEN 'Optional Uninstall'
    WHEN 2 THEN 'Mandatory Uninstall'
  END AS [Unknown],
  a.sprx_use_global,
  a.sprx_is_global,
  a.sprx_enforce,
  e.pub_id,
  b.prd_id,
  c.prl_id
FROM ProductReclaimSettings AS A
LEFT JOIN Product AS B
  ON a.sprx_prd_id = b.prd_id
LEFT JOIN Release AS C
  ON a.sprx_prl_id = c.prl_id
LEFT JOIN ManagementGroup AS D
  ON a.sprx_mgrp_id = d.mgrp_id
LEFT JOIN Publisher AS E
  ON b.prd_pub_guid = e.pub_guid
ORDER BY Publisher, Product, Release DESC, [Management Group]