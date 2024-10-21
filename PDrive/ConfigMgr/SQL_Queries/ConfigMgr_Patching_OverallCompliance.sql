select ui.BulletinID, ui.ArticleID, ui.Title, ui.DateRevised, ui.IsSuperseded, ucs.NumTotal, ucs.NumNotApplicable, ucs.NumMissing, 
	   ucs.NumPresent, ucs.NumInstalled, ucs.NumFailed, ucs.NumUnknown, ((NumTotal-NumMissing)*1.00 / NumTotal) *100 [Compliance]
from v_Update_ComplianceSummary UCS join
	 v_UpdateInfo UI on ucs.CI_ID = ui.CI_ID
order by Compliance desc