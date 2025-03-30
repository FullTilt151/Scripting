-- Builds by SMSTSRole and date
select osd.SMSTSRole0, count(*)
from v_r_system_valid sys join
	 v_gs_osd640 osd on sys.resourceid = osd.resourceid
where cast(ImageInstalled0 as datetime2) > '11/01/2018 00:00:00 AM' and ImageInstalled0 is not null and ImageInstalled0 != '%ImagedDate%' and SMSTSRole0 is not null
group by osd.SMSTSRole0
order by SMSTSRole0

-- List of WKIDs built by task sequence
select sys.netbios_name0 [WKID], osd64.DeployedBy0 [Tech], usr.Full_User_Name0 [Name], osd64.PXE0 [PXE box], osd64.TaskSequence0 [Task Sequence], osd64.SMSTSRole0 [Build], os.InstallDate0 [Build Time]
from v_r_system SYS join
	 v_gs_osd640 OSD64 ON sys.resourceid = osd64.resourceid join
	 v_GS_OPERATING_SYSTEM OS ON sys.resourceid = os.resourceid join
	 v_r_user USR on osd64.deployedby0 = usr.User_Name0
where osd64.TaskSequence0 = @TS
order by InstallDate0 desc

-- List of builds by tech
select sys.Netbios_Name0 [WKID], DeployedBy0 [Tech], TaskSequence0 [Task Sequence], SMSTSRole0 [Build], ImageName0 [Image], ImageRelease0 [Image Release], PXE0 [PXE], os.InstallDate0 [Build Date]
from v_r_system SYS join 
	 v_gs_osd640 OSD ON sys.ResourceID = osd.ResourceID join
	 v_GS_OPERATING_SYSTEM OS on sys.resourceid = os.resourceid
where deployedby0 like @Tech
order by os.InstallDate0 DESC

-- List of task sequences
select distinct TaskSequence0
from v_GS_OSD640
order by TaskSequence0