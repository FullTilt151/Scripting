/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [Id]
      ,[ProcessingId]
      ,[Retries]
      ,[DateTimeStamp]
      ,[From]
      ,[To]
      ,[Cc]
      ,[Subject]
      ,[Body]
      ,[Attachment]
  FROM [Shopping2].[dbo].[tb_EmailRetry]

/*Clear orphaned emails*/
  Delete from tb_EmailRetry 