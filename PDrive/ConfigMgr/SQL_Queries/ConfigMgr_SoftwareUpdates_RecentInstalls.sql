-- Patch deployments to a WKID
SELECT DISTINCT cia.AssignmentName AS DeploymentName, cia.CollectionName, cia.CollectionID, col.MemberCount,
				cia.StartTime AS Available, cia.EnforcementDeadline AS Deadline
FROM            v_CIAssignmentTargetedMachines AS atm INNER JOIN
                         v_CIAssignment AS cia ON atm.AssignmentID = cia.AssignmentID inner join
						 v_collection COL ON cia.CollectionID = col.CollectionID inner join
						 v_r_system SYS ON atm.ResourceID = sys.ResourceID
WHERE        (sys.Netbios_Name0 = 'WKMJ029cw9') AND (cia.AssignmentType IN (1, 5))
ORDER BY Deadline DESC

-- Failed patch installs to a WKID
select sys.Netbios_Name0 [Machine], ui.BulletinID, ui.ArticleID, ui.Title, 
	   case csa.status
	   when '0' then 'Unknown'
	   when '1' then 'Not Required'
	   when '2' then 'Required'
	   when '3' then 'Installed'
	   end [Status], 
	   csa.LastLocalChangeTime,  
	   csa.EnforcementSource, 
	   case csa.LastEnforcementMessageID
	   when '0' then 'Unknown'
	   when '1' then 'Started'
	   when '2' then 'Waiting for content'
	   when '3' then 'Waiting for another installation to complete'
	   when '4' then 'Waiting for Maintenance Window'
	   when '5' then 'Restart required before installing'
	   when '6' then 'General failure'
	   when '7' then 'Pending Installation'
	   when '8' then 'Installing Update'
	   when '9' then 'Pending system restart'
	   when '10' then 'Successfully installed update'
	   when '11' then 'Failed to install update'
	   when '12' then 'Downloading update'
	   when '13' then 'Downloaded update'
	   when '14' then 'Failed to download update'
	   end [EnforcementMessageID], 
	   csa.LastEnforcementMessageTime, csa.LastEnforcementStatusMsgID, csa.LastErrorCode
from v_r_system SYS join
	 v_update_compliancestatusall CSA on sys.resourceid = csa.resourceid join
	 v_updateinfo UI on csa.CI_ID = ui.CI_ID
where sys.Netbios_Name0 = @WKID and
      status != '3' and
	  LastEnforcementMessageTime IS NOT NULL
order by LastEnforcementMessageTime DESC, LastLocalChangeTime DESC

-- Patch installs to a WKID
select netbios_name0 [WKID], qfe.HotFixID0 [ArticleID], QFE.Description0 [Classification], qfe.InstalledBy0 [Installed By], usr.Full_User_Name0 [Friendly Name], qfe.InstalledOn0 [Install Date]
from v_GS_QUICK_FIX_ENGINEERING QFE left join
	 v_r_system SYS on QFE.resourceid = SYS.resourceid left join
	 v_r_user USR ON qfe.installedby0 = usr.Unique_User_Name0
where Netbios_Name0 = 'wkmj029cw9'
order by convert(datetime, InstalledOn0) DESC