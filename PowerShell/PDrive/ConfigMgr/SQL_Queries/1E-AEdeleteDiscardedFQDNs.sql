IF OBJECT_ID( 'tempdb..#tblDeviceList' ) IS NOT NULL DROP TABLE #tblDeviceList;
IF OBJECT_ID( 'tempdb..#tblList' ) IS NOT NULL DROP TABLE #tblList;

WITH Data AS (
SELECT 
   Id
    from Devices d
    where fqdn like 'discarded%'
)
SELECT *
into #tblDeviceList
FROM
   Data
;

--setup a table to hold our devicelist to purge
CREATE  TABLE #tblList(
       ID uniqueidentifier
);

--grab all device ids
INSERT INTO #tblList (ID) 
Select TOP 100000 Id from  #tblDeviceList 

-- purge DeviceSystemProperties
BEGIN
       DELETE d FROM DeviceSystemProperties d
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging DeviceIdentities
BEGIN
       DELETE d from DeviceIdentities d
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

--purging AdapterConfigurations
BEGIN
       DELETE d from AdapterConfigurations d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging ContentDeliveries
BEGIN
       DELETE d from ContentDeliveries d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END 

--purging ApplicationUsage
BEGIN
       DELETE d from ApplicationUsage d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

--purging ApplicationUsageOverride
BEGIN
       DELETE d from ApplicationUsageOverride d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END 

-- purging DeviceTags
BEGIN
       DELETE d from  DeviceTags d
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END 

--purging Installations
BEGIN
       DELETE d from Installations d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging OracleUsage
BEGIN
       DELETE d from  OracleUsage d
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging SqlUsage
BEGIN
       DELETE d from SqlUsage d 
       INNER JOIN #tblList dl on 
       d.DeviceId=dl.ID
END

-- purging devices
BEGIN
       DELETE d from  Devices d
       INNER JOIN #tblList dl on 
       d.Id=dl.ID
END
