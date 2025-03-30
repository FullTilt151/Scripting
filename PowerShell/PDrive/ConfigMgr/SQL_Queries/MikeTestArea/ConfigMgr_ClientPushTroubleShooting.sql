-- List of machines with certain CP errors
select datediff(HH,InitialRequestDate,getdate()) [Hours], *
from v_CP_Machine
where LastErrorCode in ('-2147023071','5','1003')
and datediff(HH,InitialRequestDate,getdate()) <= 24
order by InitialRequestDate DESC


select *
from v_CP_Machine
where name = 'LOUWEBWQL206S02'

select *
from ClientDeploymentSettings

DECLARE @PackageID varchar(8) = (select UpgradePackageID from ClientDeploymentSettings)
DECLARE @AdvertisementID varchar(8) = (select UpgradeAdvertisementID from ClientDeploymentSettings)
select * from vSMS_AdvertisementInfoEx where AdvertisementID = @AdvertisementID
select * from v_Package WHERE PackageID = @PackageID
select * from v_Program WHERE PackageID = @PackageID




-- List of non-clients and CP status
select Name, LatestProcessingAttempt, LastErrorCode, Description, NumProcessAttempts, Status
from v_CP_Machine
where machineid not in (select resourceid from v_r_system_valid)
order by lasterrorcode, name

-- Count of all status last 3 days
select LastErrorCode, count(*) [Count]
from v_CP_Machine
where datediff(HH,InitialRequestDate,getdate()) <= 30
group by LastErrorCode
order by LastErrorCode

-- List of CP details
select cpg.Name, sys.Client_Version0, cpg.Forced, cpg.ForceReinstall, cpg.InitialRequestDate, cpg.Status, cpg.LatestProcessingAttempt, cpg.LastErrorCode, cpg.NumProcessAttempts
from ClientPushMachine_G CPG join
	 v_r_system sys on cpg.MachineID = sys.ResourceID
order by InitialRequestDate desc

select *
from ClientPushMachine_G
order by InitialRequestDate desc

/*
https://www.systemcenterdudes.com/sccm-client-installation-error-codes/

-- Status
0        Not started
1        Started
2        Retry
3        Skipped
4        Complete
5        Failed

-- Errors
-2147024891 - Access denied
-2147023174 - RPC server unavailable
-2147023071 - A security package specific error has occured
5 - Access denied
8 - Not enough storage is available to process this command
21 - Device is not ready
53 - Unable to connect to admin$
64 - Network name no longer available
67 - Network name cannot be found
112 - Low disk space
120 - Client already installed (force install not checked)
1003 - Cannot complete this function
1326 - Login failure
1396 - Target account name is incorrect (duplicate DNS)
1789 - Trust relationship failed
*/