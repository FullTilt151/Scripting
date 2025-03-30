SELECT        dbo.v_StatMsgAttributes.AttributeValue AS 'User', dbo.v_StatusMessage.MessageID AS 'has deleted', dbo.v_StatMsgInsStrings.InsStrValue AS 'this computer', 
                         dbo.v_StatusMessage.RecordID, dbo.v_StatMsgAttributes.AttributeTime AS 'on'
FROM            dbo.v_StatusMessage INNER JOIN
                         dbo.v_StatMsgInsStrings ON dbo.v_StatusMessage.RecordID = dbo.v_StatMsgInsStrings.RecordID INNER JOIN
                         dbo.v_StatMsgAttributes ON dbo.v_StatMsgInsStrings.RecordID = dbo.v_StatMsgAttributes.RecordID
WHERE        (dbo.v_StatusMessage.MessageID = 30066 OR
                         dbo.v_StatusMessage.MessageID = 30067) --AND (dbo.v_StatMsgInsStrings.InsStrValue LIKE @variable) 
						 AND (dbo.v_StatMsgInsStrings.InsStrIndex = '2')
ORDER BY 'this computer' DESC