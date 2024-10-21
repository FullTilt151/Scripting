select pkg.PackageType [Type Number], 
	   case pkg.PackageType
	   when '0' then 'Package'
	   when '3' then 'Driver Package'
	   when '4' then 'Task Sequene'
	   when '5' then 'Software Update Group'
	   when '257' then 'OS image'
	   when '258' then 'Boot image'
	   when '8' then 'Application'
	   end [Type Name], AVG(psrs.SourceSize)/1024 [Avg size in MB],
	   count(*) [Count]
from v_PackageStatusRootSummarizer PSRS join
	 v_package pkg ON psrs.PackageID = pkg.PackageID
group by pkg.PackageType
order by PackageType