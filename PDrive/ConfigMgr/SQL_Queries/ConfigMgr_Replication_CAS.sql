spDiagDRS
spDiagGetSpaceUsed

-- Find bad table
select * from RCM_ReplicationLinkStatus where SnapshotApplied <>1
--update RCM_ReplicationLinkStatus set SnapshotApplied = 1 where SnapshotApplied <>1

select * from RCM_DrsInitializationTracking where initializationstatus not in (6,7)
select * from RCM_DrsInitializationTracking where initializationstatus = 6
--update RCM_DrsInitializationTracking set initializationstatus = 6 
--update RCM_DrsInitializationTracking set InitializationStatus = 6 where Replicationgroup in (select ReplicationGroup from vReplicationData where ReplicationPattern = 'CM_CAS') and SiteRequesting = 'SDC' and InitializationPercent <> 100 and InitializationPercent <> 0
--update RCM_DrsInitializationTracking set InitializationStatus = 6 where RequestTrackingGUID = '8A9CDD77-7F6D-413C-B537-DB55B511CDC3'
--update RCM_DrsInitializationtracking set initializationstatus = 7 where RequestTrackingGUID='FA422F60-792F-4CAB-B8B6-F49744B1C982'
--update RCM_DrsInitializationTracking set initializationstatus = 6 where replicationgroup='Configuration Data' and requesttrackingguid like '%CDCED819-0CD7-499D-A608-9F6A3AAE7E18%'
/*
update RCM_DrsInitializationTracking set InitializationStatus = 7 where ReplicationGroup in 
	(select replicationgroup from vReplicationData where ID in (select ReplicationID from RCM_ReplicationLinkStatus where SnapshotApplied <>1)) 
	 and InitializationPercent not in (0,100)

update rcm_drsinitializationtracking set InitializationStatus = 7 where replicationgroup in
(select replicationgroup from vReplicationData where replicationpattern ='global') and SiteRequesting = 'SDC' 
*/

--Hardware_Inventory_35 = 66
-- Find ID and tables included
DECLARE @ReplicationGroup VARCHAR(255) 
SET @ReplicationGroup = 'Hardware_Inventory' 
SELECT * 
FROM   articledata 
WHERE  replicationid IN (SELECT id 
		                 FROM   replicationdata 
                         WHERE  replicationgroup = @ReplicationGroup)

--View tables in bad table
DECLARE @ReplicationGroup VARCHAR(255) 
SET @ReplicationGroup = 'Hardware_Inventory_35'
select * from ArticleData where ReplicationID = (SELECT id 
		                 FROM   replicationdata 
                         WHERE  replicationgroup = @ReplicationGroup) 

-- Delete bad table data
DECLARE @ReplicationGroup VARCHAR(255) 
SET @ReplicationGroup = 'Hardware_Inventory_35'
select * from replicationdata where ID = (SELECT id 
		                 FROM   replicationdata 
                         WHERE  replicationgroup = @ReplicationGroup) 
/*
DECLARE @ReplicationGroup VARCHAR(255) 
SET @ReplicationGroup = 'Hardware_Inventory_35'
delete from ReplicationData where ID = (SELECT id 
		                 FROM   replicationdata 
                         WHERE  replicationgroup = @ReplicationGroup) 
*/
-- Force site to ACTIVE
select * from ServerData
--update serverdata set SiteStatus = 125 where ID=0
--Update ServerData Set SiteStatus = 120 where sitecode = 'sdc'

select * from sys.transmission_queue
select * from RCM_ExpansionTracking

-- SSB_DialogPool
select * From SSB_DialogPool order by CreationTime desc
select * From SSB_DialogPool where ToService like '%CAS'
Select * from SSB_DialogPool where ToService like '%ConfigMgrRCM_SiteSDC'
--Delete  from SSB_DialogPool where ToService like '%ConfigMgrRCM_SiteSDC'

-- Replication status
Select * From vReplicationData
select * from vReplicationData where Replicationpattern = 'global'

-- vLogs
Select top 1000 * from vLogs order by LogTime desc
select * from  Vlogs where logtext not like '%not sending changes%' and logtext not like '%no changes detected%' order by Logtime desc
select * from  Vlogs where logtext like '%sdc%' order by LogTime desc

select ArticleName from ArticleData where ReplicationID = (select ID from vReplicationData where ReplicationGroup = 'Configuration Data')
 
-- Change tracking versions
select OBJECT_NAME(OBJECT_ID) [ObjectName], * 
from sys.change_tracking_tables 
where OBJECT_NAME(OBJECT_ID) like '%smspackages%'

-- Transmissions
select transmission_status,* from sys.transmission_queue
/*
declare @conversation uniqueidentifier
      while exists (select 1 from sys.transmission_queue )
        begin
          set @conversation = (select top 1 conversation_handle from sys.transmission_queue )
          end conversation @conversation with cleanup
        end
*/

-- Misc
select name,internal_type_desc,* from sys.internal_tables where name like '%100195407%'

select * from RCM_InitPackageRequest order by LastModifyTime desc

select * from dbo.ConfigMgrRCMQueue order by message_enqueue_time desc
select * from dbo.ConfigMgrRCMQueue order by queuing_order desc

select * from sys.dm_tran_commit_table
select * from TableChangeNotifications
select * from RCM_RecoveryTracking