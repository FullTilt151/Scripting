--https://1eportal.force.com/s/article/KB000002375

IF OBJECT_ID( 'tempdb..#tblDeviceList' ) IS NOT NULL DROP TABLE #tblDeviceList;
Go
IF OBJECT_ID('tempdb..#TotalMachines') IS NOT NULL DROP TABLE #TotalMachines
Go

-- define the age of devices we'd like to purge

DECLARE @AgedDays INT
SET @AgedDays = -180 --<Please provide the aging days number such as -90 or -180 or -210 etc as per your clean-up age days. This is the difference between the last hw scan date of the device and today's date. Make sure this value is in negative. Devices/Devices data would be cleaned up as per the aged days limit from the last hw scan date for a device>
DECLARE @Recordcount INT

PRINT 'Total Number of Machines Found: ' 
Select t.smio_MachineGroup, t.smio_MachineName, t.smio_id, t.smio_UniqueGuid, t.smio_LastHW_ScanDate, CASE WHEN smio_inactivity_date_utc IS NOT NULL THEN 0
WHEN smio_inactivity_date_utc IS NULL THEN 1
END AS IsActive
into #TotalMachines
from (
Select smio_MachineGroup, smio_MachineName,smio_inactivity_date_utc, smio_id, smio_UniqueGuid,smio_LastHW_ScanDate,ROW_NUMBER() over (partition by smio_MachineGroup, smio_MachineName order by smio_LastSyncDate_utc desc ) as Rn
from SiteMachineInfo ) t
Where t.Rn=1

PRINT 'Number of Machines where Data will be deleted: ' 
SELECT smio_id, smio_UniqueGuid 
INTO #tblDeviceList
FROM #TotalMachines 
WHERE IsActive = 0 AND smio_LastHW_ScanDate < DATEADD(dd,@AgedDays, GETDATE())


--ApplicationInstMachineInactive
BEGIN

    SELECT @Recordcount=COUNT(1) from  ApplicationInstMachineInactive
    PRINT 'ApplicationInstMachineInactive Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM ApplicationInstMachineInactive d
           INNER JOIN #tblDeviceList dl on 
           d.usim_aim_machine_guid=dl.smio_UniqueGuid

    SELECT @Recordcount=COUNT(1) from  ApplicationInstMachineInactive
    PRINT 'ApplicationInstMachineInactive After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END

SET @Recordcount=NULL

--ApplicationInstMachine
BEGIN

    SELECT @Recordcount=COUNT(1) from  ApplicationInstMachine
    PRINT 'ApplicationInstMachine Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM ApplicationInstMachine d
           INNER JOIN #tblDeviceList dl on 
           d.aim_machine_guid=dl.smio_UniqueGuid

    SELECT @Recordcount=COUNT(1) from  ApplicationInstMachine
    PRINT 'ApplicationInstMachine After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END


--ApplicationUsageMachine
SET @Recordcount=NULL

BEGIN

    SELECT @Recordcount=COUNT(1) from  ApplicationUsageMachine
    PRINT 'ApplicationUsageMachine Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM ApplicationUsageMachine d
           INNER JOIN #tblDeviceList dl on 
           d.aum_machine_id=dl.smio_UniqueGuid

    SELECT @Recordcount=COUNT(1) from  ApplicationUsageMachine
    PRINT 'ApplicationUsageMachine After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END

--DeviceTagMapping
SET @Recordcount=NULL

BEGIN

    SELECT @Recordcount=COUNT(1) from  DeviceTagMapping
    PRINT 'DeviceTagMapping Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM DeviceTagMapping d
           INNER JOIN #tblDeviceList dl on 
           d.dtm_dev_source_external_id=dl.smio_UniqueGuid

    SELECT @Recordcount=COUNT(1) from  DeviceTagMapping
    PRINT 'DeviceTagMapping After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END


--MachineImportConnector
SET @Recordcount=NULL

BEGIN

    SELECT @Recordcount=COUNT(1) from MachineImportConnector
    PRINT 'MachineImportConnector Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM MachineImportConnector d
           INNER JOIN #tblDeviceList dl on 
           d.usic_smio_id=dl.smio_id

    SELECT @Recordcount=COUNT(1) from  MachineImportConnector
    PRINT 'MachineImportConnector After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END

--InstallationImportConnector
SET @Recordcount=NULL

BEGIN

    SELECT @Recordcount=COUNT(1) from InstallationImportConnector
    PRINT 'InstallationImportConnector Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM InstallationImportConnector d
           INNER JOIN #tblDeviceList dl on 
           d.iic_smio_id=dl.smio_id

    SELECT @Recordcount=COUNT(1) from  InstallationImportConnector
    PRINT 'InstallationImportConnector After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END

