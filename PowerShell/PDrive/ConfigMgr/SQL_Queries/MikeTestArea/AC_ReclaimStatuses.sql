SELECT SMI.smio_MachineName AS 'Machine Name'
    ,P.[prd_product] AS 'Product Name'
    ,[prl_rel_name] AS 'Release Version'
	,MPH.mpch_completeddate_utc AS 'Reclaim Date'
    ,CASE WHEN MPH.mpch_status = 0 THEN 'User request Remove Software Now'
                                WHEN MPH.mpch_status = 1 THEN 'Product Uninstalled'
                                WHEN MPH.mpch_status = 2 THEN 'Uninstall Failed but Retry'
                                WHEN MPH.mpch_status = 3 THEN 'Uninstall Failed Do not Retry'
                                WHEN MPH.mpch_status = 5 THEN 'User Opted Out'
                                WHEN MPH.mpch_status = 6 THEN 'UserDeferred'
								WHEN MPH.mpch_status = 7 THEN 'Unknown'
                                end [Status]
FROM [Release] AS R
    INNER JOIN dbo.MachinePolicyHistory AS MPH ON R.prl_id = MPH.mpch_prl_id
      INNER JOIN dbo.Product AS P ON MPH.mpch_prd_id = P.prd_id
      INNER JOIN dbo.SiteMachineInfo AS SMI ON MPH.mpch_smio_id = SMI.smio_id