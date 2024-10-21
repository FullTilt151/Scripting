-- Client software update scan counts
SELECT upp.LastScanState [State], stat.StateName [State Name], site.SMS_Assigned_Sites0 [Site],COUNT(*) AS Clients
FROM            v_UpdateScanStatus AS upp INNER JOIN
                v_StateNames AS stat ON stat.StateID = upp.LastScanState INNER JOIN
                v_RA_System_SMSAssignedSites AS site ON site.ResourceID = upp.ResourceID AND stat.TopicType = '501' AND upp.LastScanPackageLocation LIKE 'http%'
WHERE upp.LastScanTime > DATEADD(day, CONVERT(int, @days), GETDATE())
GROUP BY upp.LastScanState, stat.StateName, site.SMS_Assigned_Sites0
order by SMS_Assigned_Sites0, LastScanState

select *
from v_updatescanstatus

-- Clients per SUP
select LastScanPackageLocation [SUP], count(*) [Clients]
from v_UpdateScanStatus
group by LastScanPackageLocation
order by LastScanPackageLocation

-- Client count and % success Software Update Scan, Heartbeat, MP communication
SELECT  tot.SiteCode [Site]
       ,tot.TotalClient [Clients] 
       ,ptc.ScanTotal [Scan Success]
       ,CONVERT(decimal(5,2),(ptc.ScanTotal*100.00/tot.TotalClient)) [Scan Success %] 
       ,hrt.HBCount [Heartbeat Total] 
       ,CONVERT(decimal(5,2),(hrt.HBCount*100.00/tot.TotalClient)) [Heartbeat %] 
       ,mpc.MPComunicatonTotal [MP Comm Total]
	   ,mpc.MPComunicatonSuccess [MP Comm Success]
       ,mpc.MPComunicatonFailure [MP Comm Fail]
      ,CONVERT(decimal(5,2),(mpc.MPComunicatonSuccess*100.00/mpc.MPComunicatonTotal)) [MP Comm Success %]
  FROM ( 
        SELECT  sit.SMS_Assigned_Sites0 [SiteCode],COUNT(1) TotalClient 
          FROM v_R_System sis 
               INNER JOIN v_RA_System_SMSAssignedSites sit 
                  ON sis.ResourceID = sit.ResourceID 
                 AND sis.Client0 = 1 
                 AND sis.Obsolete0 = 0 
                 AND sis.Active0 = 1 
           GROUP BY sit.SMS_Assigned_Sites0 
        ) tot 
        LEFT OUTER JOIN ( 
                         SELECT  sit.SMS_Assigned_Sites0 [SiteCode] 
                                ,COUNT(1) [ScanTotal] 
                           FROM v_updateScanStatus upp 
                                INNER JOIN v_statenames stn 
                                   ON upp.LastScanState = stn.StateID 
                                  AND stn.TopicType = '501' 
                                  AND stn.StateName = 'Scan completed' 
                                INNER JOIN v_RA_System_SMSAssignedSites sit 
                                   ON upp.ResourceID = sit.ResourceID 
                                  AND upp.LastScanPackageLocation LIKE 'http%' 
                                  AND upp.LastScanTime > DATEADD(day, CONVERT(int, @days), GETDATE()) 
                          GROUP BY  upp.LastScanState 
                                   ,sit.SMS_Assigned_Sites0 
                         ) ptc 
          ON tot.SiteCode = ptc.SiteCode 
        LEFT OUTER JOIN ( 
                         SELECT  sit.SMS_Assigned_Sites0 AS [SiteCode] 
                                ,COUNT (sis.name0) AS [HBCount] 
                           FROM v_R_System sis 
                                INNER JOIN ( 
                                            SELECT a.ResourceID, a.AgentSite, b.AgentTime 
                                              FROM v_AgentDiscoveries a 
                                                   INNER JOIN ( 
                                                               SELECT ResourceID, MAX(AgentTime) AS AgentTime 
                                                                 FROM v_AgentDiscoveries 
                                                                WHERE AgentName LIKE '%Heartbeat%' 
                                                                  AND AgentTime > DATEADD(day, CONVERT(int, @days), GETDATE()) 
                                                                GROUP BY ResourceID 
                                                               ) b 
                                                      ON a.ResourceID = b.ResourceID 
                                                     AND a.AgentTime = b.AgentTime 
                                            ) hrt 
                                   ON sis.ResourceId = hrt.ResourceID 
                                INNER JOIN v_RA_System_SMSAssignedSites sit 
                                   ON sis.resourceID = sit.ResourceID 
                                  AND sis.Client0 = 1 
                                  AND sis.Obsolete0 = 0 
                          GROUP BY sit.SMS_Assigned_Sites0 
                         ) hrt 
          ON tot.SiteCode = hrt.SiteCode 
        LEFT OUTER JOIN ( 
                         SELECT  sub.[Site]                                         AS [SiteCode] 
                                ,SUM(CASE sub.HealthState WHEN 1 THEN sub.Cnt END)  AS [MPComunicatonSuccess] 
                                ,SUM(CASE sub.HealthState WHEN 2 THEN sub.Cnt END)  AS [MPComunicatonFailure] 
                                ,SUM(sub.Cnt)                                       AS [MPComunicatonTotal] 
                           FROM ( 
                                 SELECT  sit.SiteCode [Site] 
                                        ,chs.HealthState 
                                        ,COUNT(chs.HealthState) [Cnt] 
                                   FROM v_Site sit 
                                        INNER JOIN v_ClientHealthState chs 
                                           ON sit.SiteCode = chs.AssignedSiteCode 
                                          AND chs.HealthType = '1000' 
                                          AND chs.LastHealthReportDate > DATEADD(day, CONVERT(int, @days), GETDATE()) 
                                          AND sit.[Type] = 2 
                                  GROUP BY  sit.SiteCode 
                                           ,chs.HealthState 
                                 ) sub 
                          GROUP BY sub.[Site] 
                         ) mpc 
          ON tot.SiteCode = mpc.SiteCode 