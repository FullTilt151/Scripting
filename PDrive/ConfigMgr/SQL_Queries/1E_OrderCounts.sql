select *
from tb_CompletedOrder
where DATEDIFF( d, CompletedTimestamp, getdate()) < 7
order by CompletedTimestamp DESC


select PackageID, PackageName, count(*)
from tb_CompletedOrder
where DATEDIFF( d, CompletedTimestamp, getdate()) < 7
group by PackageID, PackageName
order by count(*) DESC