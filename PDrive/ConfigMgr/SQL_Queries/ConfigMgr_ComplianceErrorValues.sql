select cicsd.Netbios_Name0 [Name], cicsd.ci_id [CI ID], cicsd.configurationitemname [CI], CICSD.Criteria, 
			  cicsd.CurrentValue [Value], 
			  cicsd.LastComplianceMessageTime [Last Message]
from v_R_System SYS join
	 v_CIComplianceStatusDetail CICSD on sys.resourceid = cicsd.ResourceID
where CI_ID = '16863772'
order by Value

select distinct CI_ID, CI_UniqueID, ConfigurationItemName
from v_CIComplianceStatusDetail
order by ConfigurationItemName

select ci_id, *
from v_ConfigurationItems

select *
from vDCMDeploymentErrorStatus
where CI_ID = '16863772' or AssignmentID = '16777271'