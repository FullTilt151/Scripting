-- Advert summary
select case 
                when LastState=0 then LastAcceptanceStateName 
                when LastState=-1 then LastAcceptanceStateName 
                else LastStateName 
                end as Status, 
       COUNT(*) as Count,  
       Advert.AdvertisementID, Advert.PackageName
from v_ClientAdvertisementStatus inner join
	dbo.v_AdvertisementInfo Advert on v_ClientAdvertisementStatus.AdvertisementID = Advert.AdvertisementID
where PackageName = 'Windows 10 - ZTI - Wipe and Load 1607' and DATEDIFF(hh,LastStatusTime, GetDate()) < 24
group by case 
                when LastState=0 then LastAcceptanceStateName 
                when LastState=-1 then LastAcceptanceStateName 
                else LastStateName 
                end, Advert.AdvertisementID, Advert.PackageName
order by advertisementid, packagename

-- Advert results
select SYS.Netbios_Name0, LastStateName, LastStatusMessageIDName, LastStatusMessageID, LastStatusTime, PackageName, CollectionName
from v_ClientAdvertisementStatus AdvStat inner join
	 v_AdvertisementInfo Adv ON AdvStat.AdvertisementID = Adv.AdvertisementID inner join
	 v_r_system SYS ON AdvStat.ResourceID = SYS.ResourceID
where Adv.AdvertisementID='WP121C82' and DATEDIFF(hh,LastStatusTime, GetDate()) < 24
order by LastStatusTime DESC

-- Advert list
select AdvertisementID, AdvertisementName + ' (' + AdvertisementID + ')' [Advertisement]
from v_Advertisement
where AdvertisementName like '%ZTI%'
order by Advertisement

-- List of WKIDs built by task sequence
select sys.netbios_name0 [WKID], osd64.DeployedBy0 [Tech], usr.Full_User_Name0 [Name], osd64.PXE0 [PXE box], osd64.TaskSequence0 [Task Sequence], osd64.SMSTSRole0 [Build], os.InstallDate0 [Build Time]
from v_r_system SYS join
	 v_gs_osd640 OSD64 ON sys.resourceid = osd64.resourceid join
	 v_GS_OPERATING_SYSTEM OS ON sys.resourceid = os.resourceid left join
	 v_r_user USR on osd64.deployedby0 = usr.User_Name0
where osd64.TaskSequence0 = 'Windows 10 - ZTI - Wipe and Load 1607'
order by InstallDate0 desc

-- OSD results adverts
select AdvertisementID, PKG.Name + ' to ' + coll.Name + ' (' + AdvertisementID + ')' [Advertisement], AdvertisementName
from v_Advertisement ADV FULL JOIN
	 v_Package PKG ON ADV.PackageID = PKG.PackageID join
	 v_Collection Coll on adv.CollectionID = coll.CollectionID
where (AdvertisementName like '%Windows7%' or AdvertisementName like '%Windows10%' or AdvertisementName like '%1EZTIStateCapture-%' or AdvertisementName like '%1EZTIWin7%' or AdvertisementName like '%server%') and PackageType = '4'
order by Advertisement

-- OSD results output
declare @Timeframe int
set @Timeframe = 24

declare @AdvertID nvarchar(1000)
set @AdvertID = 'WP121C6A'

select distinct SYS.Netbios_Name0, 
		case 
		when LastStatusMessageID = 11141 then 'Failed'
		when LastStatusMessageID = 11170 then 'Failed'
		when LastStatusMessageID = 11171 then 'Succeeded'
		when LastStatusMessageID = 11143 then 'Succeeded'
		else 'In progress'
		end [Status],
		LastStateName, LastStatusMessageIDName, LastStatusMessageID, DATEADD(HH,-5,LastStatusTime) LastStatusTime, CollectionName, PackageName,
		CASE 
		when Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 5.1' then 'Windows XP'
		when Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1' then 'Windows 7'
		when Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.1 (Tablet Edition)' then 'Windows 7'
		when Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.3' then 'Windows 8.1'
		when Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 6.3 (Tablet Edition)' then 'Windows 8.1'
		when Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 10.0' then 'Windows 10'
		when Operating_System_Name_and0 = 'Microsoft Windows NT Workstation 10.0 (Tablet Edition)' then 'Windows 10'
		end [OS]
from v_ClientAdvertisementStatus AdvStat full join
	 v_AdvertisementInfo Adv ON AdvStat.AdvertisementID = Adv.AdvertisementID full join
	 v_r_system SYS ON AdvStat.ResourceID = SYS.ResourceID
where Adv.AdvertisementID = @AdvertID and DATEDIFF(hh,LastStatusTime, GetDate()) < @Timeframe 
order by LastStatusTime DESC