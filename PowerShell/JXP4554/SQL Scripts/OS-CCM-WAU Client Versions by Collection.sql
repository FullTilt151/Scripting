DECLARE @ColID CHAR(8)

SET @ColID = 'SP10072F'

SELECT STM.Netbios_Name0 [WKID],
	OSDN.DisplayName [OS],
	STM.Client_Version0 [CCM Version],
	WAU.Version0 [WAU Version]
FROM v_R_System STM
JOIN Humana_OS_Caption_DisplayName OSDN ON STM.Operating_System_Name_and0 = OSDN.Caption
JOIN v_GS_WINDOWSUPDATEAGENTVERSION WAU ON WAU.ResourceID = STM.ResourceID
WHERE STM.ResourceID IN (
		SELECT ResourceID
		FROM v_FullCollectionMembership_Valid
		WHERE CollectionID = @ColID
		)
