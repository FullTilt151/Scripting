-- Queries for clients
declare @ItemKey int set @ItemKey = '16812965'
declare @GUID nvarchar set @GUID = 'GUID:4499553B-5C1B-401F-8E9D-7CDBB47BC063'
declare @MachineName nvarchar set @MachineName = 'WKR90K3FQT'
declare @SID nvarchar set @SID = 'S-1-5-21-1275210071-879983540-1801674531-725837'
declare @HWID nvarchar set @HWID = '2:E69299F5AFA443396C6C755B749F60660BA19F4B'
declare @Cert nvarchar set @Cert = 'A019CE82EFA45912E99BB889041199A481229114'
declare @SMBGUID nvarchar set @SMBGUID = '5200390030004B003300460051005400'

select sys.Netbios_Name0, sys.client0, cs.*
from v_R_System sys left join v_CH_ClientSummary cs on sys.ResourceID = cs.ResourceID
where Netbios_Name0 = @MachineName

select itemkey, DiscArchKey, SMS_Unique_Identifier0, Netbios_Name0, Distinguished_Name0, Operating_System_Name_and0, AD_Site_Name0, client0,Active0,  
		Decommissioned0, Creation_Date0, SMS_UUID_Change_Date0, SMBIOS_GUID0, Hardware_ID0 
from system_disc where Netbios_Name0 = @MachineName

select * from System_DISC where Netbios_Name0 = @MachineName or ItemKey = @ItemKey or SID0 = @SID or SMS_Unique_Identifier0 = @GUID or SMBIOS_GUID0 = @GUID or Hardware_ID0 = @HWID
select * from MachineIdGroupXRef where GUID = @GUID
select * from ClientKeyData where SMSID = @GUID or Thumbprint = @Cert
select * from System_AUX_Info where ItemKey = @ItemKey or Hardware_ID0 = @HWID or Netbios_Name0 = @MachineName or SMBIOS_GUID0 = @SMBGUID

-- List of machines with duplicate decommissioned records COUNT
SELECT DISTINCT netbios_name0, Count (*) [Count] 
FROM   system_disc 
WHERE  netbios_name0 NOT IN (SELECT DISTINCT netbios_name0 
                             FROM   system_disc 
                             WHERE  decommissioned0 = 0) 
GROUP  BY netbios_name0 
HAVING Count(*) > 1 
ORDER  BY netbios_name0

-- List of machines with duplicate decommissioned records RAW
SELECT itemkey, DiscArchKey, SMS_Unique_Identifier0, Netbios_Name0, Distinguished_Name0, Operating_System_Name_and0, AD_Site_Name0, client0,Active0,  
		Decommissioned0, Creation_Date0, SMS_UUID_Change_Date0, SMBIOS_GUID0, Hardware_ID0 
FROM System_DISC
Where Netbios_Name0 in (
SELECT DISTINCT netbios_name0
FROM   system_disc 
WHERE  netbios_name0 NOT IN (SELECT DISTINCT netbios_name0 
                             FROM   system_disc 
                             WHERE  decommissioned0 = 0) 
GROUP  BY netbios_name0 
HAVING Count(*) > 1)
ORDER By Netbios_Name0

-- List of problem SMS Unique Identifiers
SELECT Distinct SMS_Unique_Identifier0
FROM System_DISC
Where SMS_Unique_Identifier0 is not null
and Netbios_Name0 in (
SELECT DISTINCT netbios_name0
FROM   system_disc 
WHERE  netbios_name0 NOT IN (SELECT DISTINCT netbios_name0 
                             FROM   system_disc 
                             WHERE  decommissioned0 = 0) 
GROUP  BY netbios_name0 
HAVING Count(*) > 1)

-- Remove corrupt registration data
/*
delete from ClientKeyData
where SMSID in (
'GUID:1f53dce3-5a07-4777-beac-74d2623a4e91'
)
*/