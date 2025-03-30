-- DSDeploymentID
-- Gets DeploymentID and Deployment name, meant for dropdown list

SELECT cia.assignment_uniqueid [DeploymentID], 
       Isnull(grp.title+' - ', '')  + cia.assignmentname [DeploymentName]
FROM   v_ciassignment cia 
       LEFT JOIN v_ciassignmenttogroup atg 
              ON cia.assignmenttype = 5 
                 AND atg.assignmentid = cia.assignmentid 
       LEFT JOIN v_authlistinfo grp 
              ON cia.assignmenttype = 5 
                 AND grp.ci_id = atg.assignedupdategroup 
--where cia.AssignmentType in (1,5) and (@filterwildcard='' or cia.Assignment_UniqueID like @filterwildcard or cia.AssignmentName like @filterwildcard or grp.Title like @filterwildcard) 
ORDER  BY 2   
        
Declare @DeploymentID varchar(200) = '{ABC11422-A18A-4BC6-B57F-4941C2DC2C31}'

-- Deployment states for a deployment with counts. 
DECLARE @DeploymentLocalID AS INT = (SELECT assignmentid 
   FROM   v_ciassignment 
   WHERE  assignment_uniqueid = @DEPLOYMENTID) 
DECLARE @COLLCOUNT INT = (SELECT Count(*) 
   FROM   v_ciassignmenttargetedmachines 
   WHERE  assignmentid = @DeploymentLocalID) 

SELECT a.assignment_uniqueid [DeploymentID],
       a.assignmentname [DeploymentName], 
       a.starttime [Available],
       a.enforcementdeadline [Deadline],
       sn.statename [LastEnforcementState],
       sc.statecount [NumberOfComputers],
       CONVERT(FLOAT, sc.statecount * 100.0) / 
                  Isnull(NULLIF(@COLLCOUNT, 0), 1) [PComputers],
       sc.statetype * 10000 + sc.stateid [DeploymentStateID]
FROM   v_ciassignment a 
       CROSS apply(SELECT statetype, 
                          stateid, 
                          StateCount=Count(*) 
                   FROM   v_assignmentstate_combined 
                   WHERE  assignmentid = a.assignmentid 
                          AND statetype IN ( 300, 301 ) 
                   GROUP  BY statetype, 
                             stateid) sc 
       LEFT JOIN v_statenames sn 
              ON sn.topictype = sc.statetype 
                 AND sn.stateid = sc.stateid 
WHERE  a.assignmentid = @DeploymentLocalID 
ORDER  BY sc.statecount DESC, 
          sn.statename   
-- State 4
-- Parameter_DataSet_Status
DECLARE @asid INT = (SELECT assignmentid 
   FROM   v_ciassignment 
   WHERE  assignment_uniqueid = @DEPLOYMENTID 
          AND assignmenttype IN ( 1, 5 )) 

SELECT StateID=10000 * sn.topictype + sn.stateid, 
       sn.statename 
FROM   v_statenames sn 
       JOIN (SELECT DISTINCT topictype, 
                             stateid 
             FROM   v_assignmentstatepertopic 
             WHERE  assignmentid = @asid 
                    AND topictype = 302 
             UNION ALL 
             SELECT DISTINCT statetype, 
                             stateid 
             FROM   v_assignmentstate_combined 
             WHERE  assignmentid = @asid) ast 
         ON sn.topictype = ast.topictype 
            AND sn.stateid = ast.stateid 
WHERE  sn.topictype IN ( 300, 301, 302 ) 
ORDER  BY sn.topictype, 
          sn.statename   

Declare @Status int = 3010006

--Dataset 0

SELECT s.resourceid [ResourceID], 
       m.name0                              [ComputerName], 
       m.user_domain0 + '\' + m.user_name0  [LastLoggedOnUser], 
       asite.sms_assigned_sites0            [AssignedSite], 
       m.client_version0                    [ClientVersion], 
       s.statetime                          [DeploymentStateTime], 
       ( s.laststatusmessageid&0x0000FFFF ) [ErrorStatusID], 
       sn.statename                         [Status], 
       a.assignment_uniqueid                [DeploymentID], 
       Isnull(grp.title+' - ', '') 
       + a.assignmentname                   [DeploymentName], 
       statusinfo.messagename               [ErrorStatusName]
