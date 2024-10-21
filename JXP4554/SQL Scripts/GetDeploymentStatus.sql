SELECT TOP 5 *
FROM v_Update

/* 
Software Updates View Sample Queries

Applies To: System Center Configuration Manager 2007, System Center Configuration Manager 2007 R2, System Center Configuration Manager 2007 R3, System Center Configuration Manager 2007 SP1, System Center Configuration Manager 2007 SP2

The following sample queries demonstrate how to join software updates views to each other and to views from other view categories. Software updates views will most often use the CI_ID column when joining to other views.

Joining Software Updates, Discovery, and Status Views

The following query retrieves the article ID, bulletin ID, software update title, last enforcement state for the update, the time of the last enforcement check, and the time that the last enforcement state message was sent by the Computer1 client. The results are sorted by state name and then by the last modified date for the software update. The query joins the v_UpdateComplianceStatus status view with the v_UpdateInfo software updates view by using the CI_ID column, the v_UpdateComplianceStatus status view with the v_R_System discovery view by using the ResourceID column, and the v_UpdateComplianceStatus status view with the v_StateNames status view by using the LastEnforcementStatus and StateID columns, respectively. The retrieved information is filtered by the topic type of 402, which includes state messages for configuration item enforcement, and a computer with the NetBIOS name of Computer1 
*/
SELECT v_UpdateInfo.ArticleID,
	v_UpdateInfo.BulletinID,
	v_UpdateInfo.Title,
	v_StateNames.StateName,
	v_UpdateComplianceStatus.LastStatusCheckTime,
	v_UpdateComplianceStatus.LastEnforcementMessageTime
FROM v_R_System
INNER JOIN v_UpdateComplianceStatus ON v_R_System.ResourceID = v_UpdateComplianceStatus.ResourceID
INNER JOIN v_UpdateInfo ON v_UpdateComplianceStatus.CI_ID = v_UpdateInfo.CI_ID
INNER JOIN v_StateNames ON v_UpdateComplianceStatus.LastEnforcementMessageID = v_StateNames.StateID
WHERE (v_StateNames.TopicType = 402)
	AND (v_R_System.Netbios_Name0 LIKE 'LOUWEBWTS274')
ORDER BY v_StateNames.StateName,
	v_UpdateInfo.DateLastModified

/* 
The following query lists the advertisement ID and advertisement name for all advertisements at the site, clients that have been targeted with the advertisement, IP address of the client, name of the collection that was targeted, and the last state for the advertisement. The v_Advertisement view is joined to the v_ClientAdvertisementStatus status view by using the AdvertisementID column and the v_Collection collection view by using the CollectionID column. The v_ClientAdvertisementStatus status view is joined to the v_R_System and v_RA_System_IPAddresses discovery views by using the ResourceID columns.

CAS.LastStatusMessageID CAS.LastStatusMessageIDName
 */
SELECT ADV.AdvertisementID,
	ADV.AdvertisementName,
	SYS.Netbios_Name0,
	SYSIP.IP_Addresses0,
	COL.Name AS TargetedCollection,
	CAS.*
FROM v_Advertisement ADV
INNER JOIN v_ClientAdvertisementStatus CAS ON ADV.AdvertisementID = CAS.AdvertisementID
INNER JOIN v_R_System SYS ON CAS.ResourceID = SYS.ResourceID
INNER JOIN v_Collection COL ON ADV.CollectionID = COL.CollectionID
INNER JOIN v_RA_System_IPAddresses SYSIP ON SYS.ResourceID = SYSIP.ResourceID
WHERE ADV.AdvertisementID = 'SP122242'
	AND (
		CAS.LastStatusMessageID = 10054
		OR CAS.LastStatusMessageID = 10050
		)
ORDER BY ADV.AdvertisementID,
	SYS.Netbios_Name0

SELECT *
FROM v_ConfigurationItems
WHERE CI_UniqueID IN ('fbc1b097-d33b-4295-a961-8d0104adf708', '2261358b-eedc-4825-8114-ef7011072e88', 'ba4bbea6-72cb-47d6-b61f-c2221cf4d5e8', '60fb007f-b9b1-487a-ad90-2809876b9940', '37f39f03-27ae-4240-899d-d90a7f147510', '597fc574-c938-4c75-ba99-332705631b68', '9452503c-05be-4a64-99ed-9a59f7d65398', '5998e48e-de95-433d-9386-7cffe5d13bdc', '89f208f1-9036-4049-b8f6-a28497437604', 'a024086f-17fd-4875-8d84-a5d9a6811ed4', '9d460da0-8983-4bb4-a839-df88e5777488', '1278a789-b29b-482d-b721-f3bc3c9ede66')
	OR EULAAccepted = 2

Select * from v_AuthListInfo
