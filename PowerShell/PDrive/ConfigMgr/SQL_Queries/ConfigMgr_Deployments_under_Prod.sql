-- #### All DSI Prod deployments ####
DECLARE @ObjectTypes TABLE (
   ObjectType INT PRIMARY KEY,
   TypeDescription VARCHAR(46));

   INSERT INTO @ObjectTypes (ObjectType,TypeDescription) 
VALUES
   (2,'Package'),
   (3,'Advertisement'),
   (7,'Query'),
   (8,'Report'),
   (9,'MeteredProductRule'),
   (11,'ConfigurationItem'),
   (14,'OperatingSystemInstallPackage'),
   (17,'StateMigration'),
   (18,'ImagePackage'),
   (19,'BootImagePackage'),
   (20,'TaskSequencePackage'),
   (21,'DeviceSettingPackage'),
   (23,'DriverPackage'),
   (25,'Driver'),
   (1011,'SoftwareUpdate'),
   (2011,'ConfigurationBaseline'),
   (5000,'Device Collection'),
   (5001,'User Collection'),
   (6000,'Application'),
   (6001,'ConfigurationItem');
WITH fldr AS (
   --top level folders (anchor)
   SELECT CAST('\'+f.Name AS VARCHAR(512)) AS Folder, f.ContainerNodeID AS ID, f.ParentContainerNodeID AS ParentID, ot.ObjectType, ot.TypeDescription
   FROM dbo.vSMS_Folders f JOIN 
        @ObjectTypes ot ON f.ObjectType = ot.ObjectType
   WHERE f.ParentContainerNodeID = 0
   UNION ALL
   --child folders (recursive)
   SELECT CAST(Parent.Folder+'\'+Child.Name AS VARCHAR(512)) AS Folder, Child.ContainerNodeID AS ID, Child.ParentContainerNodeID AS ParentID, 
		  ot.ObjectType, ot.TypeDescription
   FROM dbo.vSMS_Folders Child JOIN 
	    @ObjectTypes ot ON Child.ObjectType = ot.ObjectType JOIN 
		fldr AS Parent ON Child.ParentContainerNodeID = Parent.ID AND 
		Child.ObjectType = Parent.ObjectType)

select distinct ADV.AdvertisementID, AdvertisementName, 
	   case adv.AssignedScheduleEnabled 
	   when 0 then 'Pull (Available)'
	   when 16 then 'Push (Required)'
	   end as [Type],
	   cas.LastAcceptanceStatusTime,
	   adv.PackageID, ProgramName [Program], pkg.Manufacturer + ' ' + pkg.Name + ' ' + pkg.Version [Package], pkg.PkgSourcePath [Source Path], adv.CollectionID, coll.Name [Collection Name], cos.Targeted
from v_advertisement ADV join
	 v_Collection COLL ON adv.collectionid = coll.collectionid join
	 v_ClientOfferSummary COS ON adv.AdvertisementID = cos.OfferID join
	 vFolderMembers FOLD ON adv.CollectionID = fold.InstanceKey join
	 v_Package PKG on adv.PackageID = pkg.PackageID join
	 v_ClientAdvertisementStatus CAS ON ADV.AdvertisementID = CAS.AdvertisementID
where --AssignedScheduleEnabled != 0 and 
	  --(AdvertFlags & 0x720) != 0 and 
	  pkg.PackageType = 0 and
	  ADV.CollectionID in (
	  select InstanceKey [CollectionID]
	  from vFolderMembers
	  where ObjectType = '5000' and
	  ContainerNodeID in (
	    SELECT ID
		FROM fldr
		where ObjectType = '5000' and 
	    Folder like '\Prod%')
	  ) and
	  cas.LastAcceptanceStatusTime in 
	  (select max(lastacceptancestatustime)
		from v_ClientAdvertisementStatus
		group by AdvertisementID)
group by ADV.AdvertisementID, AdvertisementName, 
	   case adv.AssignedScheduleEnabled 
	   when 0 then 'Pull (Available)'
	   when 16 then 'Push (Required)'
	   end,
	   cas.LastAcceptanceStatusTime,
	   adv.PackageID, ProgramName, pkg.Manufacturer + ' ' + pkg.Name + ' ' + pkg.Version, 
	   pkg.PkgSourcePath, adv.CollectionID, coll.Name, cos.Targeted
order by Targeted DESC

/*
-- #### Test queries ####
select *
from vSMS_Folders 

DECLARE @ObjectTypes TABLE (
   ObjectType INT PRIMARY KEY,
   TypeDescription VARCHAR(46));

   INSERT INTO @ObjectTypes (ObjectType,TypeDescription) 
VALUES
   (2,'Package'),
   (3,'Advertisement'),
   (7,'Query'),
   (8,'Report'),
   (9,'MeteredProductRule'),
   (11,'ConfigurationItem'),
   (14,'OperatingSystemInstallPackage'),
   (17,'StateMigration'),
   (18,'ImagePackage'),
   (19,'BootImagePackage'),
   (20,'TaskSequencePackage'),
   (21,'DeviceSettingPackage'),
   (23,'DriverPackage'),
   (25,'Driver'),
   (1011,'SoftwareUpdate'),
   (2011,'ConfigurationBaseline'),
   (5000,'Device Collection'),
   (5001,'User Collection'),
   (6000,'Application'),
   (6001,'ConfigurationItem');
WITH fldr AS (
   --top level folders (anchor)
   SELECT CAST('\'+f.Name AS VARCHAR(512)) AS Folder, f.ContainerNodeID AS ID, f.ParentContainerNodeID AS ParentID, ot.ObjectType, ot.TypeDescription
   FROM dbo.vSMS_Folders f JOIN 
        @ObjectTypes ot ON f.ObjectType = ot.ObjectType
   WHERE f.ParentContainerNodeID = 0
   UNION ALL
   --child folders (recursive)
   SELECT CAST(Parent.Folder+'\'+Child.Name AS VARCHAR(512)) AS Folder, Child.ContainerNodeID AS ID, Child.ParentContainerNodeID AS ParentID, 
		  ot.ObjectType, ot.TypeDescription
   FROM dbo.vSMS_Folders Child JOIN 
	    @ObjectTypes ot ON Child.ObjectType = ot.ObjectType JOIN 
		fldr AS Parent ON Child.ParentContainerNodeID = Parent.ID AND 
		Child.ObjectType = Parent.ObjectType)

select InstanceKey [CollectionID]
from vFolderMembers
where ObjectType = '5000' and
	  ContainerNodeID in (
	    SELECT ID
		FROM fldr
		where ObjectType = '5000' and 
	    Folder like '\Prod%')

-- #### All recursive folders ####

DECLARE @ObjectTypes TABLE (
   ObjectType INT PRIMARY KEY,
   TypeDescription VARCHAR(46)
);
INSERT INTO @ObjectTypes (ObjectType,TypeDescription) 
VALUES
   (2,'Package'),
   (3,'Advertisement'),
   (7,'Query'),
   (8,'Report'),
   (9,'MeteredProductRule'),
   (11,'ConfigurationItem'),
   (14,'OperatingSystemInstallPackage'),
   (17,'StateMigration'),
   (18,'ImagePackage'),
   (19,'BootImagePackage'),
   (20,'TaskSequencePackage'),
   (21,'DeviceSettingPackage'),
   (23,'DriverPackage'),
   (25,'Driver'),
   (1011,'SoftwareUpdate'),
   (2011,'ConfigurationBaseline'),
   (5000,'Device Collection'),
   (5001,'User Collection'),
   (6000,'Application'),
   (6001,'ConfigurationItem');
WITH fldr AS (
   --top level folders (anchor)
   SELECT CAST('\'+f.Name AS VARCHAR(512)) AS Folder, f.ContainerNodeID AS ID, f.ParentContainerNodeID AS ParentID, ot.ObjectType, ot.TypeDescription
   FROM dbo.vSMS_Folders f JOIN 
        @ObjectTypes ot ON f.ObjectType = ot.ObjectType
   WHERE f.ParentContainerNodeID = 0
   UNION ALL
   --child folders (recursive)
   SELECT CAST(Parent.Folder+'\'+Child.Name AS VARCHAR(512)) AS Folder, Child.ContainerNodeID AS ID, Child.ParentContainerNodeID AS ParentID, 
		  ot.ObjectType, ot.TypeDescription
   FROM dbo.vSMS_Folders Child JOIN 
	    @ObjectTypes ot ON Child.ObjectType = ot.ObjectType JOIN 
		fldr AS Parent ON Child.ParentContainerNodeID = Parent.ID AND 
		Child.ObjectType = Parent.ObjectType
)
SELECT *
FROM fldr

*/