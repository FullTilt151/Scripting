select top 1000 smsgs.RecordID,
CASE smsgs.Severity
WHEN -1073741824 THEN 'Error'
WHEN 1073741824 THEN 'Informational'
WHEN -2147483648 THEN 'Warning'
ELSE 'Unknown'
END As 'SeverityName',
smsgs.MessageID, smsgs.Severity, modNames.MsgDLLName, smsgs.Component,
smsgs.MachineName, smsgs.Time, smsgs.SiteCode, smwis.InsString1,
smwis.InsString2, smwis.InsString3, smwis.InsString4, smwis.InsString5,
smwis.InsString6, smwis.InsString7, smwis.InsString8, smwis.InsString9,
smwis.InsString10
from v_StatusMessage smsgs
join v_StatMsgWithInsStrings smwis on smsgs.RecordID = smwis.RecordID
join v_StatMsgModuleNames modNames on smsgs.ModuleName = modNames.ModuleName
--where smsgs.MessageID = 10803 and smsgs.MachineName in
-- (select name from _res_coll_CEN00018)
--where smsgs.MachineName = 'mycomputername'
Order by smsgs.Time DESC
