
/*

UPDATE v_CollectionRuleQuery
set QueryExpression=

'declare @CI_ID int;set @CI_ID = 58772;select  all SMS_R_SYSTEM.ItemKey,SMS_R_SYSTEM.DiscArchKey,SMS_R_SYSTEM.Name0,SMS_R_SYSTEM.SMS_Unique_Identifier0,SMS_R_SYSTEM.Resource_Domain_OR_Workgr0,SMS_R_SYSTEM.Client0 from vSMS_R_System AS SMS_R_System INNER JOIN v_Update_ComplianceStatusAll cs on cs.CI_ID=@CI_ID and cs.ResourceID=SMS_R_System.ItemKey where cs.Status = 2'

where CollectionID = 'CAS00CB2'
*/

select * from v_CollectionRuleQuery

where CollectionID = 'CAS00CF0'