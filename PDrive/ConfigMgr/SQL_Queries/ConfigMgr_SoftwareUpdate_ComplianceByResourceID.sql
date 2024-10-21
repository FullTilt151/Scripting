select BulletinID, ArticleID, DateRevised, Title, uds.AssignmentName, uds.CollectionName, uds.StartTime, sys.Netbios_Name0, IsCompliant
from v_UpdateDeploymentSummary UDS join
	 v_UpdateAssignmentStatus UAS on uds.AssignmentID = uas.AssignmentID join
	 v_UpdateInfo UI on uds.ci_id = ui.CI_ID join
	 v_r_system SYS on uas.ResourceID = sys.ResourceID
where uas.ResourceID in (33697792,33715981,33697786,33697785,33721133,16901170)
order by AssignmentName, articleID, Netbios_Name0

select sys.Netbios_Name0, sys.Operating_System_Name_and0, UCI.status, 
	  case uci.status 
	  when 0 then 'Unknown'
	  when 1 then 'Not required'
	  when 2 then 'Required not installed'
	  when 3 then 'Installed'
	  end [Status Name]
from v_R_System_Valid sys join
	 v_Update_ComplianceStatus UCI on sys.ResourceID = uci.ResourceID
where CI_ID = '220912'


select UCI.status,
	  case uci.status 
	  when 0 then 'Unknown'
	  when 1 then 'Not required'
	  when 2 then 'Required not installed'
	  when 3 then 'Installed'
	  end [Status Name],
	   count(*)
from v_R_System_Valid sys join
	 v_Update_ComplianceStatus UCI on sys.ResourceID = uci.ResourceID
where CI_ID = '220912'
group by UCI.status