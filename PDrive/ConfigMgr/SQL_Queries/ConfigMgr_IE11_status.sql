select sys.Netbios_Name0 [Name], ui.BulletinID, ui.ArticleID, ui.Title,
	   case ucs.Status
	   when 0 then 'Unknown'
	   when 1 then 'Not Required'
	   when 2 then 'Required'
	   when 3 then 'Installed'
	   end [Status], 
	   DATEADD(hour, -5, ucs.LastStatusCheckTime) [StatusTime EST],   
	   case ucs.LastEnforcementMessageID
	   when 0 then 'Unknown'
	   when 1 then 'Started'
	   when 2 then 'Waiting for content'
	   when 3 then 'Waiting for another install'
	   when 4 then 'Waiting for Maintenance Window'
	   when 5 then 'Restart required before install'
	   when 6 then 'General failure'
	   when 7 then 'Pending installation'
	   when 8 then 'Installing update'
	   when 9 then 'Pending system restart'
	   when 10 then 'Successfully installed'
	   when 11 then 'Failed install'
	   when 12 then 'Downloading update'
	   when 13 then 'Downloaded update'
	   when 14 then 'Failed to download update'
	   end [Enforcement], 
	   DATEADD(hour, -5, LastEnforcementMessageTime) [EnforcementTime EST], ucs.LastEnforcementStatusMsgID [EnforcementMsgID], ucs.LastErrorCode [Error]
from v_r_system SYS join
	 v_Update_ComplianceStatusAll UCS on sys.ResourceID = ucs.ResourceID join
	 v_UpdateInfo UI on UCS.CI_ID = ui.CI_ID
where sys.Netbios_Name0 = @WKID and
	  ucs.Status != 1 and
	  (ui.Title like '%IE11%' or ui.Title like '%Internet Explorer 11%')
order by ucs.LastStatusChangeTime desc

select sys.Netbios_Name0 [Name], DATEADD(hour,-5, uss.ScanTime) [ScanTime EST], dateadd(hour,-5,LastScanTime) [LastScanTime EST], LastScanPackageLocation [SUP], LastWUAVersion [WUA]
from v_R_System SYS join
v_UpdateScanStatus USS on sys.ResourceID = uss.ResourceID
where Netbios_Name0 = @WKID


select sys.netbios_name0 [Name], svcVersion0 [Version], ie.svcUpdateVersion0 [Patch Version], ie.svcKBNumber0 [Patch KB]
from v_R_System SYS join
	 v_gs_internetexplorer640 IE on sys.resourceid = ie.resourceid
where sys.Netbios_Name0 = @WKID