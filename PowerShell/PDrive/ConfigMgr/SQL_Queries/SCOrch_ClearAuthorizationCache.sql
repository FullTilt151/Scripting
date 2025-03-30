-- Check maintenance tasks
SELECT * FROM [Microsoft.SystemCenter.Orchestrator.Maintenance].MaintenanceTasks

-- Run maintenance tasks
EXEC [Microsoft.SystemCenter.Orchestrator.Maintenance].EnqueueRecurrentTask 'Authorization'
EXEC [Microsoft.SystemCenter.Orchestrator.Maintenance].EnqueueRecurrentTask 'Statistics'
EXEC [Microsoft.SystemCenter.Orchestrator.Maintenance].EnqueueRecurrentTask 'ClearAuthorizationCache'

-- Clear authorization cache
TRUNCATE TABLE [Microsoft.SystemCenter.Orchestrator.Internal].AuthorizationCache

-- Check for SQL Broker
SELECT is_broker_enabled FROM sys.databases WHERE name = 'Orchestrator'

-- Fix SQL Broker
/*
ALTER DATABASE Orchestrator SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE Orchestrator SET ENABLE_BROKER WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE Orchestrator SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO
*/