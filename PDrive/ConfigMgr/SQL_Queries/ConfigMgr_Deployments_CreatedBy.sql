select smsgs.Time, smsgs.MessageID, 
		case smsgs.MessageID
		when '30226' then 'Application'
		when '30006' then 'Package/TS'
		when '30196' then 'Update/Baseline'
		when '40303' then 'Client Setting/AM Policy'
		when '40700' then 'Other'
		end [Type],
		smsgs.SiteCode,smsgs.MachineName, smwis.InsString1 [User], smwis.InsString2 [DeploymentID], smwis.InsString3 [Deployment Name], smwis.InsString4 [Program/SUG]
from v_StatusMessage smsgs
join v_StatMsgWithInsStrings smwis on smsgs.RecordID = smwis.RecordID
join v_StatMsgModuleNames modNames on smsgs.ModuleName = modNames.ModuleName
where smsgs.MessageID in ('30196','30006', '30226', '40303', '40700') 
Order by smsgs.Time DESC