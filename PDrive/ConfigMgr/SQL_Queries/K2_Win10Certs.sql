DECLARE @pStatusFilter nvarchar(max) = '16;17;18;';

BEGIN
	
	WITH CteContacts ([RequestId], [ContactTypeId], [AccountIds], [AccountNames]) 
	AS (
		SELECT RequestId, ContactTypeId, AccountIds, AccountNames
		FROM SC.RequestContacts WITH (NOLOCK)
		WHERE ContactTypeId IN (1,2,6,7)
		GROUP BY RequestId, ContactTypeId, AccountIds, AccountNames
	)

SELECT distinct R.RequestId, P.VendorName, P.ProductName, R.ProductVersion, CONCAT(P.VendorName, ' ', P.ProductName, ' ', R.ProductVersion) AS [ProductTitle], 
		Rim.InstallMethod, S.Status, RPD.PackageId,
		R.PathInstall, AT.FilePath,
		Atm.AtmNames AS [AssetTrackingMethod], 
		FName.DataDetail AS [EXE_FileName], 
		FPath.DataDetail AS [EXE_FilePath],
		FSize.DataDetail AS [EXE_FileSize],
		FVer.DataDetail AS [EXE_FileVersion],
		FRptName.DataDetail AS [EXE_ReportName],
		FRptCat.DataDetail AS [EXE_ReportCategory],
		FAddFName.DataDetail AS [EXE_AdditionalFileName],
		SName.DataDetail AS [Swidtag_FileName], 
		SPath.DataDetail AS [Swidtag_FilePath],
		SSize.DataDetail AS [Swidtag_FileSize],
		SRptName.DataDetail AS [Swidtag_ReportName],
		SRptCat.DataDetail AS [Swidtag_ReportCategory],
		SAddFName.DataDetail AS [Swidtag_AdditionalFileName],
		ArpPub.DataDetail AS [ARP_Publisher],
		ArpName.DataDetail AS [ARP_Name],
		ArpVer.DataDetail AS [ARP_Version],
		ArpProdCode.DataDetail AS [ARP_ProductCode],
		ArpInstFold.DataDetail AS [ARP_InstallFolder]
FROM SC.Request R WITH (NOLOCK)
LEFT JOIN SC.InstallType ON R.[InstallTypeId]=InstallType.TypeId
LEFT JOIN SC.Products P ON R.ProductId=P.ProductId
LEFT JOIN SC.RequestAssetTrackingMethods TM ON R.RequestId=TM.RequestId
LEFT JOIN SC.RequestOperatingSystems Ros ON R.RequestId=Ros.RequestId
LEFT JOIN SC.RequestInstallMethods Rim ON R.RequestId=Rim.[RequestId]
LEFT JOIN SC.LicReqCategory Cat ON R.RequireLicCatId=Cat.LicReqCategoryID
LEFT JOIN SC.SoftwareType St ON R.SoftwareTypeId=St.TypeId
LEFT JOIN SC.Status S ON R.StatusId=S.StatusId
LEFT JOIN SC.Team T ON R.TeamId=T.TeamId
LEFT JOIN SC.RequestAssetTrackingMethods Atm on R.RequestId=Atm.RequestId
LEFT JOIN SC.RequestAttachment AT on R.RequestId = AT.RequestId
/* EXE File Tracking */
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=7 AND FieldName LIKE '%Executable File Name') FName on R.RequestId=FName.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=7 AND FieldName LIKE '%Executable File Path') FPath on R.RequestId=FPath.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=7 AND FieldName LIKE '%Executable File Size') FSize on R.RequestId=FSize.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=7 AND FieldName LIKE '%Executable File Version') FVer on R.RequestId=FVer.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=7 AND FieldName LIKE '%Product Code') FProdCode on R.RequestId=FProdCode.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=7 AND FieldName LIKE '%Install Folder') FInstFold on R.RequestId=FInstFold.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=7 AND FieldName LIKE '%Executable File Report Name') FRptName on R.RequestId=FRptName.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=7 AND FieldName LIKE '%Executable File Report Category') FRptCat on R.RequestId=FRptCat.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=7 AND FieldName LIKE '%Additional File Name (optional)') FAddFName on R.RequestId=FAddFName.RequestId
/* Swidtag File Tracking */
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=8 AND FieldName LIKE '%Swidtag File Name') SName on R.RequestId=SName.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=8 AND FieldName LIKE '%Swidtag File Path') SPath on R.RequestId=SPath.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=8 AND FieldName LIKE '%Swidtag File Size') SSize on R.RequestId=SSize.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=8 AND FieldName LIKE '%Swidtag Report Name') SRptName on R.RequestId=SRptName.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=8 AND FieldName LIKE '%Swidtag Report Category') SRptCat on R.RequestId=SRptCat.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=8 AND FieldName LIKE '%Swidtag Additional Filename (optional)') SAddFName on R.RequestId=SAddFName.RequestId
/* ARP Tracking */
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=6 AND FieldName LIKE '%Display Publisher') ArpPub on R.RequestId=ArpPub.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=6 AND FieldName LIKE '%Display Name') ArpName on R.RequestId=ArpName.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=6 AND FieldName LIKE '%Display Version') ArpVer on R.RequestId=ArpVer.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=6 AND FieldName LIKE '%Product Code') ArpProdCode on R.RequestId=ArpProdCode.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=6 AND FieldName LIKE '%Install Folder') ArpInstFold on R.RequestId=ArpInstFold.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=6 AND FieldName LIKE '%Report Category') ArpRptCat on R.RequestId=ArpRptCat.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=6 AND FieldName LIKE '%Report Name') ArpRptName on R.RequestId=ArpRptName.RequestId
left join (SELECT * FROM SC.RequestAssetTrackingDetails WHERE MethodId=6 AND FieldName LIKE '%Post-install Validation') ArpPostInstVal on R.RequestId=ArpPostInstVal.RequestId
left join (select RequestId, (select DetailData from sc.RequestPackageDetails RPD2 where RPD2.RequestId = RPD1.RequestId and RPD2.PackageData = 'Package Id') [PackageId] from sc.RequestPackageDetails RPD1 where PackageType in ('Microsoft SCCM Application','Microsoft SCCM Package') and PackageData = 'Package ID' and RequestId not in ('60765','62978')) RPD on R.RequestId = RPD.RequestId

WHERE (	S.StatusId IN (SELECT Value FROM string_split(@pStatusFilter, ';') WHERE Value <> '') 	OR @pStatusFilter IS NULL) and OSName like '%Windows 10' 
ORDER BY ProductTitle
END