FROM   v_ciassignment a 
       JOIN (SELECT assignmentid, 
                    resourceid, 
                    statetype, 
                    stateid, 
                    statetime, 
                    laststatusmessageid 
             FROM   v_assignmentstate_combined 
             WHERE  @STATUS / 10000 IN ( 300, 301 ) 
             UNION ALL 
             SELECT assignmentid, 
                    resourceid, 
                    topictype, 
                    stateid, 
                    statetime, 
                    laststatusmessageid 
             FROM   v_assignmentstatepertopic 
             WHERE  @STATUS / 10000 IN ( 302 )) s 
         ON s.assignmentid = a.assignmentid 
            AND s.statetype = @STATUS / 10000 
            AND s.stateid = @STATUS%10000 
       LEFT JOIN v_statenames sn 
              ON sn.topictype = s.statetype 
                 AND sn.stateid = Isnull(s.stateid, 0) 
       JOIN v_r_system m 
         ON m.resourcetype = 5 
            AND m.resourceid = s.resourceid 
            AND Isnull(m.obsolete0, 0) = 0 
       LEFT JOIN v_ra_system_smsassignedsites asite 
              ON m.resourceid = asite.resourceid 
       LEFT JOIN v_advertisementstatusinformation statusinfo 
              ON statusinfo.messageid = NULLIF(s.laststatusmessageid&0x0000FFFF, 
                                        0) 
       LEFT JOIN v_ciassignmenttogroup ATG 
              ON a.assignmenttype = 5 
                 AND atg.assignmentid = a.assignmentid 
       LEFT JOIN v_authlistinfo grp 
              ON a.assignmenttype = 5 
                 AND grp.ci_id = atg.assignedupdategroup 
WHERE  ( s.laststatusmessageid&0x0000FFFF = 11760 ) and a.AssignmentID=@asid
ORDER  BY m.name0   

-- Reports below


--Group by 
SELECT Isnull(grp.title+' - ', '') 
       + a.assignmentname [DeploymentName], 
       Count(m.name0)     [Count] 
FROM   v_ciassignment a 
       JOIN (SELECT assignmentid, 
                    resourceid, 
                    statetype, 
                    stateid, 
                    statetime, 
                    laststatusmessageid 
             FROM   v_assignmentstate_combined 
             UNION ALL 
             SELECT assignmentid, 
                    resourceid, 
                    topictype, 
                    stateid, 
                    statetime, 
                    laststatusmessageid 
             FROM   v_assignmentstatepertopic 
             WHERE  301 IN ( 302 )) s 
         ON s.assignmentid = a.assignmentid 
            AND s.statetype = 301 
            AND s.stateid = 6 
       LEFT JOIN v_statenames sn 
              ON sn.topictype = s.statetype 
                 AND sn.stateid = Isnull(s.stateid, 0) 
       JOIN v_r_system m 
         ON m.resourcetype = 5 
            AND m.resourceid = s.resourceid 
            AND Isnull(m.obsolete0, 0) = 0 
       LEFT JOIN v_ra_system_smsassignedsites asite 
              ON m.resourceid = asite.resourceid 
       LEFT JOIN v_advertisementstatusinformation statusinfo 
              ON statusinfo.messageid = NULLIF(s.laststatusmessageid&0x0000FFFF, 
                                        0) 
       LEFT JOIN v_ciassignmenttogroup ATG 
              ON a.assignmenttype = 5 
                 AND atg.assignmentid = a.assignmentid 
       LEFT JOIN v_authlistinfo grp 
              ON a.assignmenttype = 5 
                 AND grp.ci_id = atg.assignedupdategroup 
