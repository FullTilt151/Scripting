SELECT
  a.mpch_id [Id],
  b.smio_MachineName Machine,
  f.pub_name Publisher,
  c.prd_product Product,
  d.prl_rel_name Release,
  a.mpch_completeddate_utc DateStamp,
  e.smst_desc [Status],
  a.mpch_additional_data [Extra Status]
FROM MachinePolicyHistory AS A
LEFT JOIN SiteMachineInfo AS B
  ON A.mpch_smio_id = b.smio_id
LEFT JOIN Product AS C
  ON a.mpch_prd_id = c.prd_id
LEFT JOIN Release AS D
  ON a.mpch_prl_id = d.prl_id
LEFT JOIN MachinePolicyStatus AS e
  ON a.mpch_status = e.smst_id
LEFT JOIN Publisher AS f
  ON c.prd_pub_guid = f.pub_guid
LEFT JOIN ManagementGroup AS g
  ON a.mpch_mgrp_id = g.mgrp_id
WHERE b.smio_MachineName LIKE '%%'
AND c.prd_product LIKE '%%'
ORDER BY Machine DESC
