select pkg.PackageType [Type Number], 
	   case pkg.PackageType
	   when '0' then 'Package'
	   when '3' then 'Driver Package'
	   when '4' then 'Task Sequence'
	   when '5' then 'Software Update Group'
       when '6' Then 'Device Settings Package'
       when '7' Then 'Virtual Package'
       when '8' then 'Application'
	   when '257' then 'OS image'
	   when '258' then 'Boot image'
       when '259' then 'OS Upgrade Package'
       when '259' Then 'OS Install Package'           
	   when '260' Then 'VHD package'
	   end [Type Name], AVG(psrs.SourceSize)/1024 [Avg size in MB],
	   count(*) [Count]
from v_PackageStatusRootSummarizer PSRS join
	 v_package pkg ON psrs.PackageID = pkg.PackageID
group by pkg.PackageType
order by PackageType