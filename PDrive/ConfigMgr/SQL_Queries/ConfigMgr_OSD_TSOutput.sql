-- TS output
SELECT        TSRPT_C009 [Timestamp], TSRPT_C004 [Step], TSRPT_C005 [Step Name], TSRPT_C006 [Group], LastStatusMessageID, LastStatusMessageIDName, TSRPT_C007 [Exit Code], TSRPT_C008 [Output]
FROM            (SELECT        tse.ExecutionTime AS TSRPT_C009, CASE WHEN LastStatusMessageID IN (11139, 11140, 11141, 11142, 11143) THEN NULL 
                                                    ELSE Step + 1 END AS TSRPT_C004, CASE WHEN LastStatusMessageID IN (11139, 11140, 11141, 11142, 11143) THEN NULL 
                                                    ELSE ActionName END AS TSRPT_C005, CASE WHEN LastStatusMessageID IN (11139, 11140, 11141, 11142, 11143) THEN NULL 
                                                    ELSE GroupName END AS TSRPT_C006, tse.LastStatusMessageID, tse.LastStatusMessageIDName, tse.ExitCode AS TSRPT_C007, 
                                                    tse.ActionOutput AS TSRPT_C008
                          FROM            dbo.v_TaskExecutionStatus AS tse INNER JOIN
                                                    dbo.v_R_System AS sys ON tse.ResourceID = sys.ResourceID
                          WHERE        (tse.AdvertisementID = @AdvertID) AND (sys.Netbios_Name0 = @WKID)
                          UNION
                          SELECT        stat.Time, NULL AS Expr1, NULL AS Expr2, NULL AS Expr3, stat.MessageID, info.MessageName, 0 AS Expr4, NULL AS Expr5
                          FROM            dbo.v_StatusMessage AS stat INNER JOIN
                                                   dbo.v_StatMsgAttributes AS att ON stat.RecordID = att.RecordID AND stat.Time = att.AttributeTime INNER JOIN
                                                   dbo.v_R_System AS sys ON stat.MachineName = sys.Name0 LEFT OUTER JOIN
                                                   dbo.v_AdvertisementStatusInformation AS info ON stat.MessageID = info.MessageID
                          WHERE        (stat.Component = 'Software Distribution' OR
                                                   stat.Component = 'Task Sequence Engine' OR
                                                   stat.Component = 'Task Sequence Manager') AND (sys.Netbios_Name0 = @WKID) AND (att.AttributeID = 401) AND 
                                                   (att.AttributeValue = @AdvertID)) AS Merged
ORDER BY TSRPT_C009


-- List of adverts
select AdvertisementID, AdvertisementName + ' (' + AdvertisementID + ')' [AdvertName]
from v_Advertisement
where AdvertisementName like 'Windows7-%' or AdvertisementName like 'Windows8-%' or AdvertisementName like '1EZTIStateCapture%' or AdvertisementName like '1EZTIWin7x64E-OSDDeploy-Master-Rel3-0830-Image_CAS00376_%' and AdvertisementName not like '%pilot%'
order by AdvertName