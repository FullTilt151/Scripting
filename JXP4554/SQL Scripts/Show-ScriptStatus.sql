SELECT FCM.Name [WKID],
	Scrpt.ScriptExitCode
FROM v_r_system STM
JOIN v_fullcollectionMembership FCM ON STM.ResourceID = FCM.ResourceID
LEFT JOIN vSMS_ScriptsExecutionStatus Scrpt ON scrpt.ResourceId = STM.ResourceID
WHERE Scrpt.ScriptGuid = '937C2F69-67ED-4682-B072-8F4BA4C53655'
	AND FCM.CollectionID = 'WP104422'

SELECT STM.Netbios_name0 [WKID]
FROM v_r_system STM
LEFT JOIN v_fullcollectionMembership FCM ON STM.ResourceID = FCM.ResourceID
WHERE FCM.CollectionID = 'WP104422'

SELECT *
FROM vsms_scripts

SELECT *
FROM vSMS_ScriptsExecutionStatus

SELECT *
FROM vSMS_ScriptsExecutionSummary

SELECT *
FROM vSMS_ScriptsExecutionTask
