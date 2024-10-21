Declare @DeploymentID Char(8)
Declare @Days Int
set @DeploymentID = 'SP120EB6'
set @Days = 1

SELECT Distinct stat.MachineName
FROM   v_statusmessage AS stat 
       LEFT JOIN v_statmsginsstrings AS ins 
              ON stat.recordid = ins.recordid 
       LEFT JOIN v_statmsgattributes AS att1 
              ON stat.recordid = att1.recordid 
       INNER JOIN v_statmsgattributes AS att2 
               ON stat.recordid = att2.recordid 
WHERE  att2.attributeid = 401 
       AND att2.attributevalue = @DeploymentID
       AND stat.sitecode = 'SP1' 
       AND ins.insstrindex = 0 
       AND stat.messageid = 10008 
       AND att1.attributevalue = @DeploymentID
	   AND DateDiff(Day,att2.AttributeTime,GetDate()) >= @Days
ORDER  BY STAT.MachineName