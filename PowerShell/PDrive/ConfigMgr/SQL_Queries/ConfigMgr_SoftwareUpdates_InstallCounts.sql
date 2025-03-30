-- Info for SUGs
select ci_id, CI_UniqueID, title
from v_updateinfo
where title in ('Security Updates 11-2019','Security Updates 12-2019', 'Security Updates 1-2020')

-- Last compliance time for software update deplotments
select ui.Title, cdr.name, LastStatusChangeTime
from v_UpdateGroupStatus_Live ugs left join
	 vSMS_CombinedDeviceResources cdr on cdr.MachineID = ugs.ResourceID left join
	 v_UpdateInfo ui on ugs.CI_ID = ui.CI_ID
where ugs.CI_ID in ('17025477','17026460','17025952') and status = 3 and cdr.IsVirtualMachine = 1

-- Last compliance time for software update deployments -- CORRECT
select assignmentname, collectionname, devicename, LastComplianceMessageTime
from vSMS_SUMDeploymentStatusPerAsset
where assignmentid in
(select AssignmentID
from vSMS_UpdateGroupAssignment
where AssignedUpdateGroup in ('17025477','17026460','17025952')) and
iscompliant = 1 and isvm = 1