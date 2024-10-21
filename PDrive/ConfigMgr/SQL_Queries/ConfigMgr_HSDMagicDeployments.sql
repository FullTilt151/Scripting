select Pkg.Name, Pkg.Version, ProgramName, CollectionName, NumberSuccess, NumberInProgress, NumberErrors, NumberTotal
from v_DeploymentSummary Adv join
	 v_Package Pkg on adv.PackageID = pkg.PackageID
where SoftwareName like 'hsd%' and CollectionName not in ('ALH5715A_HSD_QA','WP1 - WQ100196 - Huminst_DNR','WP1 - WQ100196 - Huminst_RDP','WP1 - WQ1000B1 - Huminst_DNR','WP1 - WQ1000B1 - Huminst_RDP','WP1 - WQ100197 - Huminst_DNR','WP1 - WQ100197 - Huminst_RDP') and
	  pkg.Version != '16.10.1'
order by Pkg.Name, Pkg.Version, ProgramName