-- Total packages distributed by DP
select RIGHT(LEFT(DPNALPATH,25),13) [Server], LastStatusTime, PkgCount, NumberInstalled, NumberInProgress, NumberErrors
from v_ContentDistributionReport_DP
order by Server

-- Packages not using DP groups
select cdss.PkgID, pkg.Manufacturer, pkg.Name, pkg.Version, pkg.PkgSourcePath, psrs.sourcesize/1024 [Size MB],
	   case pkg.PackageType
	   when 0 then 'Package'
	   when 3 then 'Driver Package'
	   when 257 then 'Image'
	   else 'Other' 
	   end [Type],
	   cdss.TargeteddDPCount
from v_ContDistStatSummary CDSS join
	 v_Package Pkg on cdss.PkgID = pkg.PackageID join
	 v_PackageStatusRootSummarizer PSRS on pkg.PackageID = PSRS.PackageID
where TargeteddDPCount not in (13,6,7,0)

-- DP disk space
SELECT     SiteCode AS [Site Code], RIGHT(LEFT(NALPATH,25),13) AS Server, Drive, (BytesTotal/1024/1024) AS [Total (GB)], (BytesFree/1024/1024) as [Free (GB)], PercentFree as [Percent Free]
FROM         v_DistributionPointDriveInfo
ORDER BY PercentFree