--This gets apps requested for the past 2 days prior to current date.

select PackageID, PackageName, count(*)
from tb_CompletedOrder
where DATEDIFF( d, CompletedTimestamp, getdate()) < 2
group by PackageID, PackageName
order by count(*) DESC 


--Columns named, packageID ignored
select PackageName AS "Package Name", count(*) AS "Times Requested"
from tb_CompletedOrder
where DATEDIFF( d, CompletedTimestamp, getdate()) < 2
group by PackageID, PackageName
order by count(*) DESC 