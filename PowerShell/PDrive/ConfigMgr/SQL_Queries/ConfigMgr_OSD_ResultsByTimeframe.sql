-- List of task sequences with advertisements
Select distinct pkg.PackageID, Name + ' (' + pkg.PackageID + ')' [Name]
from v_Advertisement adv inner join
	 v_Package pkg on adv.PackageID = pkg.PackageID
where PackageType = 4
order by [Name]

-- Task sequence adverts
DECLARE @PkgId nvarchar(8)
Set @PkgId = 'WP100575'

DECLARE @Days int
Set @Days = '6'

DECLARE @AdvIDs table (AdvID nvarchar(8))
insert into @AdvIDs
select AdvertisementID from v_Advertisement where PackageID = @PkgID and AssignedScheduleEnabled != 0

-- Task sequence results
select sys.name, advertisementid, sys.IsVirtualMachine [VM], LastStateName, LastStatusMessageIDName, LastStatusTime, DATEDIFF(hh,LastStatusTime, GetDate()) --, count(*)
from v_ClientAdvertisementStatus cas inner join
	 vSMS_CombinedDeviceResources sys on cas.ResourceID = sys.MachineID
where AdvertisementID in (Select AdvertisementID from @AdvIDs) and
	  LastStatusMessageIDName != 'Program received - no further status' and 
	  DATEDIFF(hh,LastStatusTime, GetDate()) < @Days
--group by sys.isvirtualMachine, LastStatusMessageIDName, LastStateName
order by [VM], LastStatusMessageIDName, LastStateName