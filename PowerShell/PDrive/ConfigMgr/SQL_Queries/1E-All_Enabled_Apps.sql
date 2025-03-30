SELECT [DisplayName] ,[ApplicationType]
      ,CASE [TypeOfApproval]
		WHEN 'A' THEN 'Application'
		WHEN 'N' THEN 'None'
	   END [Type Of Approval]
      ,[NoOfRequests]
  FROM [Shopping2].[dbo].[tb_Application]
  WHERE Enabled = 1
  ORDER BY NoOfRequests DESC