--MachinePolicyHistory
SET @Recordcount=NULL
BEGIN
    select  @Recordcount = count(d.mpch_id) FROM MachinePolicyHistory d
           INNER JOIN #tblDeviceList dl on 
           d.mpch_smio_id=dl.smio_id

    PRINT 'MachinePolicyHistory Not deleting to save historic Savings Data: ' +CAST(@Recordcount as varchar(100))
END
/*
BEGIN

    SELECT @Recordcount=COUNT(1) from  MachinePolicyHistory
    PRINT 'MachinePolicyHistory Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM MachinePolicyHistory d
           INNER JOIN #tblDeviceList dl on 
           d.mpch_smio_id=dl.smio_id

    SELECT @Recordcount=COUNT(1) from  MachinePolicyHistory
    PRINT 'MachinePolicyHistory After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END

*/




--MachineIPAddress
SET @Recordcount=NULL

BEGIN

    SELECT @Recordcount=COUNT(1) from  MachineIPAddress
    PRINT 'MachineIPAddress Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM MachineIPAddress d
           INNER JOIN #tblDeviceList dl on 
           d.smip_smio_id=dl.smio_id

    SELECT @Recordcount=COUNT(1) from  MachineIPAddress
    PRINT 'MachineIPAddress After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END

--MachineOU
SET @Recordcount=NULL

BEGIN

    SELECT @Recordcount=COUNT(1) from  MachineOU
    PRINT 'MachineOU Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM MachineOU d
           INNER JOIN #tblDeviceList dl on 
           d.smou_smio_id=dl.smio_id

    SELECT @Recordcount=COUNT(1) from  MachineOU
    PRINT 'MachineOU After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END

--MachineIPSubnet
SET @Recordcount=NULL

BEGIN

    SELECT @Recordcount=COUNT(1) from  MachineIPSubnet
    PRINT 'MachineIPSubnet Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM MachineIPSubnet d
           INNER JOIN #tblDeviceList dl on 
           d.smis_smio_id=dl.smio_id

    SELECT @Recordcount=COUNT(1) from  MachineIPSubnet
    PRINT 'MachineIPSubnet After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END


--MachineHasUsageDate
SET @Recordcount=NULL
BEGIN

    SELECT @Recordcount=COUNT(1) from  MachineHasUsageDate
    PRINT 'MachineHasUsageDate Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM MachineHasUsageDate d
           INNER JOIN #tblDeviceList dl on 
           d.mhu_smio_id=dl.smio_id

    SELECT @Recordcount=COUNT(1) from  MachineHasUsageDate
    PRINT 'MachineHasUsageDate After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END


--ProductOptOutInfo
SET @Recordcount=NULL
BEGIN

    SELECT @Recordcount=COUNT(1) from  ProductOptOutInfo
    PRINT 'ProductOptOutInfo Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM ProductOptOutInfo d
           INNER JOIN #tblDeviceList dl on 
           d.pooi_smio_id=dl.smio_id

    SELECT @Recordcount=COUNT(1) from  ProductOptOutInfo
    PRINT 'ProductOptOutInfo After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END

--SiteMachineInfo
SET @Recordcount=NULL
BEGiN
select @Recordcount =  count(d.smio_id) FROM SiteMachineInfo d
           INNER JOIN #tblDeviceList dl on 
           d.smio_UniqueGuid=dl.smio_UniqueGuid

PRINT 'SiteMachineInfo Not deleting to save historic Savings Data: ' +CAST(@Recordcount as varchar(100))
END
/*
BEGIN

    SELECT @Recordcount=COUNT(1) from  SiteMachineInfo
    PRINT 'SiteMachineInfo Before Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

    DELETE d FROM SiteMachineInfo d
           INNER JOIN #tblDeviceList dl on 
           d.smio_UniqueGuid=dl.smio_UniqueGuid

    SELECT @Recordcount=COUNT(1) from  SiteMachineInfo
    PRINT 'SiteMachineInfo After Deletion Record Count: ' +CAST(@Recordcount as varchar(100))

END
*/
-- Shrink the log file for unused space  

DECLARE @logFilenme varchar (1000)
DECLARE @targetLogSize INT

SELECT @logFilenme = name from sys.database_files WHERE type_desc='LOG'

SELECT @targetLogSize = ((size/128.0)-(size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0))

FROM sys.database_files where name=@logFilenme; 

--SELECT @targetLogSize

DBCC SHRINKFILE (@logFilenme, @targetLogSize);
GO