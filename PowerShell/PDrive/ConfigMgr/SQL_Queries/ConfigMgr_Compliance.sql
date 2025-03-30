SELECT        tm.Netbios_Name0 AS WKID,  eval.result, 
				CASE eval.result
				WHEN '7' THEN 'Success'
				WHEN '1' THEN 'Broken Client'
				ELSE 'Whatever'
				END, 
				eval.HealthCheckDescription Description, AllBaseLines.AssignmentName, AllBaselines.CollectionID 
FROM            (SELECT        assign.AssignmentID, assign.AssignmentName, coll.CollectionID, coll.Name AS CollecionName, bls.CI_ID, bls.ModelId, bls.CIType_ID, bls.CI_UniqueID, bls.CIVersion
                          FROM            dbo.v_CIAssignment AS assign INNER JOIN
                                                    dbo.v_Collection AS coll ON coll.CollectionID = assign.CollectionID INNER JOIN
                                                    dbo.v_CIAssignmentToCI AS targ ON targ.AssignmentID = assign.AssignmentID INNER JOIN
                                                    dbo.v_CIRelation_All AS rel ON rel.CI_ID = targ.CI_ID INNER JOIN
                                                    dbo.v_SMSConfigurationItems AS bls ON bls.CI_ID = rel.ReferencedCI_ID
                          WHERE        (bls.CIType_ID = 2) AND (bls.IsTombstoned = 0) AND (assign.AssignmentID = @AssignmentID) AND (assign.AssignmentType = 0) AND 
                                                    (coll.CollectionID = @CollectionID)) AS AllBaselines CROSS JOIN
                         dbo.v_R_System AS tm LEFT OUTER JOIN
                         dbo.v_SMSCICurrentComplianceStatus AS cs ON cs.ModelID = AllBaselines.ModelId AND cs.CIVersion = AllBaselines.CIVersion AND 
                         cs.ItemKey = tm.ResourceID INNER JOIN
                         dbo.v_CH_ClientSummary AS chcs ON chcs.ResourceID = tm.ResourceID LEFT OUTER JOIN
                         dbo.v_CH_EvalResults AS eval ON eval.ResourceID = tm.ResourceID
WHERE        tm.Netbios_Name0 in (
			 select SYS.netbios_name0 
			 from v_r_system SYS inner join
			 v_CM_RES_COLL_CAS01318 COL ON SYS.ResourceID = COL.ResourceID)
order by eval.Result, WKID

select distinct CollectionID, CollectionName, CollectionID + ' - ' + CollectionName
from dbo.v_CIAssignment
where AssignmentType = '0'
order by CollectionName

-------------------------------------

select CIA.AssignmentID, CIA.AssignmentName, CSD.ConfigurationItemName
from dbo.v_CIAssignment CIA FULL JOIN
	 v_CIAssignmentToCI CIID ON CIA.AssignmentID = CIID.AssignmentID FULL JOIN
	 v_CIComplianceStatusDetail CSD ON CIID.CI_ID = CSD.CI_ID
where CIA.AssignmentType = '0'
order by CIA.AssignmentName

select CIA.AssignmentID, CIA.AssignmentName, *
from dbo.v_CIAssignment CIA
where CIA.AssignmentType = '0'
order by CIA.AssignmentName

select distinct top 100 CI_ID, Rule_CI_ID, Rule_ID, Setting_ID, Setting_CI_ID
from v_CIComplianceStatusComplianceDetail

select *
from v_CIAssignmentToCI