WHERE  ( s.laststatusmessageid&0x0000FFFF = 11760 ) 
GROUP  BY Isnull(grp.title+' - ', '') 
          + a.assignmentname 
ORDER  BY Isnull(grp.title+' - ', '') 
          + a.assignmentname   

--Below is the detail report, the following is a variable that would be from the report
Declare @DeploymentName varchar(250) = 'NWS - PT Office Jul 2017 - NWS - PT Office Jul 2017 Reboot'

-- DSDeploymentID
-- Gets DeploymentID and Deployment name, meant for dropdown list

SELECT cia.assignment_uniqueid [DeploymentID], 
       Isnull(grp.title+' - ', '')  + cia.assignmentname [DeploymentName]
FROM   v_ciassignment cia 
       LEFT JOIN v_ciassignmenttogroup atg 
              ON cia.assignmenttype = 5 
                 AND atg.assignmentid = cia.assignmentid 
       LEFT JOIN v_authlistinfo grp 
              ON cia.assignmenttype = 5 
                 AND grp.ci_id = atg.assignedupdategroup 
ORDER  BY 2  


Declare @DeploymentID varchar(200) = (SELECT cia.assignment_uniqueid
FROM   v_ciassignment cia 
       LEFT JOIN v_ciassignmenttogroup atg 
              ON cia.assignmenttype = 5 
                 AND atg.assignmentid = cia.assignmentid 
       LEFT JOIN v_authlistinfo grp 
              ON cia.assignmenttype = 5 
                 AND grp.ci_id = atg.assignedupdategroup 
where Isnull(grp.title+' - ', '')  + cia.assignmentname = @DeploymentName)

DECLARE @asid INT = (SELECT assignmentid 
   FROM   v_ciassignment 
   WHERE  assignment_uniqueid = @DEPLOYMENTID 
          AND assignmenttype IN ( 1, 5 )) 

--Detail 
SELECT m.name0                             [ComputerName], 
       m.user_domain0 + '\' + m.user_name0 [LastLoggedOnUser], 
       m.client_version0                   [ClientVersion], 
       s.statetime                         [DeploymentStateTime], 
       Isnull(grp.title+' - ', '') 
       + a.assignmentname                  [DeploymentName], 
       statusinfo.messagename              [ErrorStatusName] 
FROM   v_ciassignment a 
       JOIN (SELECT assignmentid, 
                    resourceid, 
                    statetype, 
                    stateid, 
                    statetime, 
                    laststatusmessageid 
             FROM   v_assignmentstate_combined 
             UNION ALL 
             SELECT assignmentid, 
                    resourceid, 
                    topictype, 
                    stateid, 
                    statetime, 
                    laststatusmessageid 
             FROM   v_assignmentstatepertopic 
             WHERE  301 IN ( 302 )) s 
         ON s.assignmentid = a.assignmentid 
            AND s.statetype = 301 
            AND s.stateid = 6 
       LEFT JOIN v_statenames sn 
              ON sn.topictype = s.statetype 
                 AND sn.stateid = Isnull(s.stateid, 0) 
       JOIN v_r_system m 
         ON m.resourcetype = 5 
            AND m.resourceid = s.resourceid 
            AND Isnull(m.obsolete0, 0) = 0 
       LEFT JOIN v_ra_system_smsassignedsites asite 
              ON m.resourceid = asite.resourceid 
       LEFT JOIN v_advertisementstatusinformation statusinfo 
              ON statusinfo.messageid = NULLIF(s.laststatusmessageid&0x0000FFFF, 
                                        0) 
       LEFT JOIN v_ciassignmenttogroup ATG 
              ON a.assignmenttype = 5 
                 AND atg.assignmentid = a.assignmentid 
       LEFT JOIN v_authlistinfo grp 
              ON a.assignmenttype = 5 
                 AND grp.ci_id = atg.assignedupdategroup 
WHERE  ( s.laststatusmessageid&0x0000FFFF = 11760 ) and a.AssignmentID=@asid
ORDER  BY m.name0 
