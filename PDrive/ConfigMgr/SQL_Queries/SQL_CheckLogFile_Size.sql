--Will show the Log Size and % used
DBCC SQLPERF(LOGSPACE)

--Do not run the following commands in Prod.  Will cause issues with Rubrik
--BACKUP LOG cm_wq1 to disk ='J:\MSSQL14.MSSQLSERVER\MSSQL\Backup\CM_WQ1\CM_WQ1_Log_Backup.trn'
--BACKUP LOG PFE_Client_Health to disk ='J:\MSSQL14.MSSQLSERVER\MSSQL\Backup\CM_WQ1\PFE_Log_Backup.trn'


