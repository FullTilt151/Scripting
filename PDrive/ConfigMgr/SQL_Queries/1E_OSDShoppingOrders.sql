-- OSD Shopping batch jobs
select batch.id, batch.OsdBatchName, usr.FullName, batch.RequestedTimestamp, batch.ScheduledMigrationTimestamp
from tb_OsdBatch batch join
	 tb_User usr on batch.UserId = usr.UserId
order by batch.RequestedTimestamp desc

-- All ZTI batch jobs
select batch.OsdBatchName [Job Name], DATEADD(HOUR,-5,zti.ScheduledMigrationDateTime) [Scheduled Date], zti.Id, wkid.MachineName [WKID], wkid.IPAddress [IP], usr.FullName [Scheduled by], zti.DateCreated [Create Date]
from tb_OsdWizard ZTI join
	 tb_Machine wkid on zti.MachineId = wkid.MachineId join
	 tb_User usr on zti.UserId = usr.UserId join
	 tb_OsdBatch batch on zti.OsdBatchId = batch.Id
order by ScheduledMigrationDateTime desc

-- OSD Shopping all jobs
select osd.MachineID, MachineName
from tb_OsdWizard OSD join 
	 tb_machine WKID on osd.MachineId = wkid.MachineId


-- Delete OSD Shopping self-service job
/*
delete
from tb_osdwizard
<<<<<<< HEAD:PDrive/ConfigMgr/SQL_Queries/1E_OSDShoppingOrders.sql
where ScheduledMigrationDateTime < '2019-04-01 00:00:00.000'
=======
where ScheduledMigrationDateTime < '2019-04-25 00:00:00.000'
>>>>>>> 3319f6cd08befe5e13509333dd841128a8f9b36f:PDrive/ConfigMgr/SQL_Queries/1E_OSDShoppingOrders.sql
/*
where MachineId in (
select osd.MachineID
from tb_OsdWizard OSD join 
	 tb_machine WKID on osd.MachineId = wkid.MachineId
where MachineName in ('WKMJ003JP8'))
*/
*/

-- OSD Shopping self-service jobs
select osd.id, osd.DateCreated, osd.DateModified, app.DisplayName, UPPER(wkid.MachineName) [WKID], 
		case OSVersion
		WHEN '6.1.7601' THEN 'Win7'
		WHEN '10.0.10586' THEN 'Win10 1511'
		WHEN '10.0.14393' THEN 'Win10 1607'
		WHEN '10.0.15063' THEN 'Win10 1703'
		WHEN '10.0.16299' THEN 'Win10 1709'
		WHEN '10.0.17134' THEN 'Win10 1803'
		end [OS], wkid.IPAddress, usr.FullName, usr.UserAccount, usr.UserEmail, osd.IsScheduledImmediately, osd.ScheduledMigrationDateTime, osd.Status, 
	   osd.LastCompletedStep, osd.HasConfirmedBackup, osd.CompletedMigrationDateTime
from tb_OsdWizard osd join
	 tb_User usr on osd.UserId = usr.UserId join
	 tb_Machine wkid on osd.MachineId = wkid.MachineId join
	 tb_Application app on osd.RequestItemId = app.ApplicationId
where ScheduledMigrationDateTime < '2019-04-01 00:00:00.000'
--where osd.Status in ( @Status ) and 
/*where wkid.MachineName in (
'WKPC0MTJ5S'
)
*/
order by osd.DateModified desc