<#
DECLARE @lcid AS INT 
SET @lcid = dbo.fn_LShortNameToLCID(1033)

SELECT  
	UpdateClassification=cls.CategoryInstanceName,
	ui.Title,             
	ui.BulletinID, 
	ui.ArticleID,
	ui.DateRevised,
	Deployed=(CASE WHEN ctm.ResourceID IS NOT NULL THEN '*' END), 
	Installed=(CASE WHEN css.Status=3 THEN '*' END), 
	IsRequired=(CASE WHEN css.Status=2 THEN '*' END),
	WaitingforInstall=(CASE WHEN css.Status=2 AND ctm.ResourceID IS NOT NULL THEN '*' END)
FROM fn_rbac_UpdateComplianceStatus(@UserSIDs) css 
JOIN fn_rbac_UpdateInfo(@lcid, @UserSIDs) ui ON ui.CI_ID=css.CI_ID --SMS_ConfigurationItem
JOIN fn_rbac_CICategoryInfo_All(@lcid, @UserSIDs) vnd ON vnd.CI_ID=ui.CI_ID AND vnd.CategoryTypeName='Company'
JOIN fn_rbac_CICategoryInfo_All(@lcid, @UserSIDs) cls ON cls.CI_ID=ui.CI_ID AND cls.CategoryTypeName='UpdateClassification'
LEFT JOIN fn_rbac_CITargetedMachines(@UserSIDs) ctm ON ctm.CI_ID=css.CI_ID AND ctm.ResourceID = css.ResourceID
JOIN fn_rbac_R_System_Valid(@UserSIDs) AS sysr ON sysr.ResourceID = css.ResourceID 
WHERE sysr.Netbios_Name0 = @Comp
	AND cls.CategoryInstanceName in (@Class)
ORDER BY 1,5 DESC
#>

