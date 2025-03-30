--Make sure you either use the “WITH(NOLOCK)” part of the query and/or make sure you always close your SSMS query window after issuing the query.    
--Queries on the msdb database can hold locks that end up causing problems for all of the databases on that SQL Server if you don’t use “WITH(NOLOCK)”.
--If the backups are running, you should get results that look something like this.   (The full backups, type = “D”, should run once a day around 8PM-9PM.   
--The Transaction Log backups, type = “L”, should run once an hour.)

USE msdb
SELECT server_name, machine_name, database_name, name, user_name, backup_start_date, backup_finish_date, type, backup_size, compressed_backup_size
FROM backupset WITH(NOLOCK)
ORDER BY database_name, backup_start_date