select CIIR.FromCIID, CIIR.ToCIID, CIRT.Description, UIFrom.BulletinID, UIFrom.ArticleID, UIFrom.Title, UITo.BulletinID, uito.ArticleID, uito.Title, uito.IsSuperseded
from v_UpdateInfo UIFrom full join 
	 v_CIRelation CIIR on UIFrom.CI_ID = CIIR.FromCIID full join
	 v_UpdateInfo UITo on CIIR.ToCIID = UITo.CI_ID full join
	 v_CIRelationTypes CIRT on CIIR.RelationType = CIRT.RelationType
where uito.IsSuperseded != 1