-- Non-compliant machines for a CI_ID
SELECT        SMS_R_System.ItemKey, SMS_R_System.DiscArchKey, SMS_R_System.Name0, v_r_system.Operating_System_Name_and0, SMS_R_System.SMS_Unique_Identifier0, 
                         SMS_R_System.Resource_Domain_OR_Workgr0, SMS_R_System.Client0
FROM            dbo.vSMS_R_System AS SMS_R_System INNER JOIN
                         dbo.v_Update_ComplianceStatusAll AS cs ON cs.CI_ID = 58774 AND cs.ResourceID = SMS_R_System.ItemKey INNER JOIN
						 v_r_system ON v_r_system.resourceid = SMS_R_SYSTEM.itemkey
WHERE        (cs.Status = 2)