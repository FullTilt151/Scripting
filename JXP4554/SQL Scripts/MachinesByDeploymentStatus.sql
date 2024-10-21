SELECT DISTINCT STM.Netbios_Name0 [WKID],
	CDA.StatusDescription
FROM v_ClassicDeploymentAssetDetails CDA
JOIN v_r_system STM ON CDA.DeviceID = STM.ResourceID
WHERE MessageID IN (10045, 10050, 10051, 10053, 10054, 10057, 10060)
ORDER BY Netbios_Name0

SELECT DISTINCT MessageID,
	StatusDescription
FROM v_ClassicDeploymentAssetDetails CDA
ORDER BY MessageID
