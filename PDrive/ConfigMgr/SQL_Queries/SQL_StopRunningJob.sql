USE msdb ;
GO
EXEC dbo.sp_stop_job '<name of job>' --example:'IndexOptimize - Custom' ;
GO