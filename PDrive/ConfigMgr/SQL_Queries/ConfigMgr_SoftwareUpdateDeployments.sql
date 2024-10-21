SELECT DISTINCT cia.AssignmentID, cia.Assignment_UniqueID, cia.AssignmentName [Deployment], cia.CollectionID [CollectionID], cia.CollectionName [Collection], 
				CASE cia.SuppressReboot
				WHEN '0' THEN 'None'
				WHEN '1' THEN 'Workstations'
				WHEN '2' THEN 'Servers'
				WHEN '3' THEN 'Workstations and Servers'
				ELSE 'Unknown' 
				END AS 'SuppressReboot',
				cia.NotifyUser,  
				cia.OverrideServiceWindows, cia.RebootOutsideOfServiceWindows, 
				CASE cia.AssignmentType 
				WHEN 0 THEN 'Compliance' 
				WHEN 1 THEN 'Software Updates' 
				WHEN 2 THEN 'Application' 
				WHEN 5 THEN 'Software Update Group' 
				WHEN 8 THEN 'Policy' 
				ELSE 'Unknown' END AS 'Type',
				cia.StartTime, cia.EnforcementDeadline, cia.LastModifiedBy
FROM            v_CIAssignmentTargetedMachines AS atm INNER JOIN
                         v_CIAssignment AS cia ON atm.AssignmentID = cia.AssignmentID
WHERE     		(cia.AssignmentType IN (1, 5))
ORDER BY EnforcementDeadline DESC

-- Failed software updates by WKID
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