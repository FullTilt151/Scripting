SELECT *
FROM ContentDeliveries

select *
from ContentDistributionJobs

select *
from ContentGroups

select distinct AdvertID, PackageID, CollectionId, CountAll, CountDP, CountPeer, CountAlreadyCached, CountMixedDPPeer, SumPeer, SumDP, SumAlreadyCached, DeploymentDate
from reporting.NomadDeploymentSummary
order by AdvertID, PackageID