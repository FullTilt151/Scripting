-- Current jobs
select dp.ServerName, 
		case dj.action
		when 1 then 'UPDATE'
		when 2 then 'ADD'
		when 5 then 'CANCEL'
		end [Action], 
		case dj.state
		when 0 then 'PENDING'
		when 1 then 'READY'
		when 2 then 'STARTED'
		when 3 then 'INPROGRESS'
		when 4 then 'PENDING_RESTART'
		when 5 then 'COMPLETE'
		when 6 then 'FAILED'
		when 7 then 'CANCELLED'
		when 8 then 'SUSPENDED'
		end [State], dj.pkgid, dj.CreationTime, dj.TotalSize, dj.RemainingSize
from DistributionJobs DJ join
	 DistributionPoints dp on dj.DPID = dp.DPID

-- Content by DP
select dp.ServerName, cd.*
from ContentDistributionByDP cd join
	 distributionpoints dp on cd.dpid = dp.DPID
order by ServerName

-- Content by DP by pkg
select dp.ServerName, cd.*
from contentdistribution cd join
	 distributionpoints dp on cd.dpid = dp.DPID
where pkgid = 'CAS00E5A'

-- Content by pkg
select *
from ContentDistributionByPkg
where pkgid = 'CAS00E5A'